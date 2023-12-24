import 'package:sqflite_common/sqlite_api.dart';

class StudyRecordPO {
  static String tableName = "wz_study_record_t";
  static String createSql = """
    create table wz_study_record_t
    (
        id integer primary key autoincrement,
        startTime  integer,
        endTime    integer,
        nextTime   integer,
        studyScore integer,
        createTime integer,
        type        varchar(64),
        remInfo     text,
        cardUuid   varchar(64)
    )
  """;
  int? id;
  int? startTime;
  int? endTime;
  int? nextTime;
  int? studyScore;
  int? createTime;
  String? type;
  String? cardUuid;
  String? remInfo;

  StudyRecordPO({
    this.id,
    this.startTime,
    this.endTime,
    this.nextTime,
    this.studyScore,
    this.createTime,
    this.type,
    this.cardUuid,
    this.remInfo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'startTime': this.startTime,
      'endTime': this.endTime,
      'nextTime': this.nextTime,
      'studyScore': this.studyScore,
      'createTime': this.createTime,
      'type': this.type,
      'cardUuid': this.cardUuid,
      'remInfo':this.remInfo,
    };
  }

  factory StudyRecordPO.fromMap(Map<String, dynamic> map) {
    return StudyRecordPO(
      id: map['id'] as int?,
      startTime: map['startTime'] as int?,
      endTime: map['endTime'] as int?,
      nextTime: map['nextTime'] as int?,
      studyScore: map['studyScore'] as int?,
      createTime: map['createTime'] as int?,
      type: map['type'] as String?,
      cardUuid: map['cardUuid'] as String?,
      remInfo: map['remInfo'] as String?,
    );
  }

  static Future<void> upgradeDb(Database db) async{
    // await db.execute("drop table ${tableName}");
    // await db.execute(createSql);
  }
}
