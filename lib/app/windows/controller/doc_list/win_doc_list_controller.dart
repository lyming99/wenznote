import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:note/app/windows/controller/doc_list/win_doc_page_controller.dart';
import 'package:note/app/windows/controller/home/win_home_controller.dart';
import 'package:note/app/windows/model/doc_list/win_doc_list_item_vo.dart';
import 'package:note/app/windows/model/today/search_result_vo.dart';
import 'package:note/app/windows/service/doc_list/win_doc_list_service.dart';
import 'package:note/app/windows/service/today/win_today_service.dart';
import 'package:note/commons/service/copy_service.dart';
import 'package:note/model/note/po/doc_dir_po.dart';
import 'package:note/model/note/po/doc_po.dart';
import 'package:note/model/task/task.dart';
import 'package:note/service/file/wen_file_service.dart';
import 'package:note/service/service_manager.dart';
import 'package:oktoast/oktoast.dart';

class WinDocListController extends GetxController {
  late ServiceManager serviceManager;
  late WinDocListService docListService;
  String? docDirUuid;
  var pathList = RxList<DocDirPO>();
  var docList = RxList<WinDocListItemVO>();
  var selectItem = Rxn<String>();
  StreamSubscription? subscription;
  StreamSubscription? searchListener;
  var searchResultList = RxList(<WinTodaySearchResultVO>[]);
  BaseTask? searchTask;

  late WinTodayService winTodayService;

  late WenFileService wenFileService;

  WinDocListController({
    this.docDirUuid,
  });

  WinDocPageController get docPageController => Get.find();

  String get searchText => docPageController.searchContent.value;

  @override
  void onInit() {
    super.onInit();
    serviceManager = ServiceManager.of(Get.context!);
    wenFileService = serviceManager.wenFileService;
    winTodayService = serviceManager.todayService;
    docListService = serviceManager.docListService;
    fetchData();
    subscription =
        docListService.documentIsar.docDirPOs.watchLazy().listen((event) {
      queryDocList();
    });
    subscription =
        docListService.documentIsar.docPOs.watchLazy().listen((event) {
      queryDocList();
    });
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
    Get.find<WinHomeController>().openDoc(uuid, isCreateMode);
  }

  Future<DocPO> createDoc(BuildContext context, String text) async {
    var doc = await docListService.createDoc(docDirUuid, text);
    SchedulerBinding.instance.scheduleFrameCallback((timeStamp) {
      openDoc(context, doc, true);
    });
    return doc;
  }

  Future<DocDirPO> createDirectory(BuildContext context, String text) async {
    return await docListService.createDirectory(docDirUuid, text);
  }

  @override
  void onClose() {
    super.onClose();
    subscription?.cancel();
    searchListener?.cancel();
  }

  Future<void> deleteDoc(WinDocListItemVO docItem) async {
    await docListService.deleteDoc(docItem);
  }

  Future<void> deleteFolder(WinDocListItemVO docItem) async {
    await docListService.deleteFolder(docItem);
  }

  Future<void> updateDocItemName(
      BuildContext context, WinDocListItemVO docItem, String text) async {
    await docListService.updateName(docItem, text);
    if (!docItem.isFolder) {
      WinHomeController home = Get.find();
      var tab = home.getDocTab(docItem.uuid);
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
    docListService.moveToDir(dir, list);
  }

  void searchDoc(String text) async {
    searchTask?.cancel = true;
    searchResultList.clear();
    searchTask = BaseTask.start((BaseTask task) async {
      var searchDocList = <DocPO>[];
      await queryChildDocList(
          docList.map((element) => element.item!).toList(), searchDocList);
      for (var doc in searchDocList) {
        if (task.cancel) {
          break;
        }
        //对doc进行搜索
        var searchResult = await winTodayService.searchDocContent(doc, text);
        if (task.cancel == false) {
          searchResultList.addAll(searchResult);
        }
      }
    });
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
    Get.find<WinHomeController>().closeDoc(searchItem.doc);
    await winTodayService.deleteNote(searchItem.doc);
    await wenFileService.deleteDoc(searchItem.doc.uuid!);
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
