import 'package:isar/isar.dart';
part 'card_study_queue_po.g.dart';
@collection
class CardStudyQueuePO {
  Id id;
  String? cardSetId;
  String? cardId;
  bool? hasStudy;

  String? uid;
  String? uuid;
  String? did;
  String? createBy;
  String? updateBy;
  int? createTime;
  int? updateTime;
  int? orderIndex;

  CardStudyQueuePO({
    this.id = Isar.autoIncrement,
    this.cardSetId,
    this.cardId,
    this.hasStudy,
    this.uid,
    this.uuid,
    this.did,
    this.createBy,
    this.updateBy,
    this.createTime,
    this.updateTime,
    this.orderIndex,
  });
}
