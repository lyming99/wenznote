import 'package:sqflite_common/sqlite_api.dart';

class ReadRecordPO {
  static String tableName = "wz_read_record_t";
  static String createSql = """
    create table wz_read_record_t
    (
        id integer primary key autoincrement,
        startTime  integer,
        endTime    integer,
        createTime integer,
        type        varchar(64),
        cardUuid   varchar(64)
    )
  """;
  int? id;
  int? startTime;
  int? endTime;
  int? createTime;
  String? type;
  String? cardUuid;

  ReadRecordPO({
    this.id,
    this.startTime,
    this.endTime,
    this.createTime,
    this.type,
    this.cardUuid,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'startTime': this.startTime,
      'endTime': this.endTime,
      'createTime': this.createTime,
      'type': this.type,
      'cardUuid': this.cardUuid,
    };
  }

  factory ReadRecordPO.fromMap(Map<String, dynamic> map) {
    return ReadRecordPO(
      id: map['id'] as int?,
      startTime: map['startTime'] as int?,
      endTime: map['endTime'] as int?,
      createTime: map['createTime'] as int?,
      type: map['type'] as String?,
      cardUuid: map['cardUuid'] as String?,
    );
  }

  static Future<void> upgradeDb(Database db) async{}
}
