import 'package:isar/isar.dart';
import 'package:json_diff/json_diff.dart';
import 'package:note/service/service_manager.dart';

mixin IsarServiceMixin {
  ServiceManager get serviceManager;

  Isar get documentIsar => serviceManager.isarService.documentIsar;

  Map<String, dynamic> diffMap(Object oldItem, Object newItem) {
    var differ = JsonDiffer.fromJson(oldItem, newItem);
    var diff = differ.diff();
    var map = <String, dynamic>{};
    for (var entry in diff.added.entries) {
      map[entry.key.toString()] = entry.value;
    }
    for (var entry in diff.changed.entries) {
      map[entry.key.toString()] = entry.value[1];
    }
    for (var entry in diff.removed.entries) {
      map[entry.key.toString()] = null;
    }
    return map;
  }

  Future<void> upsertDbDelta({
    required String dataId,
    required String dataType,
    required Map<String, dynamic> properties,
    bool uploadNow = true,
  }) async {
    await serviceManager.recordSyncService.putDbDelta(
      dataId: dataId,
      dataType: dataType,
      properties: properties,
      uploadNow: uploadNow,
    );
  }

  Future<void> upsertDbDeltas({
    required String dataType,
    required List<Map<String, dynamic>> objList,
    bool uploadNow = true,
  }) async {
    await serviceManager.recordSyncService.putDbDeltas(
      dataType: dataType,
      objList: objList,
      uploadNow: uploadNow,
    );
  }

  Future<void> deleteDbDelta(
    List<String?> dataIdList,
  ) async {
    await serviceManager.recordSyncService.removeDbDelta(
        dataIdList.where((element) => element != null).map((e) => e!).toList());
  }
}
