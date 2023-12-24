import 'package:isar/isar.dart';

part 'card_study_score_po.g.dart';
@collection
class CardStudyScorePO {
  Id id;
  String? cardSetId;
  String? cardId;
  int? startTime;
  int? endTime;
  String? score;
  String? scoreInfo;

  String? uid;
  String? uuid;
  String? did;
  String? createBy;
  String? updateBy;
  int? createTime;
  int? updateTime;

  CardStudyScorePO({
    this.id = Isar.autoIncrement,
    this.cardSetId,
    this.cardId,
    this.startTime,
    this.endTime,
    this.score,
    this.scoreInfo,
    this.uid,
    this.uuid,
    this.did,
    this.createBy,
    this.updateBy,
    this.createTime,
    this.updateTime,
  });
}
