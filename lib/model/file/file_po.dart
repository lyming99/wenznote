import 'package:isar/isar.dart';

part 'file_po.g.dart';

@collection
class FilePO {
  Id id = Isar.autoIncrement;
  String? uuid;
  String? type;
  String? name;
  String? path;
  int? size;
  int? createTime;
  int? updateTime;

  FilePO({
    this.id = Isar.autoIncrement,
    this.uuid,
    this.type,
    this.name,
    this.path,
    this.size,
    this.createTime,
    this.updateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'uuid': this.uuid,
      'type': this.type,
      'name': this.name,
      'path': this.path,
      'size': this.size,
      'createTime': this.createTime,
      'updateTime': this.updateTime,
    };
  }

  factory FilePO.fromMap(Map<String, dynamic> map) {
    return FilePO(
      uuid: map['uuid'] as String?,
      type: map['type'] as String?,
      name: map['name'] as String?,
      path: map['path'] as String?,
      size: map['size'] as int?,
      createTime: map['createTime'] as int?,
      updateTime: map['updateTime'] as int?,
    );
  }
}
