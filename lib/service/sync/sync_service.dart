import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:ffi';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:note/model/card/po/card_po.dart';
import 'package:note/model/card/po/card_set_po.dart';
import 'package:note/model/card/po/card_study_config_po.dart';
import 'package:note/model/card/po/card_study_record_po.dart';
import 'package:note/model/delta/db_delta.dart';
import 'package:note/model/note/po/doc_dir_po.dart';
import 'package:note/model/note/po/doc_po.dart';
import 'package:note/service/isar/isar_service_mixin.dart';
import 'package:note/service/service_manager.dart';

import '../../config/app_constants.dart';

/// 1.下载 delta 数据，解析到数据库 -> 需要校验的地方：pid死环
/// 2.保存 delta 数据，触发同步任务
///
class SyncService with IsarServiceMixin {
  @override
  ServiceManager serviceManager;

  SyncService(this.serviceManager);

  var pullLock = Lock();
  var pushLock = Lock();

  Timer? pullTimer;

  void startPullTimer() {
    pullTimer?.cancel();
    pullTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      pullDbData(pullAll: true);
    });
    pullDbData(pullAll: true);
    //触发一次push
    pushDbDelta();
  }

  void stopPullTimer() {
    pullTimer?.cancel();
    pullTimer = null;
  }

  Future<void> removeDbDelta(List<String> dataIdList) async {
    for (var dataId in dataIdList) {
      var dbDelta = documentIsar.dbDeltas
          .filter()
          .dataIdEqualTo(dataId)
          .clientIdEqualTo(serviceManager.userService.clientId)
          .findFirstSync();
      if (dbDelta == null) {
        continue;
      }
      dbDelta.deleted = true;
      dbDelta.content = "";
      dbDelta.hasUpload = false;
      await documentIsar.writeTxn(() => documentIsar.dbDeltas.put(dbDelta));
    }
    pushDbDelta();
  }

  /// 更新数据
  /// DbDelta.content=> [{"key":{time:1,value:?}}]
  Future<void> putDbDelta({
    required String dataId,
    required String dataType,
    required Map<String, Object?> properties,
    bool uploadNow = true,
  }) async {
    int clientId = serviceManager.userService.clientId;
    var delta = documentIsar.dbDeltas
        .filter()
        .dataIdEqualTo(dataId)
        .clientIdEqualTo(clientId)
        .findFirstSync();
    delta ??= DbDelta(
      dataId: dataId,
      dataType: dataType,
      clientId: clientId,
    );
    delta.hasUpload = false;
    delta.updateTime = DateTime.now().millisecondsSinceEpoch;
    // DbDelta.content=> [{"key":{time:1,value:?}}]
    var content = delta.content ?? "";
    var deltaArr = [];
    if (content.isNotEmpty) {
      deltaArr = jsonDecode(content);
    }
    var propJson = properties
        .map((key, value) => MapEntry(
            key,
            PropertyInfo(
                    time: DateTime.now().millisecondsSinceEpoch, value: value)
                .toMap()))
        .cast<String, Map>();
    deltaArr.add(propJson);
    deltaArr == mergeDeltaArray(deltaArr);
    delta.content = jsonEncode(deltaArr);
    await documentIsar.writeTxn(() => documentIsar.dbDeltas.put(delta!));
    // 触发即可，不用管结果如何
    if (uploadNow) {
      pushDbDelta();
    }
  }

  Future<void> putDbDeltas({
    required String dataType,
    required List<Map<String, Object?>> objList,
    bool uploadNow = true,
  }) async {
    int clientId = serviceManager.userService.clientId;
    for (var obj in objList) {
      var dataId = obj['uuid'] as String;
      var delta = documentIsar.dbDeltas
          .filter()
          .dataIdEqualTo(dataId)
          .clientIdEqualTo(clientId)
          .findFirstSync();
      delta ??= DbDelta(
        dataId: dataId,
        dataType: dataType,
        clientId: clientId,
      );
      delta.hasUpload = false;
      delta.updateTime = DateTime.now().millisecondsSinceEpoch;
      // DbDelta.content=> [{"key":{time:1,value:?}}]
      var content = delta.content ?? "";
      var deltaArr = <Map>[];
      if (content.isNotEmpty) {
        deltaArr = jsonDecode(content);
      }
      var propJson = obj
          .map((key, value) => MapEntry(
              key,
              PropertyInfo(
                      time: DateTime.now().millisecondsSinceEpoch, value: value)
                  .toMap()))
          .cast<String, Map>();
      deltaArr.add(propJson);
      delta.content = jsonEncode(deltaArr);
      await documentIsar.writeTxn(() => documentIsar.dbDeltas.put(delta!));
    }
    // 触发即可，不用管结果如何
    if (uploadNow) {
      pushDbDelta();
    }
  }

  Future<void> pushDbDelta() async {
    var result = await _pushDbDelta();
    if (!result) {
      Timer.periodic(const Duration(seconds: 5), (timer) {
        if (pullTimer == null) {
          // 用户关闭了pull定时任务，即退出了登录，无需继续push，等下次登录再push
          return;
        }
        pushDbDelta();
        timer.cancel();
      });
    }
  }

  Future<bool> _pushDbDelta() async {
    pushLock.lock();
    try {
      var clientId = serviceManager.userService.client?.id;
      var dbDeltas = await documentIsar.dbDeltas
          .filter()
          .hasUploadEqualTo(false)
          .clientIdEqualTo(clientId)
          .findAll();
      if (dbDeltas.isEmpty) {
        return true;
      }
      for (var dbDelta in dbDeltas) {
        dbDelta.updateTime ??= DateTime.now().millisecondsSinceEpoch;
      }
      var result = await Dio().post("$noteServerUrl/db/uploadDbDelta",
          options: Options(
            headers: {
              "token": serviceManager.userService.token,
            },
          ),
          data: {
            "clientId": clientId,
            "items": dbDeltas.map((e) => e.toMap()).toList(),
          });
      if (result.data['msg'] == AppConstants.success) {
        for (var value in dbDeltas) {
          value.hasUpload = true;
        }
        await documentIsar
            .writeTxn(() => documentIsar.dbDeltas.putAll(dbDeltas));
        return true;
      }
      return false;
    } catch (e) {
      e.printError();
      return false;
    } finally {
      pushLock.unlock();
    }
  }

  String get noteServerUrl {
    var noteServer = serviceManager.userService.noteServer;
    return "http://${noteServer?.host}:${noteServer?.port}";
  }

  bool get hasNoteServer {
    var noteServer = serviceManager.userService.noteServer;
    return noteServer != null;
  }

  /// 下载记录型数据
  Future<void> pullDbData(
      {bool pullAll = false, List<String>? dataIdList}) async {
    if (!hasNoteServer) {
      return;
    }
    Int64();
    pullLock.lock();
    try {
      /**
       * 1.获取 client states 数据
       */
      var dataList = await documentIsar.dbDeltas.where().findAll();
      if (dataIdList != null) {
        dataList.removeWhere((element) => !dataIdList.contains(element.dataId));
      }
      var clientMap = HashMap<int, int>();
      for (var value in dataList) {
        var clientId = value.clientId;
        if (clientId == null) {
          continue;
        }
        var old = clientMap[clientId];
        var newValue = value.updateTime;
        if (newValue == null) {
          continue;
        }
        if (old == null || newValue > old) {
          clientMap[clientId] = newValue;
        }
      }
      var clientStates = [];
      clientMap.forEach((key, value) {
        clientStates.add({'clientId': key, 'clientTime': value});
      });
      /**
       * 2.查询 db 数据
       */
      var result = await Dio().post("$noteServerUrl/db/queryDbDeltaList",
          options: Options(
            headers: {
              "token": serviceManager.userService.token,
            },
          ),
          data: {
            "queryAll": pullAll,
            "clientStates": clientStates,
          });
      /**
       * 3.将查询的数据解析，并且存入数据库
       */
      var data = result.data;
      List<DbDelta> updateList = [];
      if (data["msg"] == AppConstants.success) {
        List list = data["data"];
        for (var value in list) {
          var item = DbDelta.fromMap(value);
          updateList.add(item);
        }
      }
      // 4.对记录进行分组
      var groupMap = updateList.groupBy((item) {
        return item.dataId ?? "";
      });
      // 5.对每个分组地记录进行分析，得到最终数据
      for (var entry in groupMap.entries) {
        var dataId = entry.key;
        var value = entry.value;
        // 6.从本地查询出dataId对应的数据
        var localList = await documentIsar.dbDeltas
            .filter()
            .dataIdEqualTo(dataId)
            .findAll();
        var mergeList = <DbDelta>[];
        mergeList.addAll(localList);
        mergeList.addAll(value);
        // 7.将所有的dbDelta数据合并起来计算出对应的数据
        dbDeltaToLocalData(dataId, mergeList);
        // 8.将下载的数据存到本地数据库
        saveDbDelta(localList, value);
      }
    } finally {
      pullLock.unlock();
    }
  }

  /// 保持或者合并DbDelta数据
  Future<void> saveDbDelta(
      List<DbDelta> localList, List<DbDelta> remoteList) async {
    for (var delta in remoteList) {
      var existItem = documentIsar.dbDeltas
          .filter()
          .dataIdEqualTo(delta.dataId)
          .and()
          .clientIdEqualTo(delta.clientId)
          .findFirstSync();
      if (existItem == null) {
        delta.id = Isar.autoIncrement;
        delta.hasUpload = true;
        await documentIsar.writeTxn(() => documentIsar.dbDeltas.put(delta));
      } else {
        if ((delta.updateTime ?? 0) > (existItem.updateTime ?? 0)) {
          delta.id = existItem.id;
          delta.hasUpload = true;
          await documentIsar.writeTxn(() => documentIsar.dbDeltas.put(delta));
        }
      }
    }
  }

  /// 将DbDelta数据转换为记录型数据
  Future<void> dbDeltaToLocalData(
      String dataId, List<DbDelta> mergeList) async {
    if (mergeList.isEmpty) {
      return;
    }
    var dataType = mergeList.first.dataType;
    if (dataType == null) {
      return;
    }
    mergeList
        .sort((a, b) => (a.updateTime ?? 0).compareTo((b.updateTime ?? 0)));
    // 1.根据时间排序
    // 2.模拟法
    // 3.删除一些冗余的信息
    switch (dataType) {
      case 'note':
        //创建、更新名称、移动、删除、存到笔记
        await dbDeltaToLocalNote(dataId, mergeList);
        break;
      case 'cardSet':
        await dbDeltaToLocalCardSet(dataId, mergeList);
        break;
      case 'card':
        await dbDeltaToLocalCard(dataId, mergeList);
        break;
      case 'dir':
        await dbDeltaToLocalDir(dataId, mergeList);
        break;
      case 'cardStudy':
        await dbDeltaToLocalStudyRecord(dataId, mergeList);
        break;
      case 'cardSetConfig':
        await dbDeltaToLocalCardSetConfig(dataId, mergeList);
        break;
      default:
        print("not suppert:$dataType");
        break;
    }
  }

  /// 将 DbDelta 转为 Note 数据
  /// mergeList数据结构如下：
  /// [{
  ///   "name":{
  ///     "value":"名称",
  ///     "time":123
  ///    }
  /// }]
  Future<void> dbDeltaToLocalNote(
      String dataId, List<DbDelta> mergeList) async {
    // 计算合并得到最新的属性
    Map<String, PropertyInfo>? properties = getProperties(mergeList);
    if (properties == null) {
      await documentIsar.writeTxn(
          () => documentIsar.docPOs.filter().uuidEqualTo(dataId).deleteAll());
      return;
    }
    //将属性转为笔记记录，存到笔记数据库中
    var doc =
        documentIsar.docPOs.filter().uuidEqualTo(dataId).findFirstSync() ??
            DocPO();
    var map = properties
        .map((key, value) => MapEntry(key, value.value))
        .cast<String, dynamic>();
    try {
      var item = DocPO.fromMap(map);
      item.id = doc.id;
      item.uuid = dataId;
      await documentIsar.writeTxn(() => documentIsar.docPOs.put(item));
    } catch (e) {
      e.printError();
    }
  }

  /// DbDelta.content=> [{"key":{time:1,value:?}}]
  Map<String, PropertyInfo>? getProperties(List<DbDelta> mergeList) {
    var properties = <String, PropertyInfo>{};
    for (var mergeItem in mergeList) {
      var content = mergeItem.content;
      if (mergeItem.deleted == true) {
        return null;
      }
      if (content == null || content.isEmpty) {
        continue;
      }
      var deltaArr = jsonDecode(content) as List;
      for (var delta in deltaArr) {
        var deltaMap = delta as Map;
        for (var deltaEntry in deltaMap.entries) {
          var deltaKey = deltaEntry.key;
          if (deltaKey is! String) {
            continue;
          }
          // 对比时间，将最新的属性替换较旧的属性
          var deltaInfo = PropertyInfo.fromMap(deltaEntry.value);
          deltaInfo.time ??= 0;
          if (properties[deltaKey] == null) {
            properties[deltaKey] = deltaInfo;
          } else {
            if (properties[deltaKey]!.time! < deltaInfo.time!) {
              properties[deltaKey] = deltaInfo;
            }
          }
        }
      }
    }
    return properties;
  }

  Future<void> dbDeltaToLocalCardSet(
      String dataId, List<DbDelta> mergeList) async {
    // 计算合并得到最新的属性
    Map<String, PropertyInfo>? properties = getProperties(mergeList);
    if (properties == null) {
      await documentIsar.writeTxn(() =>
          documentIsar.cardSetPOs.filter().uuidEqualTo(dataId).deleteAll());
      return;
    }
    //将属性转为笔记记录，存到笔记数据库中
    var doc =
        documentIsar.cardSetPOs.filter().uuidEqualTo(dataId).findFirstSync() ??
            CardSetPO();
    var map = properties
        .map((key, value) => MapEntry(key, value.value))
        .cast<String, dynamic>();
    var item = CardSetPO.fromMap(map);
    item.id = doc.id;
    item.uuid = dataId;
    await documentIsar.writeTxn(() => documentIsar.cardSetPOs.put(item));
  }

  Future<void> dbDeltaToLocalCardSetConfig(
      String dataId, List<DbDelta> mergeList) async {
    // 计算合并得到最新的属性
    Map<String, PropertyInfo>? properties = getProperties(mergeList);
    if (properties == null) {
      await documentIsar.writeTxn(() => documentIsar.cardStudyConfigPOs
          .filter()
          .uuidEqualTo(dataId)
          .deleteAll());
      return;
    }
    //将属性转为笔记记录，存到笔记数据库中
    var doc = documentIsar.cardStudyConfigPOs
            .filter()
            .uuidEqualTo(dataId)
            .findFirstSync() ??
        CardStudyConfigPO();
    var map = properties
        .map((key, value) => MapEntry(key, value.value))
        .cast<String, dynamic>();
    var item = CardStudyConfigPO.fromMap(map);
    item.id = doc.id;
    item.uuid = dataId;
    await documentIsar
        .writeTxn(() => documentIsar.cardStudyConfigPOs.put(item));
  }

  Future<void> dbDeltaToLocalCard(
      String dataId, List<DbDelta> mergeList) async {
    // 计算合并得到最新的属性
    Map<String, PropertyInfo>? properties = getProperties(mergeList);
    if (properties == null) {
      await documentIsar.writeTxn(
          () => documentIsar.cardPOs.filter().uuidEqualTo(dataId).deleteAll());
      return;
    }
    //将属性转为笔记记录，存到笔记数据库中
    var doc =
        documentIsar.cardPOs.filter().uuidEqualTo(dataId).findFirstSync() ??
            CardPO();
    var map = properties
        .map((key, value) => MapEntry(key, value.value))
        .cast<String, dynamic>();
    var item = CardPO.fromMap(map);
    item.id = doc.id;
    item.uuid = dataId;
    await documentIsar.writeTxn(() => documentIsar.cardPOs.put(item));
  }

  Future<void> dbDeltaToLocalStudyRecord(
      String dataId, List<DbDelta> mergeList) async {
    // 计算合并得到最新的属性
    Map<String, PropertyInfo>? properties = getProperties(mergeList);
    if (properties == null) {
      await documentIsar.writeTxn(() => documentIsar.cardStudyRecordPOs
          .filter()
          .uuidEqualTo(dataId)
          .deleteAll());
      return;
    }
    //将属性转为笔记记录，存到笔记数据库中
    var doc = documentIsar.cardStudyRecordPOs
            .filter()
            .uuidEqualTo(dataId)
            .findFirstSync() ??
        CardStudyRecordPO();
    var map = properties
        .map((key, value) => MapEntry(key, value.value))
        .cast<String, dynamic>();
    var item = CardStudyRecordPO.fromMap(map);
    item.id = doc.id;
    item.uuid = dataId;
    await documentIsar
        .writeTxn(() => documentIsar.cardStudyRecordPOs.put(item));
  }

  Future<void> dbDeltaToLocalDir(String dataId, List<DbDelta> mergeList) async {
    // 计算合并得到最新的属性
    Map<String, PropertyInfo>? properties = getProperties(mergeList);
    if (properties == null) {
      await documentIsar.writeTxn(() =>
          documentIsar.docDirPOs.filter().uuidEqualTo(dataId).deleteAll());
      return;
    }
    //将属性转为笔记记录，存到笔记数据库中
    var doc =
        documentIsar.docDirPOs.filter().uuidEqualTo(dataId).findFirstSync() ??
            DocDirPO();
    var map = properties
        .map((key, value) => MapEntry(key, value.value))
        .cast<String, dynamic>();
    var item = DocDirPO.fromMap(map);
    item.id = doc.id;
    item.uuid = dataId;
    await documentIsar.writeTxn(() => documentIsar.docDirPOs.put(item));
  }

  List<dynamic> mergeDeltaArray(List<dynamic> deltaArr) {
    Map<String, Map> propMap = {};
    List<Map> pidList = [];
    for (var delta in deltaArr) {
      var deltaMap = delta as Map;
      for (var entry in deltaMap.entries) {
        if (entry.key == "pid") {
          pidList.add({
            "pid": entry.value,
          });
        } else {
          propMap[entry.key] = entry.value;
        }
      }
    }
    return [propMap, ...pidList];
  }
}

extension on List<DbDelta> {
  Map<String, List<DbDelta>> groupBy(String Function(DbDelta o) map) {
    Map<String, List<DbDelta>> result = HashMap();
    for (var item in this) {
      var key = map.call(item);
      var list = result[key];
      list ??= [];
      list.add(item);
      result[key] = list;
    }
    return result;
  }
}

class PropertyInfo {
  int? time;
  Object? value;

  PropertyInfo({
    this.time,
    this.value,
  });

  Map<String, dynamic> toMap() {
    return {
      'time': this.time,
      'value': this.value,
    };
  }

  factory PropertyInfo.fromMap(Map<String, dynamic> map) {
    return PropertyInfo(
      time: map['time'] as int?,
      value: map['value'] as Object?,
    );
  }
}
