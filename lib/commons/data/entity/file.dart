
import 'package:sqflite_common/sqlite_api.dart';

///文件id
class FilePO {
  int? id;
  String? type;
  String? uuid;
  String? docId;
  String? path;
  String? name;
  int? createTime;
  static String tableName = "wz_file_t";
  static String createSql = """
  create table wz_file_t(
  id integer primary key autoincrement,
  type varchar(64),
  uuid varchar(64),
  docId varchar(64),
  path text, 
  name varchar(1024),
  createTime integer
  )
  """;

  FilePO({
    this.id,
    this.type,
    this.uuid,
    this.docId,
    this.path,
    this.name,
    this.createTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'type': this.type,
      'uuid': this.uuid,
      'docId': this.docId,
      'path': this.path,
      'name': this.name,
      'createTime': this.createTime,
    };
  }

  factory FilePO.fromMap(Map<String, dynamic> map) {
    return FilePO(
      id: map['id'] as int?,
      type: map['type'] as String?,
      uuid: map['uuid'] as String?,
      docId: map['docId'] as String?,
      path: map['path'] as String?,
      name: map['name'] as String?,
      createTime: map['createTime'] as int?,
    );
  }

  static Future<void> upgradeDb(Database db) async{}
}