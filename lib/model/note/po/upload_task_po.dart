import 'package:isar/isar.dart';

part 'upload_task_po.g.dart';

@collection
class UploadTaskPO {
  Id id = Isar.autoIncrement;
  String? dataId;
  String? type;
  int? planTime;
  bool? isDone;

  UploadTaskPO({
    this.id = Isar.autoIncrement,
    this.dataId,
    this.type,
    this.planTime,
  });
}
