import 'package:sqflite_common/sqlite_api.dart';

class DocDirectoryPO {
  int? id;

  ///设备id
  String? did;

  ///路径
  String? path;

  ///文件夹id
  String? uuid;

  ///父节点id
  String? pid;

  ///标题
  String? title;

  ///排序
  int? orderIndex;

  ///创建时间
  int? createTime;

  ///更新时间
  int? updateTime;
  static String tableName = "wz_doc_directory_t";
  static String createSql = """
  create table wz_doc_directory_t (
  id integer primary key autoincrement,
  did varchar(64),
  uuid varchar(64),
  pid varchar(64),
  title varchar(1024),
  path text,
  createTime integer,
  updateTime integer,
  orderIndex integer,
  deleted integer
  )
  """;

  DocDirectoryPO({
    this.id,
    this.did,
    this.uuid,
    this.pid,
    this.title,
    this.path,
    this.orderIndex,
    this.createTime,
    this.updateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'did': this.did,
      'uuid': this.uuid,
      'pid': this.pid,
      'title': this.title,
      'path': this.path,
      'orderIndex': this.orderIndex,
      'createTime': this.createTime,
      'updateTime': this.updateTime,
    };
  }

  factory DocDirectoryPO.fromMap(Map<String, dynamic> map) {
    return DocDirectoryPO(
      id: map['id'] as int?,
      did: map['did'] as String?,
      uuid: map['uuid'] as String?,
      pid: map['pid'] as String?,
      title: map['title'] as String?,
      path: map['path'] as String?,
      orderIndex: map['orderIndex'] as int?,
      createTime: map['createTime'] as int?,
      updateTime: map['updateTime'] as int?,
    );
  }

  static Future<void> upgradeDb(Database db) async{}
}