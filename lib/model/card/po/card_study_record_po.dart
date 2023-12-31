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

  Map<String, dynamic> toMap() {
    return {
      'cardSetId': this.cardSetId,
      'cardId': this.cardId,
      'startTime': this.startTime,
      'endTime': this.endTime,
      'uid': this.uid,
      'uuid': this.uuid,
      'did': this.did,
      'createBy': this.createBy,
      'updateBy': this.updateBy,
      'createTime': this.createTime,
      'updateTime': this.updateTime,
      'nextStudyTime': this.nextStudyTime,
      'score': this.score,
      'fsrsRemInfo': this.fsrsRemInfo,
    };
  }

  factory CardStudyRecordPO.fromMap(Map<String, dynamic> map) {
    return CardStudyRecordPO(
      cardSetId: map['cardSetId'] as String?,
      cardId: map['cardId'] as String?,
      startTime: map['startTime'] as int?,
      endTime: map['endTime'] as int?,
      uid: map['uid'] as String?,
      uuid: map['uuid'] as String?,
      did: map['did'] as String?,
      createBy: map['createBy'] as String?,
      updateBy: map['updateBy'] as String?,
      createTime: map['createTime'] as int?,
      updateTime: map['updateTime'] as int?,
      nextStudyTime: map['nextStudyTime'] as int?,
      score: map['score'] as int?,
      fsrsRemInfo: map['fsrsRemInfo'] as String?,
    );
  }
}
