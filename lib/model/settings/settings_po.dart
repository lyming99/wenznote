import 'package:isar/isar.dart';

part 'settings_po.g.dart';

@collection
class SettingsPO {
  Id id = Isar.autoIncrement;
  String? uid;
  String? uuid;
  String? did;

  String? createBy;
  String? updateBy;
  int? createTime;
  int? updateTime;

  String? key;
  String? name;
  String? value;
  String? groupName;

  SettingsPO({
    this.id = Isar.autoIncrement,
    this.uid,
    this.uuid,
    this.did,
    this.createBy,
    this.updateBy,
    this.createTime,
    this.updateTime,
    this.key,
    this.name,
    this.groupName,
    this.value,
  });
}
