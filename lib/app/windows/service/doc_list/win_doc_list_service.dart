import 'package:flutter_crdt/flutter_crdt.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:note/app/windows/controller/home/win_home_controller.dart';
import 'package:note/app/windows/model/doc_list/win_doc_list_item_vo.dart';
import 'package:note/editor/crdt/YsText.dart';
import 'package:note/model/note/enum/note_type.dart';
import 'package:note/model/note/po/doc_dir_po.dart';
import 'package:note/model/note/po/doc_po.dart';
import 'package:note/service/isar/isar_service_mixin.dart';
import 'package:note/service/service_manager.dart';
import 'package:uuid/uuid.dart';

class WinDocListService with IsarServiceMixin {
  @override
  ServiceManager serviceManager;

  WinDocListService(this.serviceManager);

  Future<List<dynamic>> queryDirAndDocList(String? uuid) async {
    var result = [];
    var dirList = await documentIsar.docDirPOs
        .filter()
        .pidEqualTo(uuid)
        .sortByCreateTime()
        .findAll();
    result.addAll(dirList);
    var docList = await documentIsar.docPOs
        .filter()
        .pidEqualTo(uuid)
        .and()
        .typeEqualTo(NoteType.doc.name)
        .sortByCreateTime()
        .findAll();
    result.addAll(docList);
    return result;
  }

  Future<List<dynamic>> queryDirList(String? uuid) async {
    return await documentIsar.docDirPOs
        .filter()
        .pidEqualTo(uuid)
        .sortByCreateTime()
        .findAll();
  }

  Future<List<DocDirPO>> queryPath(String? uuid) async {
    var result = [DocDirPO(name: "我的笔记")];
    if (uuid == null) {
      return result;
    }
    var current =
        await documentIsar.docDirPOs.filter().uuidEqualTo(uuid).findFirst();
    while (current != null) {
      result.insert(1, current);
      if (current.pid == null) {
        break;
      }
      current = await documentIsar.docDirPOs
          .filter()
          .uuidEqualTo(current.pid)
          .findFirst();
    }
    return result;
  }

  Future<DocDirPO> createDirectory(String? pid, String text) async {
    var item = DocDirPO(
      pid: pid,
      uuid: Uuid().v1(),
      createTime: DateTime.now().millisecondsSinceEpoch,
      updateTime: DateTime.now().millisecondsSinceEpoch,
      name: text,
    );
    await documentIsar.writeTxn(() async {
      await documentIsar.docDirPOs.put(item);
    });
    return item;
  }

  Future<DocPO> createDoc(String? pid, String text) async {
    var item = DocPO(
      pid: pid,
      uuid: Uuid().v1(),
      createTime: DateTime.now().millisecondsSinceEpoch,
      updateTime: DateTime.now().millisecondsSinceEpoch,
      name: text,
      type: "doc",
    );
    await serviceManager.docService.createDoc(item);
    var docContent = Doc();
    docContent.getArray("blocks").insert(0, [createEmptyTextYMap()]);
    await serviceManager.wenFileService.writeDoc(item.uuid, docContent);
    return item;
  }

  Future<void> deleteDoc(WinDocListItemVO docItem) async {
    Get.find<WinHomeController>().closeDoc(docItem.doc!);
    var isar = documentIsar.docPOs.isar;
    await isar.writeTxn(() async {
      await isar.docPOs.filter().uuidEqualTo(docItem.uuid).deleteFirst();
    });
    await serviceManager.wenFileService.deleteDoc(docItem.uuid!);
  }

  Future<void> deleteFolder(WinDocListItemVO docItem) async {
    var isar = documentIsar.docDirPOs.isar;
    await isar.writeTxn(() async {
      await isar.docDirPOs.filter().uuidEqualTo(docItem.uuid).deleteFirst();
    });
  }

  Future<void> updateName(WinDocListItemVO docItem, String name) async {
    if (docItem.isFolder) {
      var dir = docItem.dir!;
      dir.updateTime = DateTime.now().millisecondsSinceEpoch;
      dir.name = name;
      await serviceManager.docService.updateDocDir(dir);
    } else {
      var doc = docItem.doc!;
      doc.updateTime = DateTime.now().millisecondsSinceEpoch;
      doc.name = name;
      await serviceManager.docService.updateDoc(doc);
    }
  }

  Future<void> moveToDir(DocDirPO toDir, List<WinDocListItemVO> list) async {
    for (var value in list) {
      if (value.isFolder) {
        var item = value.dir!;
        item.pid = toDir.uuid;
        item.updateTime = DateTime.now().millisecondsSinceEpoch;
        await serviceManager.docService.updateDocDir(item);
      } else {
        var doc = value.doc!;
        doc.pid = toDir.uuid;
        doc.updateTime = DateTime.now().millisecondsSinceEpoch;
        await serviceManager.docService.updateDoc(doc);
      }
    }
  }
}
