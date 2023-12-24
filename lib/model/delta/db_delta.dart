import 'package:isar/isar.dart';

part 'db_delta.g.dart';

@collection
class DbDelta {
  Id id = Isar.autoIncrement;
  int? clientId;
  String? dataType;
  String? dataId;
  String? content;
  int? updateTime;
  bool? deleted;
  bool? hasUpload;
}
