import 'package:flutter_crdt/flutter_crdt.dart';
import 'package:get/get.dart';
import 'package:note/app/windows/controller/home/win_home_controller.dart';
import 'package:note/app/windows/model/doc_list/win_doc_list_item_vo.dart';
import 'package:note/editor/crdt/YsText.dart';
import 'package:note/model/note/po/doc_dir_po.dart';
import 'package:note/model/note/po/doc_po.dart';
import 'package:note/service/service_manager.dart';
import 'package:uuid/uuid.dart';

class WinDocListService {
  @override
  ServiceManager serviceManager;

  WinDocListService(this.serviceManager);

  Future<List<dynamic>> queryDirAndDocList(String? uuid) async {
    return serviceManager.docService.queryDirAndDocList(uuid);
  }

  Future<List<dynamic>> queryDirList(String? uuid) async {
    return serviceManager.docService.queryDirList(uuid);
  }

  Future<List<DocDirPO>> queryPath(String? uuid) async {
    return serviceManager.docService.queryPath(uuid);
  }

  Future<DocDirPO> createDirectory(String? pid, String text) async {
    var item = DocDirPO(
      pid: pid,
      uuid: Uuid().v1(),
      createTime: DateTime.now().millisecondsSinceEpoch,
      updateTime: DateTime.now().millisecondsSinceEpoch,
      name: text,
    );
    await serviceManager.docService.createDocDir(item);
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
    await serviceManager.editService.writeDoc(item.uuid, docContent);
    return item;
  }

  Future<void> deleteDoc(WinDocListItemVO docItem) async {
    Get.find<WinHomeController>().closeDoc(docItem.doc!);
    await serviceManager.docService.deleteDoc(docItem.doc!);
    await serviceManager.editService.deleteDocFile(docItem.uuid!);
  }

  Future<void> deleteFolder(WinDocListItemVO docItem) async {
    await serviceManager.docService.deleteDir(docItem.uuid);
  }

  Future<void> updateName(Object? docItem, String name) async {
    if (docItem is DocDirPO) {
      var dir = docItem;
      dir.updateTime = DateTime.now().millisecondsSinceEpoch;
      dir.name = name;
      await serviceManager.docService.updateDocDir(dir);
    } else if (docItem is DocPO) {
      var doc = docItem;
      doc.updateTime = DateTime.now().millisecondsSinceEpoch;
      doc.name = name;
      await serviceManager.docService.updateDoc(doc);
    }
  }

  Future<void> moveToDir(DocDirPO toDir, List list) async {
    for (var value in list) {
      if (value is DocDirPO) {
        var item = value;
        item.pid = toDir.uuid;
        item.updateTime = DateTime.now().millisecondsSinceEpoch;
        await serviceManager.docService.updateDocDir(item);
      } else if(value is DocPO){
        var doc = value;
        doc.pid = toDir.uuid;
        doc.updateTime = DateTime.now().millisecondsSinceEpoch;
        await serviceManager.docService.updateDoc(doc);
      }
    }
  }
}
