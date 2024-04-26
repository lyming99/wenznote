import '../isar/isar_service_mixin.dart';

abstract class RecordSyncService with IsarServiceMixin {
  String? get noteServerUrl;

  bool get hasNoteServer;

  void startPullTimer();

  void stopPullTimer();

  Future<void> pullDbData({bool pullAll = false, List<String>? dataIdList});

  Future<void> putDbDelta({
    required String dataId,
    required String dataType,
    required Map<String, Object?> properties,
    bool uploadNow = true,
  });

  Future<void> putDbDeltas({
    required String dataType,
    required List<Map<String, Object?>> objList,
    bool uploadNow = true,
  });

  Future<void> removeDbDelta(List<String> dataIdList);

  Future<void> reUploadDbData();
}
