import 'dart:async';

import 'package:wenznote/service/sync/p2p_packet.pb.dart';

import '../api/doc_api.dart';

abstract class DocSyncService {
  void startDownloadTimer();

  void stopDownloadTimer();

  /// 查询需要更新的列表，可以通过本地的文档数据的时间戳查询服务器的最新文档列表
  Future<List<UpdateDocStateInfo>?> queryUpdateList();

  /// 接收文档编辑增量数据，将编辑器增量更新编码到本地
  Future<void> receiveDocEditEvent(P2pPacket pkt);

  Future<void> queryDocDelta(P2pPacket pkt);

  /// 与 receiveDocEditEvent 相同，接收文档增量数据
  Future<void> receiveDocDelta(P2pPacket pkt);

  Future<void> verifyDoc(List<String> docList);

  /// 接收下载文档指令
  Future<void> downloadDoc(P2pPacket pkt);

  Future<void> downloadDocFile(String docId, {Duration? timeout});

  Future<bool> uploadDocFile(String docId, {Duration? timeout});

}
