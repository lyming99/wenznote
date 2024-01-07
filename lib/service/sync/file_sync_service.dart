import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:note/commons/util/file_utils.dart';
import 'package:note/config/app_constants.dart';
import 'package:note/model/file/file_po.dart';
import 'package:note/service/isar/isar_service_mixin.dart';
import 'package:note/service/service_manager.dart';

class FileSyncService with IsarServiceMixin {
  @override
  ServiceManager serviceManager;

  FileSyncService(this.serviceManager);

  Future<FilePO?> getFile(String? id) async {
    var file = await documentIsar.filePOs.filter().uuidEqualTo(id).findFirst();
    if (file != null) {
      return file;
    }
    await 1.seconds.delay();
    // 查询文件信息并且下载
    for (var i = 0; i < 20; i++) {
      var res = await queryAndDownloadFile(id);
      if (res != null) {
        return res;
      }
      await 2.seconds.delay();
    }
    return null;
  }

  Future<FilePO?> createAndUploadFile({
    required String uuid,
    required String name,
    required String path,
    required String type,
    required int size,
  }) async {
    // 1.创建文件
    var filePO = FilePO(
        type: type,
        uuid: uuid,
        path: path,
        name: name,
        createTime: DateTime.now().millisecondsSinceEpoch);
    await documentIsar.writeTxn(() => documentIsar.filePOs.put(filePO));
    // 3.创建同步任务
    await serviceManager.uploadTaskService.uploadFile(uuid);
    return filePO;
  }

  Future<void> downloadFile(String? fileId, String savePath) async {
    if (fileId == null) {
      return;
    }
    var token = serviceManager.userService.token;
    if (token == null) {
      return;
    }
    var noteServer = serviceManager.recordSyncService.noteServerUrl;
    try {
      await Dio().download("$noteServer/file/download/$fileId", savePath,
          options: Options(
            headers: {
              "token": token,
            },
            method: "post",
          ));
    } catch (e) {
      print(e);
    }
  }

  Future<FilePO?> queryAndDownloadFile(String? fileId) async {
    if (fileId == null) {
      return null;
    }
    var token = serviceManager.userService.token;
    if (token == null) {
      return null;
    }
    var noteServer = serviceManager.recordSyncService.noteServerUrl;
    try {
      var result = await Dio().post(
        "$noteServer/file/queryFileInfo/$fileId",
        options: Options(
          headers: {
            "token": token,
          },
          responseType: ResponseType.json,
        ),
      );
      if (result.data['msg'] == AppConstants.success) {
        var data = result.data['data'];
        var filename = data['filename'];
        var fileId = data['id'];
        var size = data['size'];
        var savePath = await serviceManager.fileManager.getFilePath(
          fileId,
          filename,
          download: false,
        );
        await downloadFile(fileId, savePath);
        var filePO = FilePO(
            type: getFileType(filename),
            uuid: fileId,
            path: filename,
            size: size,
            name: filename,
            createTime: DateTime.now().millisecondsSinceEpoch);
        await documentIsar.writeTxn(() => documentIsar.filePOs.put(filePO));
        return filePO;
      }
    } catch (e) {
      print(e);
    }
    return null;
  }
}
