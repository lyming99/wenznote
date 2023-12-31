import 'package:note/service/service_manager.dart';
import 'package:note/service/sync/p2p_packet.pb.dart';

class DocSnapshotService {
  ServiceManager serviceManager;

  DocSnapshotService(this.serviceManager);

  Future<void> receiveDocEditEvent(P2pPacket pkt) async {}

  Future<void> downloadDoc(P2pPacket pkt) async {}

  Future<void> queryDocDelta(P2pPacket pkt) async {}

  Future<void> receiveDocDelta(P2pPacket pkt) async {}

  Future<void> queryDocState(P2pPacket pkt) async {}

  Future<void> receiveDocState(P2pPacket pkt) async {}
}
