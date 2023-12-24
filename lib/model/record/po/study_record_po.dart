import 'package:isar/isar.dart';
part 'study_record_po.g.dart';
@collection
class StudyRecordPO {
  Id id = Isar.autoIncrement;
  String? uid;
  String? uuid;
  String? did;

  String? createBy;
  String? updateBy;
  int? createTime;
  int? updateTime;

  int? startTime;
  int? endTime;
  int? nextTime;
  int? studyScore;
  String? type;
  String? cardSetId;
  String? cardId;
  String? remInfo;

  StudyRecordPO({
    this.id = Isar.autoIncrement,
    this.uid,
    this.uuid,
    this.did,
    this.createBy,
    this.updateBy,
    this.createTime,
    this.updateTime,
    this.startTime,
    this.endTime,
    this.nextTime,
    this.studyScore,
    this.type,
    this.cardSetId,
    this.cardId,
    this.remInfo,
  });
}
