import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:isar/isar.dart';
import 'package:wenznote/commons/util/mehod_time_record.dart';
import 'package:wenznote/config/app_constants.dart';
import 'package:wenznote/model/file/file_po.dart';
import 'package:wenznote/model/note/po/doc_state_po.dart';
import 'package:wenznote/model/note/po/upload_task_po.dart';
import 'package:wenznote/service/service_manager.dart';

import '../../commons/util/log_util.dart';

/// 上传定时任务间隔设置为10分钟，每10分钟都会再次执行上传失败的任务
const uploadTimerMinutes = 10;

class DocState {
  int? id;
  String? dataId;
  String? docState;
  int? updateTime;

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'dataId': this.dataId,
      'docState': this.docState,
      'updateTime': this.updateTime,
    };
  }

  factory DocState.fromMap(Map<String, dynamic> map) {
    return DocState(
      id: map['id'] as int,
      dataId: map['dataId'] as String,
      docState: map['docState'] as String,
      updateTime: map['updateTime'] as int,
    );
  }

  DocState({
    this.id,
    this.dataId,
    this.docState,
    this.updateTime,
  });
}

class UploadTaskService {
  ServiceManager serviceManager;
  Timer? _uploadTimer;
  final _uploadNoteLock = Object();
  final _uploadFileLock = Object();
  bool _taskDoing = false;

  UploadTaskService(this.serviceManager);

  Isar get isar => serviceManager.isarService.documentIsar;

  void startUploadTimer() {
    stopUploadTimer();
    _uploadTimer =
        Timer.periodic(const Duration(minutes: uploadTimerMinutes), (timer) {
      doUpload();
    });
    // 启动马上上传
    doUploadFirst();
  }

  void doUploadFirst() async {
    try {
      var uploadConfigKey = "first.upload1.${serviceManager.userService.uid}";
      var result =
          await serviceManager.configManager.readConfig(uploadConfigKey, "");
      if (result == "ok") {
        return;
      }
      var docList = await serviceManager.docService.queryDocAndNoteList();
      for (var doc in docList.where((element) => element.uuid != null)) {
        await uploadDoc(doc.uuid!);
      }
      serviceManager.configManager.saveConfig(uploadConfigKey, "ok");
    } finally {
      doUpload();
    }
  }

  void stopUploadTimer() {
    _uploadTimer?.cancel();
    _uploadTimer = null;
  }

  Future<void> uploadDoc(String docId, [int seconds = 20]) async {
    var planTime = DateTime.now().millisecondsSinceEpoch + seconds * 000 - 1;
    var task =
        await isar.uploadTaskPOs.filter().dataIdEqualTo(docId).findFirst();
    task ??= UploadTaskPO(dataId: docId, type: "note", planTime: planTime);
    task.planTime = planTime;
    task.isDone = false;
    await isar.writeTxn(() async {
      await isar.uploadTaskPOs.put(task!);
    });
    if (seconds <= 0) {
      doUploadSingle(docId);
    } else {
      Timer(Duration(seconds: seconds), () {
        doUploadSingle(docId);
      });
    }
  }

  Future<void> uploadFile(String fileId, [int seconds = 1]) async {
    var planTime = DateTime.now().millisecondsSinceEpoch + seconds * 000 - 1;
    var task =
        await isar.uploadTaskPOs.filter().dataIdEqualTo(fileId).findFirst();
    task ??= UploadTaskPO(dataId: fileId, type: "file", planTime: planTime);
    task.planTime = planTime;
    task.isDone = false;
    await isar.writeTxn(() async {
      await isar.uploadTaskPOs.put(task!);
    });
    Timer(Duration(seconds: seconds), () async {
      doUploadSingle(fileId);
    });
  }

  Future<void> doUploadSingle(String dataId) async {
    // 查询
    var task = await isar.uploadTaskPOs
        .filter()
        .dataIdEqualTo(dataId)
        .isDoneEqualTo(false)
        .findFirst();
    if (task != null) {
      _doUploadTask(task);
    }
  }

  Future<void> doUpload() async {
    if (_taskDoing) {
      return;
    }
    try {
      _taskDoing = true;
      var tasks = await isar.uploadTaskPOs
          .filter()
          .planTimeLessThan(DateTime.now().millisecondsSinceEpoch)
          .and()
          .isDoneEqualTo(false)
          .findAll();
      for (var task in tasks) {
        try {
          if (await _doUploadTask(task)) {
            task.isDone = true;
            await isar.writeTxn(() async {
              await isar.uploadTaskPOs.put(task);
            });
          }
        } catch (e) {
          printLog("上传任务失败, error: $e");
        }
      }
    } finally {
      _taskDoing = false;
    }
  }

  Future<bool> _doUploadTask(UploadTaskPO task) async {
    switch (task.type) {
      case "doc":
      case "note":
        return await _uploadNoteLock.synchronizedWithLog(
            () => _doUploadNote(task),
            logTitle: "doUploadNote");
      case "file":
        return await _uploadFileLock.synchronizedWithLog(
            () => _doUploadFile(task),
            logTitle: "doUploadFile");
    }
    return false;
  }

  /// 上传文件
  Future<bool> _doUploadFile(UploadTaskPO task) async {
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
      if (File(filepath).lengthSync() > 10 * 1000 * 1000) {
        return false;
      }
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

  Future<DocState?> _queryDocState(String docId) async {
    var noteServerUrl = serviceManager.recordSyncService.noteServerUrl;
    if (noteServerUrl == null) {
      return null;
    }
    var result = await Dio().post(
      "$noteServerUrl/doc/queryDocState/$docId",
      options: Options(
        headers: {
          "token": serviceManager.userService.token,
        },
        responseType: ResponseType.json,
      ),
    );
    if (result.statusCode != 200) {
      return null;
    }
    if (result.data['msg'] == AppConstants.success) {
      var json = result.data['data'];
      if (json != null) {
        return DocState.fromMap(json);
      }
    }
    return null;
  }

  /// 上传笔记快照
  Future<bool> _doUploadNote(UploadTaskPO task) async {
    try {
      var token = serviceManager.userService.token;
      if (token == null || token.isEmpty) {
        return false;
      }
      var docId = task.dataId;
      // 1.读取文件
      // 2.读取state
      // 3.上传文件
      var doc = await serviceManager.editService.readDoc(docId);
      if (docId == null || doc == null) {
        return false;
      }
      var docState = await _queryDocState(docId);
      Uint8List? uploadBytes;
      if (docState != null) {
        var state = docState.docState;
        if (state != null) {
          var vector = base64Decode(state);
          uploadBytes = doc.encodeStateAsUpdateV2(vector);
        }
      }
      uploadBytes ??= doc.encodeStateAsUpdateV2();
      var noteServerUrl = serviceManager.recordSyncService.noteServerUrl;
      var result = await Dio().post(
        "$noteServerUrl/doc/uploadDoc/$docId",
        options: Options(
          headers: {
            "token": serviceManager.userService.token,
            "Content-Type": "multipart/form-data;"
          },
          responseType: ResponseType.json,
        ),
        data: FormData.fromMap({
          "file": MultipartFile.fromBytes(
              serviceManager.cryptService.encode(uploadBytes),
              filename: "doc.wnote"),
        }),
      );
      if (result.statusCode != 200) {
        return false;
      }
      if (result.data['msg'] == AppConstants.success) {
        return true;
      }
      // 版本较旧导致更新失败，放弃这次上传？
    } catch (e) {
      printLog("上传笔记任务失败, error: $e");
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
