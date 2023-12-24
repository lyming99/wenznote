import 'package:sqflite_common/sqlite_api.dart';

class CardSetPO {
  int? id;

  ///预留字段：类型
  String? type;

  ///设备id
  String? did;

  ///文件id
  String? uuid;

  ///父节点id
  String? pid;

  ///标题
  String? title;

  ///摘要
  String? summary;

  ///版本创建时间
  int? createTime;

  ///更新时间
  int? updateTime;

  ///排序
  int? orderIndex;

  static String tableName = "wz_card_set_t";
  static String createSql = """
  create table wz_card_set_t (
  id integer primary key autoincrement,
  type varchar(64),
  did varchar(64),
  uuid varchar(64),
  pid varchar(64),
  title varchar(1024),
  summary text,
  createTime integer,
  updateTime integer,
  orderIndex integer,
  deleted integer
  )
  """;
  static String dropSql = """
    drop table $tableName
  """;

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'type': this.type,
      'did': this.did,
      'uuid': this.uuid,
      'pid': this.pid,
      'title': this.title,
      'summary': this.summary,
      'createTime': this.createTime,
      'updateTime': this.updateTime,
      'orderIndex': this.orderIndex,
    };
  }

  factory CardSetPO.fromMap(Map<String, dynamic> map) {
    return CardSetPO(
      id: map['id'] as int?,
      type: map['type'] as String?,
      did: map['did'] as String?,
      uuid: map['uuid'] as String?,
      pid: map['pid'] as String?,
      title: map['title'] as String?,
      summary: map['summary'] as String?,
      createTime: map['createTime'] as int?,
      updateTime: map['updateTime'] as int?,
      orderIndex: map['orderIndex'] as int?,
    );
  }

  CardSetPO({
    this.id,
    this.type,
    this.did,
    this.uuid,
    this.pid,
    this.title,
    this.summary,
    this.createTime,
    this.updateTime,
    this.orderIndex,
  });

  static Future<void> upgradeDb(Database db) async{}
}

class CardSetCountPO {
  int? todayReviewCount;
  int? todayReviewAllCount;
  int? todayStudyCount;
  int? todayStudyAllCount;
  int? allCount;
  int? studyCount;
  int? lastStudyTime;

  CardSetCountPO({
    this.todayReviewCount,
    this.todayReviewAllCount,
    this.todayStudyCount,
    this.todayStudyAllCount,
    this.allCount,
    this.studyCount,
    this.lastStudyTime,
  });
}
