import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:wenznote/app/windows/controller/doc/win_doc_list_controller.dart';
import 'package:wenznote/app/windows/controller/home/win_home_controller.dart';
import 'package:wenznote/commons/mvc/controller.dart';
import 'package:wenznote/model/note/po/doc_po.dart';
import 'package:ydart/ydart.dart';

class WinDocPageController extends MvcController {
  WinHomeController homeController;
  var searchController = TextEditingController();
  var searchContent = "".obs;
  WinDocListController? docListController;
  var docListControllerMap = <String, WinDocListController>{};

  WinDocPageController(this.homeController);

  @override
  void onDidUpdateWidget(BuildContext context, MvcController oldController) {
    super.onDidUpdateWidget(context, oldController);
    var old = oldController as WinDocPageController;
    searchController = old.searchController;
    searchContent = old.searchContent;
    docListController = old.docListController;
    docListControllerMap = old.docListControllerMap;
  }

  void createDoc(BuildContext context, String text) async {
    var doc = await docListController?.createDoc(context, text);
    docListController?.selectItem.value = doc?.uuid;
  }

  void createDirectory(BuildContext context, String text) async {
    var dir = await docListController?.createDirectory(context, text);
    docListController?.selectItem.value = dir?.uuid;
  }

  void onPushRoute(Route? route) {}

  void onPopRoute(Route? route) {}

  void openDoc(DocPO doc, bool isCreateMode) {
    homeController.openDoc(doc, isCreateMode);
  }

  void reloadDoc(DocPO doc, YDoc content) {
    for (var listController in docListControllerMap.values) {
      var docList = listController.searchResultList;
      for (var docItem in docList) {
        if (docItem.doc.uuid == doc.uuid) {
          docItem.updateContent(content);
          break;
        }
      }
    }
  }
}
