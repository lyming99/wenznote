import 'package:sqflite_common/sqlite_api.dart';

class StudyPlanPO {
  static String tableName = "wz_study_plan_t";
  static String createSql = """
    create table wz_study_plan_t
    (
        id integer primary key autoincrement,
        cardSetUuid varcahr(64),
        cardUuid   varchar(64),
        type varchar(64),
        createTime integer,
        isOk integer
    )
  """;
  int? id;
  String? type;
  String? cardUuid;
  String? cardSetUuid;
  int? isOk;
  int? createTime;

  StudyPlanPO({
    this.id,
    this.type,
    this.cardUuid,
    this.cardSetUuid,
    this.createTime,
    this.isOk,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'type': this.type,
      'cardUuid': this.cardUuid,
      'cardSetUuid': this.cardSetUuid,
      'isOk': this.isOk,
      'createTime': this.createTime,
    };
  }

  factory StudyPlanPO.fromMap(Map<String, dynamic> map) {
    return StudyPlanPO(
      id: map['id'] as int?,
      type: map['type'] as String?,
      cardUuid: map['cardUuid'] as String?,
      cardSetUuid: map['cardSetUuid'] as String?,
      isOk: map['isOk'] as int?,
      createTime: map['createTime'] as int?,
    );
  }

  static Future<void> upgradeDb(Database db) async{}
}
