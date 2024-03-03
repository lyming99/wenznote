import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_crdt/flutter_crdt.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:synchronized/extension.dart';
import 'package:wenznote/editor/crdt/YsText.dart';
import 'package:wenznote/editor/crdt/doc_utils.dart';
import 'package:wenznote/model/note/po/doc_po.dart';
import 'package:wenznote/model/note/po/doc_state_po.dart';
import 'package:wenznote/service/service_manager.dart';

import '../../commons/util/log_util.dart';

/// 读取数据 = 读取全量数据(离线)+读取合并数据(用户)+增量数据(用户)
/// 写入数据 = 写入全量数据+写入增量数据
/// 每500个增量合并一次
class DocEditService {
  ServiceManager serviceManager;

  DocEditService(this.serviceManager);

  final _fileCache = <String, Uint8List>{};
  final _docCache = <String, Doc>{};
  final _updateLock = Lock();
  final _openedDocList = <String>{};
  final _docUserEditMap = <String, bool>{};

  void openDocEditor(String id) {
    _openedDocList.add(id);
  }

  void closeDocEditor(String id) {
    _openedDocList.remove(id);
  }

  bool hasOpenDocEditor(String id) {
    return _openedDocList.contains(id);
  }

  bool isNotEditUpdate(String docId) {
    return _docUserEditMap[docId] ?? false;
  }

  void setNotEditUpdate(String docId, bool? state) {
    if (state == null) {
      _docUserEditMap.remove(docId);
      return;
    }
    _docUserEditMap[docId] = state;
  }

  Future<Uint8List?> readDocBytes(String? docId) async {
    if (docId == null || docId.isEmpty) {
      return null;
    }
    var item = _fileCache[docId];
    if (item != null) {
      return item;
    }
    var noteFile =
        File(await serviceManager.fileManager.getNoteFilePath(docId));
    if (noteFile.existsSync()) {
      var result = await noteFile.readAsBytes();
      _fileCache[docId] = result;
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
    _fileCache[docId] = data;
  }

  Future<Doc?> readDoc(String? docId) async {
    if (docId == null) {
      return null;
    }
    var doc = _docCache[docId];
    if (doc != null) {
      return doc;
    }
    // 如何将读取耗时控制在一定范围内？
    var bytes = await readDocBytes(docId);
    if (bytes == null) {
      // 读取失败，应该触发1秒后从服务器下载文档数据
      serviceManager.docSnapshotService.downloadDocFile(docId);
      return null;
    }
    try {
      Doc result = Doc()..clientID = serviceManager.userService.clientId;
      try {
        applyUpdateV2(result, bytes, null);
      } catch (e) {
        applyUpdate(result, bytes, null);
      }
      _docCache[docId] = result;
      return result;
    } catch (e) {
      return null;
    }
  }

  Future<void> writeDoc(
    String? docId,
    Doc doc, {
    bool needUpload = true,
    bool uploadNow = false,
  }) async {
    if (docId == null) {
      return;
    }
    useV2Encoding();
    await _updateLock.synchronized(() async {
      var bytes = encodeStateAsUpdate(doc, null);
      _docCache[docId] = doc;
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
          await serviceManager.uploadTaskService.uploadDoc(docId, 0);
        } else {
          await serviceManager.uploadTaskService.uploadDoc(docId);
        }
      }
    });
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
    return _updateLock.synchronized(() async {
      try {
        // 1.更新到编辑器
        var doc = _docCache[docId];
        if (doc != null) {
          // 将此次更新设置位不需要上传变化，也不需要写到文件
          setNotEditUpdate(docId, true);
          try {
            applyUpdateV2(doc, delta, null);
          } catch (e) {
            printLog("更新doc失败, applyUpdateV2 error: $e");
          } finally {
            setNotEditUpdate(docId, null);
          }
        }
        // 2.写到文件
        var newBytes = delta;
        var docBytes = await readDocBytes(docId);
        if (docBytes != null && docBytes.isNotEmpty) {
          var mergeList = [delta, docBytes];
          newBytes = mergeUpdatesV2(mergeList);
        }
        await writeDocBytes(docId, newBytes);
        // 3.上传到服务器(20秒后)
        await serviceManager.uploadTaskService.uploadDoc(docId);
        return docBytes == null || !_equalsBytes(docBytes, newBytes);
      } catch (e) {
        printLog("合并doc失败, error: $e");
        return false;
      }
    });
  }

  Future<void> deleteDocFile(String docId) async {
    _docCache.remove(docId);
    _fileCache.remove(docId);
    var path = await serviceManager.fileManager.getNoteFilePath(docId);
    try {
      File(path).deleteSync();
    } catch (e) {
      e.printError();
    }
  }

  String readDocToJson(Uint8List data) {
    var doc = Doc();
    applyUpdateV2(doc, data, null);
    return jsonEncode(doc.toJSON());
  }

  Future<Doc> readJsonDoc(String? content) async {
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

  bool _equalsSnapshot(Uint8List bytes1, Uint8List bytes2) {
    Doc doc1 = Doc();
    applyUpdateV2(doc1, bytes1, null);
    Doc doc2 = Doc();
    applyUpdateV2(doc2, bytes2, null);
    return equalSnapshots(snapshot(doc1), snapshot(doc2));
  }

  Doc createYDoc(DocPO info) {
    var doc = Doc();
    doc.clientID = serviceManager.userService.clientId;
    doc.getArray("blocks").insert(0, [createEmptyTextYMap()]);
    writeDoc(info.uuid, doc, uploadNow: true);
    return doc;
  }

  Future<Uint8List?> queryDocDelta(String dataId, List<int> content) async {
    var doc = await readDoc(dataId);
    if (doc == null) {
      return null;
    }
    return encodeStateAsUpdateV2(doc, Uint8List.fromList(content));
  }

  Future<Uint8List?> queryDocSnap(String docId) async {
    var doc = await readDoc(docId);
    if (doc == null) {
      return null;
    }
    return encodeStateVectorV2(doc);
  }
}
