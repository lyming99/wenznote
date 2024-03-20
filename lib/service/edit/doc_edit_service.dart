import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:wenznote/commons/util/mehod_time_record.dart';
import 'package:wenznote/editor/crdt/YsText.dart';
import 'package:wenznote/editor/crdt/doc_utils.dart';
import 'package:wenznote/model/note/po/doc_po.dart';
import 'package:wenznote/model/note/po/doc_state_po.dart';
import 'package:wenznote/service/service_manager.dart';
import 'package:ydart/ydart.dart';

import '../../commons/util/log_util.dart';

const checkDocSwitch = false;

/// 读取数据 = 读取全量数据(离线)+读取合并数据(用户)+增量数据(用户)
/// 写入数据 = 写入全量数据+写入增量数据
/// 每500个增量合并一次
class DocEditService {
  ServiceManager serviceManager;

  DocEditService(this.serviceManager);

  final _docCache = <String, YDoc>{};
  final _docLock = <String, Object>{};
  final _openedDocList = <String>{};

  void openDocEditor(String id) {
    _openedDocList.add(id);
  }

  void closeDocEditor(String id) {
    _openedDocList.remove(id);
  }

  bool hasOpenDocEditor(String id) {
    return _openedDocList.contains(id);
  }

  Future<Uint8List?> readDocBytes(String? docId) async {
    if (docId == null || docId.isEmpty) {
      return null;
    }
    var noteFile =
        File(await serviceManager.fileManager.getNoteFilePath(docId));
    if (noteFile.existsSync()) {
      var result = await noteFile.readAsBytes();
      return result;
    }
    return null;
  }

  Future<void> writeDocBytes(String? docId, Uint8List data) async {
    if (docId == null || docId.isEmpty) {
      return;
    }
    var noteFile =
        File(await serviceManager.fileManager.getNoteFilePath(docId));
    await noteFile.writeAsBytes(data);
    printLog("writeDocBytes: $noteFile");
  }

  Future<YDoc?> readDoc(String? docId) async {
    if (docId == null) {
      return null;
    }
    var doc = _docCache[docId];
    if (doc != null) {
      return doc;
    }
    try {
      var path = await serviceManager.fileManager.getNoteFilePath(docId);
      var result = YDoc()..clientId = serviceManager.userService.clientId;
      result.applyUpdateV2(File(path).readAsBytesSync());
      FragmentDocFile(path: "$path.bak").readDoc(result);
      _docCache[docId] = result;
      return result;
    } catch (e, stack) {
      return null;
    }
  }

  Object getDocLock(String docId) {
    _docLock[docId] ??= Object();
    return _docLock[docId]!;
  }

  Future<void> writeDoc(
    String? docId,
    YDoc doc, {
    bool needUpload = true,
    bool uploadNow = false,
  }) async {
    if (docId == null) {
      return;
    }
    await getDocLock(docId).synchronizedWithLog(
      () async {
        printLog(
            "write doc [$docId] need upload:[$needUpload] uploadNow:[$uploadNow]");
        var bytes = await withLog(() => doc.encodeStateAsUpdateV2(),
            logTitle: "encode");
        _docCache[docId] = doc;
        // 校验文档数据
        if (checkDocSwitch) {
          var checkDoc = YDoc();
          checkDoc.applyUpdateV2(bytes);
          if (doc.getArray("blocks").length !=
              checkDoc.getArray("blocks").length) {
            printLog("文件写入失败，文件格式损坏");
            return;
          }
        }
        await writeDocBytes(docId, bytes);
        // 更新doc state
        var isar = serviceManager.isarService.documentIsar;
        var clientId = serviceManager.userService.clientId;
        var state = await isar.docStatePOs
            .filter()
            .docIdEqualTo(docId)
            .clientIdEqualTo(clientId)
            .findFirst();
        state ??= DocStatePO(docId: docId, clientId: clientId);
        state.updateTime = DateTime.now().millisecondsSinceEpoch;
        await isar.writeTxn(() async {
          await isar.docStatePOs.put(state!);
        });
        // 增加上传快照任务
        if (needUpload) {
          if (uploadNow) {
            serviceManager.uploadTaskService.uploadDoc(docId, 0);
          } else {
            serviceManager.uploadTaskService.uploadDoc(docId);
          }
        }
      },
      logTitle: "writeDoc: $docId",
    );
  }

  /// 收到数据，或者下载数据时，会促发这个方法
  /// 需要通知界面刷新具体的数据
  Future<bool> updateDocContent(
    String docId,
    Uint8List delta,
  ) async {
    if (delta.isEmpty) {
      return false;
    }
    // 提出问题，这个方法能否在 on update 里面直接调用？
    return getDocLock(docId).synchronizedWithLog(
      () async {
        try {
          // 1.更新到编辑器
          var doc = await readDoc(docId);
          var oldDocLength = -1;
          if (doc != null) {
            // 将此次更新设置位不需要上传变化，也不需要写到文件
            try {
              doc.applyUpdateV2(delta);
            } catch (e) {
              printLog("更新doc失败, applyUpdateV2 error: $e");
            }
            oldDocLength = doc.getArray("blocks").length;
          } else {
            doc = YDoc();
            doc.clientId = serviceManager.userService.clientId;
            doc.applyUpdateV2(delta);
          }
          // 2.写到文件
          var oldBytes = delta;
          var newBytes = doc.encodeStateAsUpdateV2();
          // 校验文档数据
          if (checkDocSwitch) {
            var checkDoc = YDoc();
            checkDoc.applyUpdateV2(newBytes);
            if (oldDocLength != checkDoc.getArray("blocks").length) {
              printLog("文件写入失败，文件格式损坏");
              return false;
            }
          }
          await writeDocBytes(docId, newBytes);
          // 3.上传到服务器(20秒后)
          await serviceManager.uploadTaskService.uploadDoc(docId);
          return !_equalsBytes(newBytes, oldBytes);
        } catch (e) {
          printLog("合并doc失败, error: $e");
          return false;
        }
      },
      logTitle: "updateDocContent: $docId",
    );
  }

  Future<void> deleteDocFile(String docId) async {
    _docCache.remove(docId);
    var path = await serviceManager.fileManager.getNoteFilePath(docId);
    try {
      File(path).deleteSync();
    } catch (e) {
      e.printError();
    }
  }

  String readDocToJson(Uint8List data) {
    var doc = YDoc();
    doc.applyUpdateV2(data);
    return jsonEncode(doc.toJson());
  }

  Future<YDoc> readJsonDoc(String? content) async {
    return jsonToYDoc(serviceManager.userService.clientId, content);
  }

  bool _equalsBytes(Uint8List a, Uint8List b) {
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }

  Future<YDoc> createYDoc(DocPO info) async {
    var doc = YDoc();
    doc.clientId = serviceManager.userService.clientId;
    var blocks = doc.getArray("blocks");
    blocks.insert(0, [createEmptyTextYMap()]);
    await writeDoc(info.uuid, doc, uploadNow: true);
    return doc;
  }

  Future<Uint8List?> queryDocDelta(String dataId, List<int> content) async {
    var doc = await readDoc(dataId);
    if (doc == null) {
      return null;
    }
    return doc.encodeStateAsUpdateV2(Uint8List.fromList(content));
  }

  Future<Uint8List?> queryDocSnap(String docId) async {
    var doc = await readDoc(docId);
    if (doc == null) {
      return null;
    }
    return doc.encodeStateVectorV2();
  }
}
