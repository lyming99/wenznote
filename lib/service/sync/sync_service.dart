import 'package:dio/dio.dart';
import 'package:isar/isar.dart';
import 'package:note/model/delta/db_delta.dart';
import 'package:note/service/isar/isar_service_mixin.dart';
import 'package:note/service/service_manager.dart';
import 'package:note/commons/util/list_utils.dart';
import 'dart:collection';

import '../../config/app_constants.dart';

class SyncService with IsarServiceMixin {
  @override
  ServiceManager serviceManager;

  SyncService(this.serviceManager);

  Future<void> pullAllDbData() async {
    /**
     * 1.获取 client states 数据
     */
    var dataList = await documentIsar.dbDeltas.where().findAll();
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
    var result = await Dio().post("${AppConstants.apiUrl}/db/queryDbDeltaList",
        options: Options(
          headers: {
            "token": serviceManager.userService.token,
          },
        ),
        data: {
          "queryAll": true,
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
    var groupMap = updateList.groupBy((item) {
      return (item as DbDelta).dataId ?? "";
    });
    // 将数据解析为本地数据库的数据，然后存到笔记记录、卡片记录等表里面
    // 内容需要解密，所以需要配置密码
    // 密码从configManager拿
    // 加解密
    // delta数据如何与本地数据转换：
    // 1。将delta数据转换为本地具体数据
    //    a。获取delta所对应的所有dataId数据
    //    b。对数据根据时间排序，得到数据的最终状态
    // 2。将本地数据转换为delta数据
  }
}

extension on List<dynamic> {
  Map groupBy(Object Function(Object o) map) {
    Map result = HashMap();
    for (var item in this) {
      var key = map.call(item);
      var list = result[key];
      list ??= [];
      (list as List).add(item);
    }
    return result;
  }
}

