import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:isar/isar.dart';
import 'package:wenznote/commons/util/log_util.dart';
import 'package:wenznote/commons/util/mehod_time_record.dart';
import 'package:wenznote/model/note/po/doc_state_po.dart';
import 'package:wenznote/service/service_manager.dart';
import 'package:wenznote/service/sync/p2p_packet.pb.dart';

class DocSyncService {
  ServiceManager serviceManager;
  Map<String, int> queryDeltaTimeRecord = {};
  Map<String, int> downloadDocFileTimeRecord = {};
  Timer? _downloadTimer;

  final _downloadLock = <String, Object>{};

  DocSyncService(this.serviceManager);

  void startDownloadTimer() {
    stopDownloadTimer();
    _downloadTimer = Timer.periodic(const Duration(minutes: 20), (timer) {
      _downloadDocTask();
    });
    _downloadDocTask();
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
    var updated = await serviceManager.editService.updateDocContent(
      dataId,
      Uint8List.fromList(pkt.content),
    );
    // 没有更新成功，数据错位导致的，发送请求完整数据
    if (updated == false) {
      printLog("收到编辑更新消息，但内容没有得到更新,需要修复最新数据.");
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
    await isar.writeTxn(() async {
      await isar.docStatePOs.put(state);
    });
    serviceManager.editService.updateDocContent(
      dataId,
      Uint8List.fromList(pkt.content),
    );
  }

  Future<void> verifyDoc(List<String> docList) async {
    for (var docId in docList) {
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

  Future<void> downloadDocFile(String docId, {Duration? timeout}) async {
    var doc = await serviceManager.docService.queryDoc(docId);
    if (doc?.type == null) {
      return;
    }
    var docDownloadLock = _downloadLock.putIfAbsent(docId, () => Object());
    return docDownloadLock.synchronizedWithLog(() async {
      var noteServerUrl = serviceManager.recordSyncService.noteServerUrl;
      if (noteServerUrl == null) {
        return;
      }
      var doc = await serviceManager.editService.readDoc(docId);
      String? docState;
      if (doc != null) {
        docState = base64Encode(doc.encodeStateVectorV2());
      }
      Response result;
      try {
        result = await Dio().post(
          "$noteServerUrl/doc/download/$docId",
          options: Options(
            headers: {
              "token": serviceManager.userService.token,
            },
            responseType: ResponseType.bytes,
          ),
          data: FormData.fromMap({
            "docState": docState,
          }),
        );
      } catch (e) {
        print(e);
        if (e is DioError) {
          if (e.response?.statusCode == 401) {
            // 文件不存在，为啥会被下载？
            rethrow;
          }
        }
        return;
      }
      // result 返回的是数据+文件zip压缩包{state,file}
      if (result.statusCode == 200) {
        var fileBytes = result.data;

        // 写入文件,并且通知upload
        try {
          // 更新文档，并且检测文档是否需要更新
          await serviceManager.editService.updateDocContent(
            docId,
            fileBytes,
          );
        } catch (e) {
          // 可能存在yjs合并失败的bug，需要处理yjs类型转换问题
          // type 'ContentDeleted' is not a subtype of type 'ContentType' in type cast
          printLog("下载文档时，更新ydoc失败: $e");
        }
      }
    }, logTitle: "downloadDocFile", timeout: timeout);
  }

  /// 通过clientId,updateTime查询需要更新的文档
  /// 一旦查询到需要下载的docId，那么这个docId必须下载成功
  /// 否则，就会导致文档下载更新失败而无法打开
  /// 所以，需要将查询到的需要更新的文档，存到任务队列，直到该文档下载成功
  /// 需要注意的时，如果下载文档任务为定时任务，那么在文档编辑过程中不要执行该任务，直到编辑器关闭
  /// 编辑过程，用户可以手动下载文档进行更新，或者编辑器会自动触发p2p更新，无需下载文档
  Future<List<String>> queryUpdateList() async {
    var list = await serviceManager.docService.queryDocAndNoteList();
    return list
        .map((e) => e.uuid)
        .where((element) => element != null)
        .map((e) => e!)
        .toList();
  }

  /// 返回文档状态的最大时间点 clientId,updateTime
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

  Future<void> _downloadDocTask() async {
    var updateList = await queryUpdateList();
    for (var update in updateList) {
      await downloadDocFile(update);
    }
  }
}
