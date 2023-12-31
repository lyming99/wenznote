import 'package:isar/isar.dart';

part 'doc_po.g.dart';

@collection
class DocPO {
  Id id = Isar.autoIncrement;
  String? uid;
  String? uuid;
  String? did;
  String? createBy;
  String? updateBy;
  int? createTime;
  int? updateTime;

  String? pid;
  String? name;
  String? type;
  String? content;

  DocPO({
    this.id = Isar.autoIncrement,
    this.uid,
    this.uuid,
    this.did,
    this.createBy,
    this.updateBy,
    this.createTime,
    this.updateTime,
    this.pid,
    this.name,
    this.type,
    this.content,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': this.uid,
      'uuid': this.uuid,
      'did': this.did,
      'createBy': this.createBy,
      'updateBy': this.updateBy,
      'createTime': this.createTime,
      'updateTime': this.updateTime,
      'pid': this.pid,
      'name': this.name,
      'type': this.type,
      'content': this.content,
    };
  }

  factory DocPO.fromMap(Map<String, dynamic> map) {
    return DocPO(
      uid: map['uid'] as String?,
      uuid: map['uuid'] as String?,
      did: map['did'] as String?,
      createBy: map['createBy'] as String?,
      updateBy: map['updateBy'] as String?,
      createTime: map['createTime'] as int?,
      updateTime: map['updateTime'] as int?,
      pid: map['pid'] as String?,
      name: map['name'] as String?,
      type: map['type'] as String?,
      content: map['content'] as String?,
    );
  }
}
