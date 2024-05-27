import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:synchronized/extension.dart';
import 'package:wenznote/commons/util/log_util.dart';
import 'package:wenznote/commons/util/mehod_time_record.dart';
import 'package:wenznote/model/card/po/card_po.dart';
import 'package:wenznote/model/card/po/card_set_po.dart';
import 'package:wenznote/model/card/po/card_study_config_po.dart';
import 'package:wenznote/model/card/po/card_study_record_po.dart';
import 'package:wenznote/model/delta/db_delta.dart';
import 'package:wenznote/model/note/po/doc_dir_po.dart';
import 'package:wenznote/model/note/po/doc_po.dart';
import 'package:wenznote/service/api/delta_api.dart';

import '../../service_manager.dart';
import '../record_sync_service.dart';

/// 1.下载 delta 数据，解析到数据库 -> 需要校验的地方：pid死环
/// 2.保存 delta 数据，触发同步任务
///
class RecordSyncServiceImpl extends RecordSyncService {
  @override
  ServiceManager serviceManager;

  RecordSyncServiceImpl(this.serviceManager);

  var pullSingleLock = Lock();
  var pullAllLock = Lock();
  var mergeLock = Lock();

  var pushLock = Lock();

  Timer? pullTimer;

  @override
  void startPullTimer() {
    pullTimer?.cancel();
    pullTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      pullDbData(pullAll: true);
    });
    pullDbData(pullAll: true);
    //触发一次push
    pushDbDelta();
  }

  @override
  void stopPullTimer() {
    pullTimer?.cancel();
    pullTimer = null;
  }

  @override
  Future<void> removeDbDelta(List<String> dataIdList) async {
    for (var dataId in dataIdList) {
      var dbDelta = documentIsar.dbDeltas
          .filter()
          .dataIdEqualTo(dataId)
          .clientIdEqualTo(serviceManager.userService.clientId)
          .findFirstSync();
      dbDelta ??= DbDelta(
        clientId: serviceManager.userService.clientId,
        dataId: dataId,
      );
      dbDelta.deleted = true;
      dbDelta.content = "";
      dbDelta.hasUpload = false;
      dbDelta.updateTime = DateTime.now().millisecondsSinceEpoch;
      await documentIsar.writeTxn(() async {
        await documentIsar.dbDeltas.put(dbDelta!);
      });
    }
    pushDbDelta();
  }

  /// 更新数据
  /// DbDelta.content=> [{"key":{time:1,value:?}}]
  @override
  Future<void> putDbDelta({
    required String dataId,
    required String dataType,
    required Map<String, Object?> properties,
    bool uploadNow = true,
  }) async {
    printLog("putDbDelta, dataId:$dataId, dataType:$dataType");
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
    await documentIsar.writeTxn(() async {
      await documentIsar.dbDeltas.put(delta!);
    });
    // 触发即可，不用管结果如何
    if (uploadNow) {
      pushDbDelta();
    }
  }

  @override
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
      await documentIsar.writeTxn(() async {
        await documentIsar.dbDeltas.put(delta!);
      });
    }
    // 触发即可，不用管结果如何
    if (uploadNow) {
      pushDbDelta();
    }
  }

  Future<void> pushDbDelta() async {
    printLog("pushDbDelta start");
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

  DeltaApi get api => DeltaApi(
        baseUrl: serviceManager.userService.noteServerUrl ?? "",
        token: serviceManager.userService.token,
        clientId: serviceManager.userService.clientId.toString(),
        securityVersion:
            serviceManager.cryptService.getCurrentPassword()?.version,
      );

  Future<bool> _pushDbDelta() async {
    return pushLock.synchronized(() async {
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
        var result = await api.uploadDbDelta(DbUploadVO(
          clientId: clientId,
          items: encryptDbDelta(dbDeltas),
          securityVersion:
              serviceManager.cryptService.getCurrentPassword()?.version ?? 0,
        ));

        if (result) {
          for (var value in dbDeltas) {
            value.hasUpload = true;
          }
          await documentIsar.writeTxn(() async {
            await documentIsar.dbDeltas.putAll(dbDeltas);
          });
          serviceManager.p2pService
              .sendUpdateRecordMessage(dbDeltas.map((e) => e.dataId!).toList());
          return true;
        }
        return false;
      } catch (e) {
        e.printError();
        printLog("pushDbDelta error:$e");
        return false;
      }
    });
  }

  List<DbDelta> encryptDbDelta(List<DbDelta> dbDeltas) {
    return dbDeltas
        .map((e) => DbDelta(
              id: e.id,
              clientId: e.clientId,
              dataType: e.dataType,
              dataId: e.dataId,
              content: serviceManager.cryptService
                  .encodeStringByCurrentPwd(e.content),
              updateTime: e.updateTime,
              deleted: e.deleted,
              hasUpload: e.hasUpload,
              securityVersion:
                  serviceManager.cryptService.getCurrentPassword()?.version,
            ))
        .toList();
  }

  @override
  String? get noteServerUrl {
    var noteServer = serviceManager.userService.noteServer;
    if (noteServer == null) {
      return null;
    }
    return "http://${noteServer.host}:${noteServer.port}";
  }

  @override
  bool get hasNoteServer {
    var noteServer = serviceManager.userService.noteServer;
    return noteServer != null;
  }

  /// 下载记录型数据
  @override
  Future<void> pullDbData(
      {bool pullAll = false, List<String>? dataIdList}) async {
    if (!hasNoteServer) {
      return;
    }
    var pullLock = pullSingleLock;
    if (pullAll) {
      pullLock = pullAllLock;
    }

    return pullLock.synchronizedWithLog(() async {
      try {
        /**
         * 1.获取 client states 数据
         */
        var allDataList = await documentIsar.dbDeltas.where().findAll();
        var uploadList = allDataList;
        if (dataIdList != null) {
          uploadList = allDataList
              .where((element) => !dataIdList.contains(element.dataId))
              .toList();
        }
        var clientMap = HashMap<int, int>();
        for (var uploadItem in uploadList) {
          var clientId = uploadItem.clientId;
          if (clientId == null) {
            continue;
          }
          var old = clientMap[clientId];
          var newValue = uploadItem.updateTime ?? 0;
          if (old == null || newValue > old) {
            clientMap[clientId] = newValue;
          }
        }
        var clientStates = <ClientDbStateVO>[];
        clientMap.forEach((key, value) {
          clientStates.add(ClientDbStateVO(clientId: key, clientTime: value));
        });
        var token = serviceManager.userService.token;
        if (token == null) {
          return;
        }
        var dataTypeList = [
          "note",
          "dir",
          "cardSet",
          "cardSetConfig",
          "cardStudy"
        ];
        for (var dataType in dataTypeList) {
          try {
            await _pullDbData(
              token: token,
              pullAll: pullAll,
              clientStates: clientStates,
              dataIdList: dataIdList,
              dataType: dataType,
              localAllList: allDataList,
            );
          } catch (e, stack) {
            if (kDebugMode) {
              print(stack);
            }
            printLog("同步时下载$dataType类型数据失败，$e");
          }
        }
        var cardSetList = await serviceManager.cardService.queryCardSetList();
        for (var cardSet in cardSetList) {
          try {
            var startTime = DateTime.now().millisecondsSinceEpoch;
            await _pullDbData(
              token: token,
              pullAll: pullAll,
              localAllList: allDataList,
              clientStates: clientStates,
              dataIdList: dataIdList,
              dataType: "card-${cardSet.uuid}",
            );
            var endTime = DateTime.now().millisecondsSinceEpoch;
            var useTime = endTime - startTime;
            if (kDebugMode) {
              print('pull card use time:$useTime');
            }
          } catch (e) {
            printLog("同步时下载卡片数据失败，$e");
          }
        }
      } catch (e) {
        printLog("同步时下载记录数据失败，$e");
      }
    }, logTitle: 'pull db delta');
  }

  Future<void> _pullDbData({
    required String token,
    required bool pullAll,
    required List<DbDelta> localAllList,
    List<ClientDbStateVO>? clientStates,
    List<String>? dataIdList,
    String? dataType,
  }) async {
    var updateList = await api.queryDbDeltaList(DbQueryVO(
        queryAll: pullAll,
        clientStates: clientStates,
        dataIdList: dataIdList,
        dataType: dataType));
    if (updateList == null) {
      return;
    }
    printLog("pull db delta size:${updateList.length}");
    // 解密
    for (var element in updateList) {
      element.content = serviceManager.cryptService
          .decodeString(element.content, element.securityVersion);
    }
    // 对记录进行分组
    var groupMap = updateList.groupBy((item) {
      return item.dataId ?? "";
    });
    // 5.对每个分组地记录进行分析，得到最终数据
    for (var entry in groupMap.entries) {
      var dataId = entry.key;
      var value = entry.value;
      // 6.从本地查询出dataId对应的数据
      var localList =
          localAllList.where((element) => element.dataId == dataId).toList();
      var mergeList = <DbDelta>[];
      mergeList.addAll(localList);
      mergeList.addAll(value);
      // 7.将所有的dbDelta数据合并起来计算出对应的数据
      await dbDeltaToLocalData(dataId, mergeList);
      // 8.将下载的数据存到本地数据库
      await saveDbDelta(localAllList, value);
    }
    var hasDirItem = updateList.any((element) => element.dataType == "dir");
    if (hasDirItem) {
      await calcDirPid();
    }
  }

  /// 保持或者合并DbDelta数据
  Future<void> saveDbDelta(
      List<DbDelta> localAllList, List<DbDelta> remoteList) async {
    for (var delta in remoteList) {
      var existItem = localAllList
          .where((element) =>
              element.dataId == delta.dataId &&
              element.clientId == delta.clientId)
          .toList();
      if (existItem.isEmpty) {
        delta.id = Isar.autoIncrement;
        delta.hasUpload = true;
        await documentIsar.writeTxn(() async {
          await documentIsar.dbDeltas.put(delta);
        });
      } else {
        if ((delta.updateTime ?? 0) > (existItem.first.updateTime ?? 0)) {
          delta.id = existItem.first.id;
          delta.hasUpload = true;
          await documentIsar.writeTxn(() async {
            await documentIsar.dbDeltas.put(delta);
          });
        }
      }
    }
  }

  /// 计算 pid，移除回环
  Future<void> calcDirPid() async {
    var dirDbDeltas =
        await documentIsar.dbDeltas.filter().dataTypeEqualTo("dir").findAll();
    // id,pid,time
    List<PidItem> pidItemList = [];
    for (var dirItem in dirDbDeltas) {
      var content = dirItem.content;
      if (content == null || content.isEmpty) {
        continue;
      }
      var propArray = jsonDecode(content);
      if (propArray is! List) {
        continue;
      }
      for (var prop in propArray) {
        if (prop is! Map) {
          continue;
        }
        var pidProp = prop['pid'];
        if (pidProp is! Map) {
          continue;
        }
        pidItemList.add(PidItem(
            id: dirItem.dataId, pid: pidProp["value"], time: pidProp["time"]));
      }
    }
    pidItemList.sort((a, b) {
      return (a.time ?? 0).compareTo(b.time ?? 0);
    });
    // 计算 pid
    Map<String, String?> pidMap = {};
    for (var pidItem in pidItemList) {
      var pid = pidItem.pid;
      var originId = pidItem.id;
      if (originId == null) {
        continue;
      }
      bool isCycle = false;
      while (pid != null) {
        if (pid == originId) {
          isCycle = true;
          break;
        }
        pid = pidMap[pid];
      }
      if (!isCycle) {
        // 非死环，则更新，否则此次更新无效
        pidMap[originId] = pidItem.pid;
      }
    }
    // 将pid更新到本地
    var dirList = await documentIsar.docDirPOs.where().findAll();
    List<DocDirPO> updateList = [];
    for (var dir in dirList) {
      if (dir.pid != pidMap[dir.uuid]) {
        dir.pid = pidMap[dir.uuid];
        updateList.add(dir);
      }
    }
    if (updateList.isNotEmpty) {
      documentIsar.writeTxn(() async {
        await documentIsar.docDirPOs.putAll(updateList);
      });
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
        if (dataType.startsWith("card-")) {
          await dbDeltaToLocalCard(dataId, mergeList);
        }
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
      await documentIsar.writeTxn(() async {
        await documentIsar.docPOs.put(item);
      });
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
      await documentIsar.writeTxn(() async {
        await documentIsar.cardSetPOs.filter().uuidEqualTo(dataId).deleteAll();
      });
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
    await documentIsar.writeTxn(() async {
      await documentIsar.cardSetPOs.put(item);
    });
  }

  Future<void> dbDeltaToLocalCardSetConfig(
      String dataId, List<DbDelta> mergeList) async {
    // 计算合并得到最新的属性
    Map<String, PropertyInfo>? properties = getProperties(mergeList);
    if (properties == null) {
      await documentIsar.writeTxn(() async {
        await documentIsar.cardStudyConfigPOs
            .filter()
            .uuidEqualTo(dataId)
            .deleteAll();
      });
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
    await documentIsar.writeTxn(() async {
      await documentIsar.cardStudyConfigPOs.put(item);
    });
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
    await documentIsar.writeTxn(() async {
      await documentIsar.cardPOs.put(item);
    });
  }

  Future<void> dbDeltaToLocalStudyRecord(
      String dataId, List<DbDelta> mergeList) async {
    // 计算合并得到最新的属性
    Map<String, PropertyInfo>? properties = getProperties(mergeList);
    if (properties == null) {
      await documentIsar.writeTxn(() async {
        await documentIsar.cardStudyRecordPOs
            .filter()
            .uuidEqualTo(dataId)
            .deleteAll();
      });
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
    await documentIsar.writeTxn(() async {
      await documentIsar.cardStudyRecordPOs.put(item);
    });
  }

  Future<void> dbDeltaToLocalDir(String dataId, List<DbDelta> mergeList) async {
    // 计算合并得到最新的属性
    Map<String, PropertyInfo>? properties = getProperties(mergeList);
    if (properties == null) {
      await documentIsar.writeTxn(() async {
        await documentIsar.docDirPOs.filter().uuidEqualTo(dataId).deleteAll();
      });
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
    await documentIsar.writeTxn(() async {
      await documentIsar.docDirPOs.put(item);
    });
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

  @override
  Future<void> reUploadDbData() async {
    await reUploadAllDbData();
    await reUploadOldPwdDbData();
  }

  // 重新上传所有本地数据，一般在密码修改之后或者服务器修改之后执行
  Future<bool> reUploadAllDbData() async {
    var clientId = serviceManager.userService.client?.id;
    var dbDeltas = await documentIsar.dbDeltas.where().findAll();
    var result = await api.uploadDbDelta(DbUploadVO(
      clientId: clientId,
      items: encryptDbDelta(dbDeltas),
      securityVersion:
          serviceManager.cryptService.getCurrentPassword()?.version ?? 0,
    ));
    return result;
  }

  // 重新上传旧密码部分数据，通过服务器查询存在的旧密码版本数据
  Future<void> reUploadOldPwdDbData() async {
    // 1.读取本地密码版本
    // 2.从服务下载密码版本对于的数据
    // 3.重新上传服务器下载的数据
    var versions = serviceManager.cryptService.getPasswordVersions();
    var oldVersionDbDeltas = await api.queryOldPwdVersionDbDelta(versions);
    if (oldVersionDbDeltas == null || oldVersionDbDeltas.isEmpty) {
      return;
    }
    var clientId = serviceManager.userService.client?.id;
    await api.uploadDbDelta(DbUploadVO(
      clientId: clientId,
      items: encryptDbDelta(oldVersionDbDeltas),
      securityVersion:
          serviceManager.cryptService.getCurrentPassword()?.version ?? 0,
    ));
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
      'time': time,
      'value': value,
    };
  }

  factory PropertyInfo.fromMap(Map<String, dynamic> map) {
    return PropertyInfo(
      time: map['time'] as int?,
      value: map['value'] as Object?,
    );
  }
}

class PidItem {
  String? id;
  String? pid;
  int? time;

  PidItem({
    required this.id,
    required this.pid,
    required this.time,
  });
}
