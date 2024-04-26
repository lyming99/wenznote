import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:isar/isar.dart';
import 'package:wenznote/commons/util/log_util.dart';
import 'package:wenznote/commons/util/mehod_time_record.dart';
import 'package:wenznote/model/note/po/doc_state_po.dart';
import 'package:wenznote/service/api/doc_api.dart';
import 'package:wenznote/service/service_manager.dart';
import 'package:wenznote/service/sync/p2p_packet.pb.dart';
import 'package:ydart/utils/encoding_utils.dart';

import '../doc_sync_service.dart';

class DocSyncServiceImpl implements DocSyncService {
  ServiceManager serviceManager;
  Map<String, int> queryDeltaTimeRecord = {};
  Map<String, int> downloadDocFileTimeRecord = {};
  Timer? _downloadTimer;

  final _downloadLock = <String, Object>{};

  DocSyncServiceImpl(this.serviceManager);

  @override
  void startDownloadTimer() {
    stopDownloadTimer();
    _downloadTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _downloadDocTask();
    });
    _downloadDocTask();
  }

  @override
  void stopDownloadTimer() {
    _downloadTimer?.cancel();
    _downloadTimer = null;
  }

  Future<void> _downloadDocTask() async {
    var updateList = await queryUpdateList();
    if (updateList == null || updateList.isEmpty) {
      return;
    }
    for (var update in updateList) {
      await downloadDocFile(update.dataId);
    }
    var updateTime = updateList
        .map((e) => e.updateTime)
        .reduce((value, element) => max(value, element));
    await writeDocUpdateTime(updateTime);
  }

  Future<int> readDocUpdateTime() async {
    return int.parse(await serviceManager.configManager.readConfig(
        "user.doc.updateTime.${serviceManager.userService.currentUser?.id}",
        '0'));
  }

  Future<void> writeDocUpdateTime(int time) async {
    await serviceManager.configManager.saveConfig(
        "user.doc.updateTime.${serviceManager.userService.currentUser?.id}",
        time.toString());
  }

  @override
  Future<List<UpdateDocStateInfo>?> queryUpdateList() async {
    var docUpdateTime = await readDocUpdateTime();
    var docApi = DocApi(
      baseUrl: serviceManager.userService.noteServerUrl ?? "",
      token: serviceManager.userService.token,
      clientId: serviceManager.userService.clientId.toString(),
      securityVersion:
          serviceManager.cryptService.getCurrentPassword()?.version,
    );
    return await docApi.queryUpdateList(docUpdateTime);
  }

  /// 接收文档编辑增量数据，将编辑器增量更新编码到本地
  @override
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

  @override
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
  @override
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

  @override
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
  @override
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

  @override
  Future<void> downloadDocFile(String docId, {Duration? timeout}) async {
    var doc = await serviceManager.docService.queryDoc(docId);
    if (doc?.type == null) {
      return;
    }
    var docDownloadLock = _downloadLock.putIfAbsent(docId, () => Object());
    return docDownloadLock.synchronizedWithLog(() async {
      var noteServerUrl = serviceManager.userService.noteServerUrl;
      if (noteServerUrl == null) {
        return;
      }
      var docApi = DocApi(
        baseUrl: noteServerUrl,
        token: serviceManager.userService.token,
        clientId: serviceManager.userService.clientId.toString(),
        securityVersion:
            serviceManager.cryptService.getCurrentPassword()?.version,
      );
      Response result;
      try {
        result = await docApi.downloadDoc(docId);
      } catch (e) {
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
        fileBytes = serviceManager.cryptService.decode(fileBytes);
        // 写入文件,并且通知upload
        try {
          // 更新文档，并且检测文档是否需要更新
          await serviceManager.editService.updateDocContent(
            docId,
            fileBytes,
          );
        } catch (e) {
          printLog("下载文档时，更新ydoc失败: $e");
        }
      }
    }, logTitle: "downloadDocFile", timeout: timeout);
  }

  @override
  Future<bool> uploadDocFile(String docId, {Duration? timeout}) async {
    var noteServerUrl = serviceManager.userService.noteServerUrl;
    if (noteServerUrl == null) {
      return false;
    }
    var docApi = DocApi(
      baseUrl: noteServerUrl,
      token: serviceManager.userService.token,
      clientId: serviceManager.userService.clientId.toString(),
      securityVersion:
          serviceManager.cryptService.getCurrentPassword()?.version,
    );
    var lockResult = await docApi.queryDocStateAndLock(docId);
    var serverDocState = lockResult?.docState;
    var doc = await serviceManager.editService.readDoc(docId);
    if (doc == null) {
      return false;
    }
    var docState = base64Encode(doc.encodeStateVectorV2());
    if (needDownload(docState, serverDocState)) {
      // 下载文档
      await downloadDocFile(docId);
      doc = await serviceManager.editService.readDoc(docId);
      if (doc == null) {
        return false;
      }
      docState = base64Encode(doc.encodeStateVectorV2());
    }
    var docContent = doc.encodeStateAsUpdateV2();
    docContent = serviceManager.cryptService.encode(docContent);
    await docApi.uploadDoc(docId, docState, docContent);
    return true;
  }

  bool needDownload(String docState, String? serverDocState) {
    if (serverDocState == null || serverDocState.isEmpty) {
      return false;
    }
    if (docState == serverDocState) {
      return false;
    }
    var localState = EncodingUtils.decodeStateVector(base64Decode(docState));
    var serverState =
        EncodingUtils.decodeStateVector(base64Decode(serverDocState));
    for (var value in serverState.entries) {
      if (!localState.containsKey(value.key)) {
        return true;
      }
      var i = localState[value.key];
      if (i == null || i < value.value) {
        return true;
      }
    }
    return false;
  }
}
