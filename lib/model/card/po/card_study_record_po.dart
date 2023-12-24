import 'package:isar/isar.dart';

part 'card_study_record_po.g.dart';

@collection
class CardStudyRecordPO {
  Id id;
  String? cardSetId;
  String? cardId;
  int? startTime;
  int? endTime;
  String? uid;
  String? uuid;
  String? did;
  String? createBy;
  String? updateBy;
  int? createTime;
  int? updateTime;
  int? nextStudyTime;
  int? score;
  String?fsrsRemInfo;
  CardStudyRecordPO({
    this.id = Isar.autoIncrement,
    this.cardSetId,
    this.cardId,
    this.startTime,
    this.endTime,
    this.uid,
    this.uuid,
    this.did,
    this.createBy,
    this.updateBy,
    this.createTime,
    this.updateTime,
    this.nextStudyTime,
    this.score,
    this.fsrsRemInfo,
  });
}
