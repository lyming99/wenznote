import 'package:isar/isar.dart';

part 'file_link_po.g.dart';

@collection
class FileLinkPO {
  Id id = Isar.autoIncrement;
  String? fileId;
  String? dataId;
  String? type;
  int? createTime;
  int? updateTime;

  FileLinkPO({
    this.id = Isar.autoIncrement,
    this.fileId,
    this.dataId,
    this.type,
    this.createTime,
    this.updateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'fileId': this.fileId,
      'dataId': this.dataId,
      'type': this.type,
      'createTime': this.createTime,
      'updateTime': this.updateTime,
    };
  }

  factory FileLinkPO.fromMap(Map<String, dynamic> map) {
    return FileLinkPO(
      fileId: map['fileId'] as String?,
      dataId: map['dataId'] as String?,
      type: map['type'] as String?,
      createTime: map['createTime'] as int?,
      updateTime: map['updateTime'] as int?,
    );
  }
}
