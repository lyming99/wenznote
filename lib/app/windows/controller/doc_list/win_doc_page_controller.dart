import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:note/app/windows/controller/doc_list/win_doc_list_controller.dart';

class WinDocPageController extends GetxController {
  var searchController = TextEditingController();
  var searchContent = "".obs;
  WinDocListController? docListController;
  var docListControllerMap = <String, WinDocListController>{};

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
}
