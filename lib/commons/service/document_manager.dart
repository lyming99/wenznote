import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import 'package:wenznote/commons/util/markdown/markdown.dart';
import 'package:wenznote/commons/util/string.dart';
import 'package:wenznote/commons/util/wdoc/wdoc.dart';
import 'package:wenznote/model/note/po/doc_dir_po.dart';
import 'package:wenznote/model/note/po/doc_po.dart';
import 'package:wenznote/service/service_manager.dart';

enum ConflictMode { keepNew, keepAll }

class ImportService {
  ServiceManager serviceManager;

  ImportService(this.serviceManager);

  Future<void> importWdoc({
    required String file,
    String toPath = "",
    ConflictMode conflictMode = ConflictMode.keepAll,
  }) async {
    var docInfo = await readWdocFile(serviceManager.fileManager, file);
    var infoPo = docInfo.info;
    if (infoPo != null) {
      var dir = await createDocPath(toPath);
      infoPo.pid = dir?.uuid;
      DocPO? oldItem;
      if (infoPo.uuid != null) {
        oldItem = await serviceManager.docService.queryDoc(infoPo.uuid!);
      }
      var yDoc = await serviceManager.editService.readJsonDoc(docInfo.content);
      if (conflictMode == ConflictMode.keepAll) {
        //保留旧的和新的
        infoPo.id = Isar.autoIncrement;
        if (oldItem?.uuid == infoPo.uuid) {
          infoPo.uuid = const Uuid().v1();
        }
        await serviceManager.docService.createDoc(infoPo, yDoc);
      } else {
        //保留新的 oldTime<=newTime
        if (compareDocTime(oldItem, infoPo) <= 0) {
          await serviceManager.docService.deleteDocReally(infoPo.uuid!);
          await serviceManager.docService.createDoc(infoPo, yDoc);
        }
      }
    }
  }

  /// -1: aTime<bTime
  /// 0: aTime==bTime
  /// 1: aTime>bTime
  int compareDocTime(DocPO? a, DocPO? b) {
    int aTime = a?.updateTime ?? a?.createTime ?? 0;
    int bTime = b?.updateTime ?? b?.createTime ?? 0;
    //1.compareTo(2) -1
    return aTime.compareTo(bTime);
  }

  Future<void> importMarkdownFile(
      {required String file,
      required String toPath,
      required ConflictMode conflictMode}) async {
    var docInfo = await readMarkdownInfo(serviceManager.fileManager, file);
    if (docInfo == null) {
      return;
    }
    var filename = docInfo.filename;
    if (filename == null) {
      return;
    }
    var elements = docInfo.elements;
    if (elements == null) {
      return;
    }
    var uuid = Uuid().v1();
    var dir = await createDocPath(toPath);
    //保留旧的和新的
    var doc = DocPO(
      type: "doc",
      pid: dir?.uuid,
      name: filename,
      uuid: uuid,
      createTime: DateTime.now().millisecondsSinceEpoch,
    );
    var yDoc =
        await serviceManager.editService.readJsonDoc(jsonEncode(elements));
    await serviceManager.docService.createDoc(doc, yDoc);
  }

  Future<DocDirPO?> createDocPath(String path) async {
    if (path == "" || path == "/") {
      return null;
    }
    path = path.trimChar("/");
    //1.查询所有路径
    //2.匹配相同路径
    var dirs = await serviceManager.docService.queryAllDocDirList();
    var dirMap = <String, DocDirPO>{};
    for (var dir in dirs) {
      var uuid = dir.uuid;
      if (uuid != null) {
        dirMap[uuid] = dir;
      }
    }
    var pathMap = <String, DocDirPO>{};
    for (var dir in dirs) {
      if (dir.uuid == null) {
        continue;
      }
      var path = dir.name ?? "";
      var parent = dir.pid;
      while (parent != null) {
        var pNode = dirMap[parent];
        if (pNode == null) {
          break;
        }
        var pPath = pNode.name ?? "";
        path = "$pPath/$path".trimLeftChar("/");
        parent = pNode.pid;
      }
      pathMap[path] = dir;
    }
    var pathList = pathMap.keys.toList()
      ..sort((a, b) {
        return (b.length).compareTo(a.length);
      });
    for (var value in pathList) {
      if (path.startsWith(value)) {
        return await _createDirInDir(pathMap[value], value, path);
      }
    }
    return await _createDirectory(path, null);
  }

  Future<DocDirPO?> _createDirInDir(
      DocDirPO? dir, String? parentPath, String path) async {
    if (parentPath?.trimRightChar("/") == path.trimRightChar("/")) {
      return dir;
    }
    if (parentPath != null) {
      var subPath = path.substring(parentPath.length).trimLeftChar("/");
      return await _createDirectory(subPath, dir?.uuid);
    } else {
      return await _createDirectory(path, null);
    }
  }

  Future<DocDirPO?> _createDirectory(String path, String? pid) async {
    var items = path.split("/");
    DocDirPO? last;
    for (var item in items) {
      var uuid = const Uuid().v1();
      var po = DocDirPO(
        uuid: uuid,
        pid: pid,
        name: item,
      );
      await serviceManager.docService.createDocDir(po);
      pid = uuid;
      last = po;
    }
    return last;
  }
}
