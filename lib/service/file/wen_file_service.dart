import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_crdt/flutter_crdt.dart';
import 'package:note/commons/service/file_manager.dart';
import 'package:note/editor/crdt/doc_utils.dart';
import 'package:note/service/crypt/crypt_service.dart';
import 'package:note/service/service_manager.dart';
import 'package:note/service/user/user_service.dart';
import 'package:path_provider/path_provider.dart';

/// 读取数据 = 读取全量数据(离线)+读取合并数据(用户)+增量数据(用户)
/// 写入数据 = 写入全量数据+写入增量数据
/// 每500个增量合并一次
class WenFileService {
  ServiceManager serviceManager;

  WenFileService(this.serviceManager);

  final _fileCache = <String, Uint8List>{};
  final _docCache = <String, Doc>{};

  Future<String> getNoteDir() async {
    var appDir = await getApplicationDocumentsDirectory();
    return "${appDir.path}/WenNote/${serviceManager.userService.userPath}notes";
  }

  Future<String> getNoteFilePath(String docId) async {
    var noteDir = await getNoteDir();
    if (!await Directory(noteDir).exists()) {
      await Directory(noteDir).create(recursive: true);
    }
    return "$noteDir/$docId.wnote";
  }

  Future<Uint8List?> readDocFile(String? docId) async {
    if (docId == null || docId.isEmpty) {
      return null;
    }
    var item = _fileCache[docId];
    if (item != null) {
      return item;
    }
    var noteFile = File(await getNoteFilePath(docId));
    if (noteFile.existsSync()) {
      var result = await serviceManager.cryptService.decode(await noteFile.readAsBytes());
      _fileCache[docId] = result;
      return result;
    }
    return null;
  }

  Future<void> writeDocFile(String? docId, Uint8List data) async {
    if (docId == null || docId.isEmpty) {
      return;
    }
    var noteFile = File(await getNoteFilePath(docId));
    await noteFile.writeAsBytes(await serviceManager.cryptService.encode(data));
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

    var startTime = DateTime.now().millisecondsSinceEpoch;
    // 如何将读取耗时控制在一定范围内？
    var bytes = await readDocFile(docId);
    if (bytes == null) {
      return null;
    }
    var endTime = DateTime.now().millisecondsSinceEpoch;
    print('read doc use time:${endTime - startTime} ms');
    try {
      Doc result = Doc();
      try {
        applyUpdateV2(result, bytes, null);
      } catch (e) {
        applyUpdate(result, bytes, null);
      }
      _docCache[docId] = result;
      return result;
    } catch (e) {
      return null;
    } finally {
      var endTime = DateTime.now().millisecondsSinceEpoch;
      print('to doc use time:${endTime - startTime} ms');
    }
  }

  Future<void> writeDoc(String? docId, Doc doc) async {
    if (docId == null) {
      return;
    }
    useV2Encoding();
    var bytes = encodeStateAsUpdate(doc, null);
    _docCache[docId] = doc;
    await writeDocFile(docId, bytes);
  }

  Future<void> deleteDoc(String docId) async {
    _docCache.remove(docId);
    _fileCache.remove(docId);
    var path = await getNoteFilePath(docId);
    try {
      File(path).deleteSync();
    } catch (e) {}
  }

  Future<void> saveDocStringFile(String? uuid, String? content) async {
    if (uuid == null) {
      return;
    }
    var doc = await jsonToYDoc(content);
    await writeDoc(uuid, doc);
  }
}
