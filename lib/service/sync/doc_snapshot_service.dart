import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:wenznote/config/app_constants.dart';
import 'package:wenznote/model/note/po/doc_state_po.dart';
import 'package:wenznote/service/service_manager.dart';
import 'package:wenznote/service/sync/p2p_packet.pb.dart';

class DocSnapshotService {
  ServiceManager serviceManager;
  Map<String, int> queryDeltaTimeRecord = {};
  Map<String, int> downloadDocFileTimeRecord = {};
  Timer? _downloadTimer;
  final Lock _downloadLock = Lock();

  DocSnapshotService(this.serviceManager);

  void startDownloadTimer() {
    stopDownloadTimer();
    _downloadTimer = Timer.periodic(5.minutes, (timer) {
      _downloadUpdateSnapshot();
    });
    _downloadUpdateSnapshot();
  }

  void stopDownloadTimer() {
    _downloadTimer?.cancel();
    _downloadTimer = null;
  }

  /// 接收文档编辑增量数据，将编辑器增量更新编码到本地
  Future<void> receiveDocEditEvent(P2pPacket pkt) async {
    if (pkt.dataIdList.isEmpty) {
      return;
    }
    var dataId = pkt.dataIdList[0];
    var updated = await serviceManager.editService
        .updateDoc(dataId, Uint8List.fromList(pkt.content), needUpload: false);
    if (updated == false) {
      var snap = await serviceManager.editService.queryDocSnap(dataId);
      if (snap == null || snap.isEmpty) {
        return;
      }
      serviceManager.p2pService.sendQueryDocMessage(dataId, snap);
    }
  }

  Future<void> queryDocDelta(P2pPacket pkt) async {
    if (pkt.dataIdList.isEmpty) {
      return;
    }
    var dataId = pkt.dataIdList[0];
    var update =
        await serviceManager.editService.queryDocDelta(dataId, pkt.content);
    if (update == null || update.isEmpty) {
      return;
    }
    // 查询clientTime
    var clientId = serviceManager.userService.clientId;
    var isar = serviceManager.isarService.documentIsar;
    int clientTime = isar.docStatePOs
            .filter()
            .clientIdEqualTo(clientId)
            .and()
            .docIdEqualTo(dataId)
            .updateTimeProperty()
            .findFirstSync() ??
        0;
    // 大于 128 kb，直接重新下载，不允许p2p传输太多的数据
    if (update.length > 1024 * 128) {
      serviceManager.p2pService.sendDocDeltaMessage(
          pkt.clientId.toInt(), dataId, clientTime, Uint8List(0));
      // 发送空数据，表示无内容更新
      serviceManager.p2pService
          .sendDownloadDocMessage(pkt.clientId.toInt(), dataId);
      return;
    }
    // 将增量数据发送过去
    serviceManager.p2pService
        .sendDocDeltaMessage(pkt.clientId.toInt(), dataId, clientTime, update);
  }

  /// 与 receiveDocEditEvent 相同，接收文档增量数据
  Future<void> receiveDocDelta(P2pPacket pkt) async {
    if (pkt.dataIdList.isEmpty) {
      return;
    }
    if (pkt.content.isEmpty) {
      return;
    }
    var dataId = pkt.dataIdList[0];
    var clientId = pkt.clientId.toInt();
    var clientTime = pkt.clientTime.toInt();
    var isar = serviceManager.isarService.documentIsar;
    var state = isar.docStatePOs
            .filter()
            .docIdEqualTo(dataId)
            .and()
            .clientIdEqualTo(clientId)
            .findFirstSync() ??
        DocStatePO(clientId: clientId, docId: dataId, updateTime: clientTime);
    state.updateTime = clientTime;
    await isar.writeTxn(() => isar.docStatePOs.put(state));
    serviceManager.editService
        .updateDoc(dataId, Uint8List.fromList(pkt.content), needUpload: false);
  }

  /// 查询文档状态数据
  Future<void> queryDocState(P2pPacket pkt) async {
    var isar = serviceManager.isarService.documentIsar;
    var states = await isar.docStatePOs.where().findAll();
    var clientStates = jsonDecode(utf8.decode(pkt.content));
    var result = <DocStatePO>[];
    for (var state in states) {
      var time = clientStates[state.clientId];
      if (time == null) {
        result.add(state);
        continue;
      }
      if (time < state.updateTime) {
        result.add(state);
      }
    }
    if (result.isEmpty) {
      return;
    }
    var stateJson = jsonEncode(result.map((e) => e.toMap()).toList());
    serviceManager.p2pService
        .sendDocStateMessage(pkt.clientId.toInt(), stateJson);
  }

  /// 接受到文档状态数据
  Future<void> receiveDocState(P2pPacket pkt) async {
    var stateJson = jsonDecode(utf8.decode(pkt.content)) as List;
    var states = stateJson.map((e) => DocStatePO.fromMap(e)).toList();
    for (var state in states) {
      var docId = state.docId;
      if (docId == null) {
        continue;
      }
      var lastQueryTime = queryDeltaTimeRecord[docId];
      if (lastQueryTime != null &&
          lastQueryTime < DateTime.now().millisecondsSinceEpoch) {
        continue;
      }
      // 因为服务器会限制p2p网络速度
      // 所有创建8秒查询锁：一个文档的查询间隔调大，避免无限查询，导致查询量剧增，造成网络阻塞
      queryDeltaTimeRecord[docId] =
          DateTime.now().millisecondsSinceEpoch + 8000;
      var snap = await serviceManager.editService.queryDocSnap(docId);
      if (snap == null || snap.isEmpty) {
        continue;
      }
      serviceManager.p2pService.sendQueryDocMessage(docId, snap);
    }
  }

  /// 接收下载文档指令
  Future<void> downloadDoc(P2pPacket pkt) async {
    /// 1.增加8秒文档下载锁，减少下载量
    /// 2.下载时获取文档的状态数据，通过状态数据决定是否下载最新数据
    if (pkt.dataIdList.isEmpty) {
      return;
    }
    if (!serviceManager.recordSyncService.hasNoteServer) {
      return;
    }
    var dataId = pkt.dataIdList.first;
    await downloadDocFile(dataId);
  }

  Future<void> downloadDocFile(String docId) async {
    _downloadLock.lock();
    try {
      var lastQueryTime = downloadDocFileTimeRecord[docId];
      if (lastQueryTime != null &&
          lastQueryTime < DateTime.now().millisecondsSinceEpoch) {
        return;
      }
      // 因为服务器会限制下载文件频率
      // 所有创建8秒下载锁，避免重复下载
      queryDeltaTimeRecord[docId] =
          DateTime.now().millisecondsSinceEpoch + 8000;
      var noteServerUrl = serviceManager.recordSyncService.noteServerUrl;
      var isar = serviceManager.isarService.documentIsar;

      var result = await Dio().post(
        "$noteServerUrl/snapshot/download/$docId",
        options: Options(
          headers: {
            "token": serviceManager.userService.token,
          },
          responseType: ResponseType.bytes,
        ),
      );
      // result 返回的是数据+文件zip压缩包{state,file}
      if (result.statusCode == 200) {
        var data = result.data;
        var entries = ZipDecoder().decodeBytes(data);
        Uint8List? stateBytes;
        Uint8List? fileBytes;
        for (var entry in entries) {
          if (!entry.isFile) {
            continue;
          }
          if (entry.name.endsWith("state")) {
            stateBytes = entry.content as Uint8List;
          }
          if (entry.name.endsWith("file")) {
            fileBytes = entry.content as Uint8List;
          }
        }
        if (stateBytes == null || fileBytes == null) {
          return;
        }
        // 读取状态
        var stateMap = (jsonDecode(utf8.decode(stateBytes)) as Map)
            .map((key, value) => MapEntry(key.toString(), value as int));
        List<DocStatePO> saveStates = [];
        bool needUpload = false;
        for (var entry in stateMap.entries) {
          var clientId = int.parse(entry.key);
          var time = entry.value;
          var isar = serviceManager.isarService.documentIsar;
          var saveState = await isar.docStatePOs
              .filter()
              .docIdEqualTo(docId)
              .clientIdEqualTo(clientId)
              .findFirst();
          saveState ??= DocStatePO(
            docId: docId,
            clientId: clientId,
          );
          // 判断是否需要upload本地数据
          if (clientId == serviceManager.userService.clientId) {
            var localTime = saveState.updateTime;
            if (localTime != null && localTime > time) {
              needUpload = true;
            }
            // 下载数据后，本client的状态不必更新
            // 避免state回滚，其他客户端无法知道本client状态，导致其他客户端无法下载本client数据
            continue;
          }
          saveState.updateTime = time;
          saveStates.add(saveState);
        }
        // 写入文件,并且通知upload
        await serviceManager.editService.updateDoc(
          docId,
          fileBytes,
          needUpload: needUpload,
        );
        // 写入状态
        await isar.writeTxn(() => isar.docStatePOs.putAll(saveStates));
      }
    } finally {
      _downloadLock.unlock();
    }
  }

  Future<List<String>?> queryUpdateList() async {
    var token = serviceManager.userService.token;
    if (token == null) {
      return null;
    }
    Map<String, int> clients = await getClientStates();
    var noteServer = serviceManager.recordSyncService.noteServerUrl;
    var result = await Dio().post("$noteServer/snapshot/queryUpdateList",
        options: Options(
          headers: {"token": token},
        ),
        data: {
          "clients": clients,
        });
    if (result.statusCode != 200) {
      return null;
    }
    if (result.data['msg'] == AppConstants.success) {
      var data = result.data['data'];
      if (data != null) {
        return (data as List).map((e) => e.toString()).toList();
      }
    }
    return null;
  }

  Future<Map<String, int>> getClientStates() async {
    var isar = serviceManager.isarService.documentIsar;
    var states = await isar.docStatePOs.where().findAll();
    var clients = <String, int>{};
    for (var state in states) {
      var clientId = state.clientId;
      var time = state.updateTime;
      if (clientId == null || time == null) {
        continue;
      }
      var oldTime = clients["$clientId"];
      if (oldTime == null || oldTime < time) {
        clients["$clientId"] = time;
      }
    }
    return clients;
  }

  Future<void> _downloadUpdateSnapshot() async {
    var updateList = await queryUpdateList();
    if (updateList == null) {
      return;
    }
    for (var update in updateList) {
      downloadDocFile(update);
    }
  }
}
