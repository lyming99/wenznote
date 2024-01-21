import 'package:flutter_crdt/flutter_crdt.dart';
import 'package:get/get.dart';
import 'package:wenznote/app/mobile/view/doc/mobile_doc_page_controller.dart';
import 'package:wenznote/app/mobile/view/today/mobile_today_controller.dart';
import 'package:wenznote/editor/crdt/YsText.dart';
import 'package:wenznote/model/note/po/doc_po.dart';
import 'package:wenznote/service/service_manager.dart';
import 'package:uuid/uuid.dart';

class MobileHomePageController extends ServiceManagerController {
  var navIndex = 0.obs;
  String? currentDocDir;
  var showBottomNav = true.obs;
  var todayController = MobileTodayController();

  var docListController = MobileDocPageController();

  String getTile() {
    return getLabel(navIndex.value);
  }

  String getLabel(int index) {
    String title = "";
    switch (index) {
      case 0:
        title = "今天";
        break;
      case 1:
        title = "笔记";
        break;
      case 2:
        title = "卡片";
        break;
    }
    return title;
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

  Future<DocPO> createNote() async {
    var item = DocPO(
      uuid: const Uuid().v1(),
      createTime: DateTime.now().millisecondsSinceEpoch,
      updateTime: DateTime.now().millisecondsSinceEpoch,
      type: "note",
    );
    await serviceManager.docService.createDoc(item);
    var docContent = Doc();
    docContent.getArray("blocks").insert(0, [createEmptyTextYMap()]);
    await serviceManager.editService.writeDoc(item.uuid, docContent);
    return item;
  }

  Future<DocPO?> createNoteAndOpen() async {
    return null;
  }
}
