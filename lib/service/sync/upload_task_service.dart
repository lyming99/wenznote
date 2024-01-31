import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:isar/isar.dart';
import 'package:wenznote/config/app_constants.dart';
import 'package:wenznote/model/file/file_po.dart';
import 'package:wenznote/model/note/po/doc_state_po.dart';
import 'package:wenznote/model/note/po/upload_task_po.dart';
import 'package:wenznote/service/service_manager.dart';

class UploadTaskService {
  ServiceManager serviceManager;
  final Lock _uploadLock = Lock();
  Timer? _uploadTimer;

  UploadTaskService(this.serviceManager);

  void startUploadTimer() {
    stopUploadTimer();
    _uploadTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      doUpload();
    });
    doUpload();
  }

  void stopUploadTimer() {
    _uploadTimer?.cancel();
    _uploadTimer = null;
  }

  Future<void> uploadDoc(String docId, [int seconds = 20]) async {
    var planTime = DateTime.now().millisecondsSinceEpoch + seconds * 000 - 100;
    var task =
        await isar.uploadTaskPOs.filter().dataIdEqualTo(docId).findFirst();
    task ??= UploadTaskPO(dataId: docId, type: "note", planTime: planTime);
    task.planTime = planTime;
    task.isDone = false;
    await isar.writeTxn(() => isar.uploadTaskPOs.put(task!));
    Timer(Duration(seconds: seconds), () {
      doUpload();
    });
  }

  Future<void> uploadFile(String fileId, [int seconds = 1]) async {
    var planTime = DateTime.now().millisecondsSinceEpoch + seconds * 000 - 100;
    var task =
        await isar.uploadTaskPOs.filter().dataIdEqualTo(fileId).findFirst();
    task ??= UploadTaskPO(dataId: fileId, type: "file", planTime: planTime);
    task.planTime = planTime;
    task.isDone = false;
    await isar.writeTxn(() => isar.uploadTaskPOs.put(task!));
    Timer(Duration(seconds: seconds), () {
      doUpload();
    });
  }

  Isar get isar => serviceManager.isarService.documentIsar;

  Future<void> doUpload() async {
    _uploadLock.lock();
    try {
      // 查询
      var tasks = await isar.uploadTaskPOs
          .filter()
          .planTimeLessThan(DateTime.now().millisecondsSinceEpoch)
          .and()
          .isDoneEqualTo(false)
          .findAll();
      for (var task in tasks) {
        try {
          if (await doUploadTask(task)) {
            task.isDone = true;
            await isar.writeTxn(() => isar.uploadTaskPOs.put(task));
          }
        } catch (e) {
          print(e);
        }
      }
    } finally {
      _uploadLock.unlock();
    }
  }

  Future<bool> doUploadTask(UploadTaskPO task) async {
    switch (task.type) {
      case "doc":
      case "note":
        return await doUploadNote(task);
      case "file":
        return await doUploadFile(task);
    }
    return false;
  }

  /// 上传文件
  Future<bool> doUploadFile(UploadTaskPO task) async {
    // 1.读取文件
    // 2.读取token
    // 3.读取noteserver
    // 4.上传
    var token = serviceManager.userService.token;
    var noteServer = serviceManager.recordSyncService.noteServerUrl;
    if (token == null) {
      return false;
    }
    var dataId = task.dataId;
    var filePO = await isar.filePOs.filter().uuidEqualTo(dataId).findFirst();
    if (filePO == null) {
      return false;
    }
    var filepath =
        await serviceManager.fileManager.getFilePath(dataId, filePO.name);
    if (File(filepath).existsSync()) {
      var resp = await Dio().post(
        "$noteServer/file/upload/$dataId",
        options: Options(
          headers: {"token": token, "Content-Type": "multipart/form-data;"},
          responseType: ResponseType.json,
        ),
        data: FormData.fromMap({
          "file": await MultipartFile.fromFile(filepath, filename: filePO.name),
        }),
      );
      if (resp.data['msg'] == AppConstants.success) {
        return true;
      }
    }
    return false;
  }

  /// 上传笔记快照
  Future<bool> doUploadNote(UploadTaskPO task) async {
    try {
      var token = serviceManager.userService.token;
      if (token == null) {
        return false;
      }
      var docId = task.dataId;
      // 1.读取文件
      // 2.读取state
      // 3.上传文件
      var data = await serviceManager.editService.readDocFile(docId);
      if (data == null) {
        return false;
      }
      var noteServerUrl = serviceManager.recordSyncService.noteServerUrl;
      var states =
          await isar.docStatePOs.filter().docIdEqualTo(docId).findAll();
      Map<String, int> state = getClientStates(states);
      var result = await Dio().post(
        "$noteServerUrl/snapshot/upload/$docId",
        options: Options(
          headers: {
            "token": serviceManager.userService.token,
            "Content-Type": "multipart/form-data;"
          },
          responseType: ResponseType.json,
        ),
        data: FormData.fromMap({
          "state": jsonEncode(state),
          "file": MultipartFile.fromBytes(
              serviceManager.cryptService.encode(data),
              filename: "doc.wnote"),
        }),
      );
      if (result.statusCode != 200) {
        return false;
      }
      if (result.data['msg'] == AppConstants.success) {
        return true;
      }
      // 查询差异数据，或者先下载数据
      serviceManager.docSnapshotService.downloadDocFile(docId!);
    } catch (e) {
      print(e);
    }
    return false;
  }

  Map<String, int> getClientStates(List<DocStatePO> states) {
    Map<String, int> clients = {};
    for (var value in states) {
      var clientId = value.clientId?.toString();
      var time = value.updateTime;
      if (clientId == null || time == null) {
        continue;
      }
      if (clients.containsKey(clientId)) {
        clients[clientId] = max(clients[clientId]!, time);
      } else {
        clients[clientId] = time;
      }
    }
    return clients;
  }
}
