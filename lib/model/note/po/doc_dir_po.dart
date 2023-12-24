import 'package:isar/isar.dart';

part 'doc_dir_po.g.dart';

@collection
class DocDirPO {
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

  DocDirPO({
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
    };
  }

  factory DocDirPO.fromMap(Map<String, dynamic> map) {
    return DocDirPO(
      uid: map['uid'],
      uuid: map['uuid'],
      did: map['did'],
      createBy: map['createBy'],
      updateBy: map['updateBy'],
      createTime: map['createTime'],
      updateTime: map['updateTime'],
      pid: map['pid'],
      name: map['name'],
    );
  }
}
