import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';
import 'package:wenznote/app/windows/controller/doc/win_doc_page_controller.dart';
import 'package:wenznote/app/windows/model/doc/win_doc_list_item_vo.dart';
import 'package:wenznote/app/windows/model/today/search_result_vo.dart';
import 'package:wenznote/app/windows/service/doc/win_doc_list_service.dart';
import 'package:wenznote/app/windows/service/today/win_today_service.dart';
import 'package:wenznote/model/note/po/doc_dir_po.dart';
import 'package:wenznote/model/note/po/doc_po.dart';
import 'package:wenznote/model/task/task.dart';
import 'package:wenznote/service/edit/doc_edit_service.dart';
import 'package:wenznote/service/service_manager.dart';

class WinDocListController extends ServiceManagerController {
  String? docDirUuid;
  var pathList = RxList<DocDirPO>();
  var docList = RxList<WinDocListItemVO>();
  var selectItem = Rxn<String>();
  StreamSubscription? subscription;
  StreamSubscription? searchListener;
  var searchResultList = RxList(<WinTodaySearchResultVO>[]);
  BaseTask? searchTask;
  late WinTodayService winTodayService;
  late WinDocListService docListService;
  late DocEditService docEditService;
  WinDocPageController docPageController;

  WinDocListController({
    this.docDirUuid,
    required this.docPageController,
  });

  String get searchText => docPageController.searchContent.value;

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    docEditService = serviceManager.editService;
    winTodayService = serviceManager.todayService;
    docListService = serviceManager.docListService;
    fetchData();
    // subscription = serviceManager.docService.documentIsar.docDirPOs
    //     .watchLazy()
    //     .listen((event) {
    //   queryDocList();
    // });
    // subscription = serviceManager.docService.documentIsar.docPOs
    //     .watchLazy()
    //     .listen((event) {
    //   queryDocList();
    // });
    searchListener =
        docPageController.searchContent.listen(onSearchContentChanged);
  }

  void onSearchContentChanged(String text) {
    if (docPageController.docListController == this) {
      searchDoc(text);
    }
  }

  void fetchData() async {
    await queryPathList();
    await queryDocList();
    if (searchText.isNotEmpty) {
      onSearchContentChanged(searchText);
    }
  }

  bool isHome() {
    return docDirUuid == null;
  }

  Future<void> queryDocList() async {
    var dirAndDocList = await docListService.queryDirAndDocList(docDirUuid);
    var itemList = dirAndDocList.map((e) => WinDocListItemVO(item: e)).toList();
    docList.value = itemList;
  }

  void back(BuildContext context) {
    if (ModalRoute.of(context)?.canPop == true) {
      Navigator.of(context).pop();
    }
  }

  List<String> getPath() {
    return ["笔记"];
  }

  Future<void> queryPathList() async {
    pathList.value = await docListService.queryPath(docDirUuid);
    // pathList.refresh();
    print('get ');
  }

  void openDirectory(BuildContext context, String? uuid,
      [bool restore = false]) {
    var routeName = uuid ?? "/";
    if (restore) {
      Navigator.of(context).popUntil((item) {
        return item.settings.name == routeName || item.settings.name == "/";
      });
      return;
    }
    Navigator.of(context).restorablePushNamed(routeName);
  }

  void openDocOrDirectory(
    BuildContext context,
    WinDocListItemVO docItem,
  ) {
    if (docItem.isFolder) {
      openDirectory(context, docItem.uuid);
    } else {
      openDoc(context, docItem.doc);
    }
  }

  Future<void> openDoc(BuildContext context, DocPO? uuid,
      [bool isCreateMode = false]) async {
    if (uuid == null) {
      return;
    }
    docPageController.openDoc(uuid, isCreateMode);
  }

  Future<DocPO> createDoc(BuildContext context, String name) async {
    var doc = await docListService.createDoc(docDirUuid, name);
    SchedulerBinding.instance.scheduleFrameCallback((timeStamp) {
      openDoc(context, doc, true);
    });
    return doc;
  }

  Future<DocDirPO> createDirectory(BuildContext context, String text) async {
    return await docListService.createDirectory(docDirUuid, text);
  }

  @override
  void onDispose() {
    super.onDispose();
    subscription?.cancel();
    searchListener?.cancel();
  }

  Future<void> deleteDoc(WinDocListItemVO docItem) async {
    await docListService.deleteDoc(docItem);
    docPageController.homeController.closeDoc(docItem.doc!);
  }

  Future<void> deleteFolder(WinDocListItemVO docItem) async {
    await docListService.deleteFolder(docItem);
  }

  Future<void> updateDocItemName(
      BuildContext context, WinDocListItemVO docItem, String text) async {
    await docListService.updateName(docItem.doc ?? docItem.dir, text);
    if (!docItem.isFolder) {
      var tab = docPageController.homeController.getDocTab(docItem.uuid);
      tab?.controller.onRename(text);
    }
  }

  bool canMoveToPath(List<WinDocListItemVO> list, List<DocDirPO> path) {
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

  void moveToDir(DocDirPO dir, List<WinDocListItemVO> list) {
    docListService.moveToDir(dir, list.map((e) => e.doc ?? e.dir).toList());
  }

  Future<void> searchDoc(String text) async {
    searchTask?.cancel = true;
    searchResultList.clear();
    searchTask = BaseTask(task: (BaseTask task) async {
      var searchDocList = <DocPO>[];
      await queryChildDocList(
          docList.map((element) => element.item!).toList(), searchDocList);
      for (var doc in searchDocList) {
        if (task.cancel) {
          break;
        }
        //对doc进行搜索
        try {
          var searchResult = await winTodayService.searchDocContent(doc, text);
          if (task.cancel == false) {
            searchResultList.addAll(searchResult);
          }
        } catch (e, stack) {
          print(stack);
        }
      }
    });
    await searchTask!.doTask();
  }

  Future<void> queryChildDocList(List<dynamic> list, List<DocPO> result) async {
    for (var value in list) {
      if (value is DocDirPO) {
        var childList = await docListService.queryDirAndDocList(value.uuid);
        await queryChildDocList(childList, result);
      } else {
        result.add(value as DocPO);
      }
    }
  }

  Future<void> deleteNote(WinTodaySearchResultVO searchItem) async {
    docPageController.homeController.closeDoc(searchItem.doc);
    await winTodayService.deleteNote(searchItem.doc);
    await docEditService.deleteDocFile(searchItem.doc.uuid!);
  }

  Future<void> moveToDocDir(
      WinTodaySearchResultVO searchItem, DocDirPO dir) async {
    var doc = searchItem.doc;
    doc.name = searchItem.getTitleString();
    doc.type = 'doc';
    doc.pid = dir.uuid;
    doc.updateTime = DateTime.now().millisecondsSinceEpoch;
    await winTodayService.updateDoc(doc);
    fetchData();
  }

  Future<void> copyContent(
      BuildContext context, WinTodaySearchResultVO searchItem) async {
    await winTodayService.serviceManager.copyService
        .copyWenElements(context, searchItem.getAllWenElements());
    showToast(
      "复制成功",
      position: ToastPosition.bottom,
    );
  }
}
