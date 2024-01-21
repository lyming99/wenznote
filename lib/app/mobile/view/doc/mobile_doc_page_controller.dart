import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_crdt/flutter_crdt.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:note/app/windows/service/doc/win_doc_list_service.dart';
import 'package:note/commons/mvc/controller.dart';
import 'package:note/model/note/enum/note_type.dart';
import 'package:note/model/note/po/doc_dir_po.dart';
import 'package:note/model/note/po/doc_po.dart';
import 'package:note/service/search/search_result_vo.dart';
import 'package:note/service/service_manager.dart';
import 'package:uuid/uuid.dart';

import 'mobile_doc_page_model.dart';

class MobileDocPageController extends ServiceManagerController {
  late WinDocListService docListService;

  var scrollController = ScrollController();
  String? pid;

  var searchController = TextEditingController();

  var searchFocusNode = FocusNode();

  var modelList = RxList(<MobileDocModel>[]);

  var searchList = RxList(<SearchResultVO>[]);

  var pathList = RxList(<DocDirPO>[]);

  var selectItem = Rxn<String>();

  var searchText = "".obs;

  MobileDocPageController({this.pid});

  bool get isSearchList => searchText.isNotEmpty;

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    docListService = serviceManager.docListService;
    fetchData();
  }

  @override
  void onDidUpdateWidget(BuildContext context, MvcController oldController) {
    super.onDidUpdateWidget(context, oldController);
    var old = oldController as MobileDocPageController;
    pid = old.pid;
    scrollController = old.scrollController;
    searchController = old.searchController;
    docListService = old.docListService;
    modelList = old.modelList;
    searchList = old.searchList;
    pathList = old.pathList;
    selectItem = old.selectItem;
  }

  Future<void> fetchData() async {
    await queryPathList();
    await queryDocList();
  }

  void doSearch() {
    searchList.clear();
    if (searchController.text.isNotEmpty) {
      serviceManager.searchService.searchDoc(
        pid: pid,
        type: "doc",
        text: searchController.text,
        callback: (doc, result) {
          if (result.isNotEmpty) {
            searchList.add(result.first);
          }
        },
      );
    }
  }

  Future<void> queryPathList() async {
    pathList.value = await docListService.queryPath(pid);
  }

  Future<void> queryDocList() async {
    var dirAndDocList = await docListService.queryDirAndDocList(pid);
    modelList.value =
        dirAndDocList.map((e) => MobileDocModel(value: e)).toList();
  }

  void openDirectory(BuildContext context, String? uuid) {
    var router = GoRouter.of(context);
    if (uuid == null) {
      GoRouter.of(context).go(
        "/mobile/doc",
      );
    } else {
      if (existPath(router, uuid)) {
        while (!router.routerDelegate.currentConfiguration.last.matchedLocation
            .contains(uuid)) {
          router.pop();
        }
      } else {
        GoRouter.of(context).push(
          "/mobile/doc/dir/$uuid",
        );
      }
    }
  }

  bool existPath(GoRouter router, String path) {
    var matches = router.routerDelegate.currentConfiguration.matches;
    for (var item in matches) {
      if (item.matchedLocation.contains(path)) {
        return true;
      }
      if (item is ShellRouteMatch) {
        for (var childItem in item.matches) {
          if (childItem.matchedLocation.contains(path)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  void createNote() {}

  void openSearchItem(SearchResultVO searchItem) {}

  void copySearchItem(BuildContext context, int index) {}

  void moveSearchItem(BuildContext context, int index) {}

  void deleteSearchItem(BuildContext context, int index) async {
    var searchItem = searchList[index];
    await serviceManager.todayService.deleteNote(searchItem.doc);
    await serviceManager.editService.deleteDocFile(searchItem.doc.uuid!);
    fetchData();
  }

  void openDocOrDirectory(BuildContext ctx, MobileDocModel docItem) {
    if (docItem.isFolder) {
      openDirectory(context, docItem.uuid);
    } else {
      GoRouter.of(context)
          .push("/mobile/doc/edit", extra: {"doc": docItem.value});
    }
  }

  void createDoc(BuildContext context, String name) async {
    var doc = DocPO(
      uuid: const Uuid().v1(),
      pid: pid,
      type: NoteType.doc.name,
      createTime: DateTime.now().millisecondsSinceEpoch,
      updateTime: DateTime.now().millisecondsSinceEpoch,
    );
    await serviceManager.todayService.createDoc(doc);
    var docContent = serviceManager.editService.createDoc();
    serviceManager.p2pService
        .sendDocEditMessage(doc.uuid!, encodeStateAsUpdateV2(docContent, null));
    await serviceManager.editService.writeDoc(doc.uuid, docContent);
    fetchData();
    GoRouter.of(context).push("/mobile/doc/edit", extra: {"doc": doc});
  }

  void createDirectory(BuildContext context, String name) async {
    var item = await docListService.createDirectory(pid, name);
    selectItem.value = item.uuid;
    fetchData();
  }

  void updateDocItemName(
    BuildContext context,
    MobileDocModel docItem,
    String name,
  ) async {
    await docListService.updateName(docItem.value, name);
    fetchData();
  }

  bool canMoveToPath(List<MobileDocModel> list, List<DocDirPO> path) {
    if (path.length <= 1) {
      return true;
    }
    var pathIdSet =
        path.map((e) => e.uuid).where((element) => element != null).toSet();

    /// 如果 path 路径包含选择的路径，则无法移动
    for (var item in list) {
      if (item.isFolder) {
        if (pathIdSet.contains(item.uuid)) {
          return false;
        }
      }
    }
    return true;
  }

  void moveToDir(DocDirPO dir, List<MobileDocModel> list) async {
    await docListService.moveToDir(dir, list.map((e) => e.value).toList());
    fetchData();
  }

  void deleteFolder(MobileDocModel docItem) async {
    await serviceManager.docService.deleteDir(docItem.value.uuid!);
    fetchData();
  }

  void deleteDoc(MobileDocModel docItem) async {
    await serviceManager.todayService.deleteNote(docItem.value);
    await serviceManager.editService.deleteDocFile(docItem.value.uuid!);
    fetchData();
  }
}
