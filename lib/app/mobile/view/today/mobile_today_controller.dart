import 'dart:async';

import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crdt/flutter_crdt.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:note/app/windows/view/doc/win_select_doc_dir_dialog.dart';
import 'package:note/commons/mvc/controller.dart';
import 'package:note/model/note/enum/note_order_type.dart';
import 'package:note/model/note/enum/note_type.dart';
import 'package:note/model/note/po/doc_dir_po.dart';
import 'package:note/model/note/po/doc_po.dart';
import 'package:note/service/search/search_result_vo.dart';
import 'package:note/service/service_manager.dart';
import 'package:uuid/uuid.dart';

/// 日记、便签、笔记、卡片*、待办*、重点*
class MobileTodayController extends ServiceManagerController {
  var searchList = RxList(<SearchResultVO>[]);
  var orderType = OrderType.desc.obs;
  var orderParam = OrderProperty.updateTime.obs;

  var showDoc = true.obs;
  var showNote = true.obs;
  var scrollController = ScrollController();
  var searchController = TextEditingController();
  var searchFocusNode = FocusNode();
  var searchText = "".obs;

  List<SearchResultVO> get showList => searchList;

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    searchController.addListener(() {
      searchText.value = searchController.text;
      doSearch(searchController.text);
    });
    orderParam.listen((val) {
      sortDoc(searchList);
    });
    orderType.listen((val) {
      sortDoc(searchList);
    });

    showDoc.listen((val) {
      fetchDoc();
    });

    showNote.listen((val) {
      fetchDoc();
    });
    fetchDoc();
  }

  void fetchDoc({bool refreshList = true}) async {
    doSearch(searchText.value);
  }

  void sortDoc(List<SearchResultVO> docList) {
    var comparators = <Comparator<SearchResultVO>>[];
    switch (orderParam.value) {
      case OrderProperty.createTime:
        comparators
            .add((a, b) => a.doc.createTime!.compareTo(b.doc.createTime!));
        comparators.add((a, b) => a.updateTime!.compareTo(b.doc.updateTime!));
        break;
      case OrderProperty.updateTime:
        comparators
            .add((a, b) => a.doc.updateTime!.compareTo(b.doc.updateTime!));
        comparators
            .add((a, b) => a.doc.createTime!.compareTo(b.doc.createTime!));
        break;
      case OrderProperty.memo:
        break;
    }
    bool reverse = orderType.value == OrderType.desc;
    docList.sort((SearchResultVO a, SearchResultVO b) {
      if (reverse) {
        return -compareMultiProperties(a, b, comparators);
      }
      return compareMultiProperties(a, b, comparators);
    });
  }

  void openDoc(SearchResultVO docModel) async {
    await context.push("/mobile/doc/edit", extra: {"doc": docModel.doc});
    docModel.refresh();
  }

  void delete(BuildContext context, int index) {
    var item = searchList.removeAt(index);
    serviceManager.docService.deleteDoc(item.doc);
    Fluttertoast.showToast(msg: "已经删除~");
  }

  void copy(BuildContext context, int index) async {
    var docModel = searchList[index];
    serviceManager.copyService.copyDocContent(context, docModel.doc.uuid!);
    Fluttertoast.showToast(msg: "复制成功~");
  }

  bool canMoveToPath(DocPO doc, List<DocDirPO> path) {
    if (path.length <= 1) {
      return true;
    }
    var pathIdSet =
        path.map((e) => e.uuid).where((element) => element != null).toSet();

    /// 如果 path 路径包含选择的路径，则无法移动
    if (pathIdSet.contains(doc.uuid)) {
      return false;
    }
    return true;
  }

  void saveToDocTree(BuildContext context, int index) async {
    var doc = searchList[index];
    var po = doc.doc;
    void moveToDir(DocDirPO dir, List<DocPO> list) async {
      await serviceManager.docListService.moveToDir(dir, list);
      fetchDoc(refreshList: false);
    }

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      builder: (context) {
        return SelectDocDirDialog(
          title: "移动到",
          actionLabel: "移动到此处",
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.8,
          filter: (path) {
            return canMoveToPath(po, path);
          },
          onSelect: (dir) {
            po.type = "doc";
            po.name = "便签 ${formatDate(DateTime.now(), [
                  yyyy,
                  "-",
                  mm,
                  "-",
                  dd,
                  " ",
                  HH,
                  ":",
                  nn,
                  ":",
                  ss
                ])}";
            moveToDir(dir, [po]);
          },
        );
      },
    );
  }

  void doSearch(String text) {
    searchList.clear();
    serviceManager.searchService.searchDoc(
      text: text,
      callback: (doc, list) {
        if (showNote.isFalse && doc.type == "note") {
          return;
        }
        if (showDoc.isFalse && doc.type == "doc") {
          return;
        }
        if (list.isNotEmpty) {
          searchList.add(list.first);
        }
      },
      onEnd: () {
        sortDoc(searchList);
      },
    );
  }

  int compareMultiProperties<T>(T a, T b, List<Comparator<T>> comparators) {
    for (var value in comparators) {
      int result = value.call(a, b);
      if (result == 0) {
        continue;
      }
      return result;
    }
    return 0;
  }

  Future<void> createNote() async {
    var doc = DocPO(
      uuid: const Uuid().v1(),
      type: NoteType.note.name,
      createTime: DateTime.now().millisecondsSinceEpoch,
      updateTime: DateTime.now().millisecondsSinceEpoch,
    );
    await serviceManager.todayService.createDoc(doc);
    var docContent = serviceManager.editService.createDoc();
    serviceManager.p2pService
        .sendDocEditMessage(doc.uuid!, encodeStateAsUpdateV2(docContent, null));
    await serviceManager.editService.writeDoc(doc.uuid, docContent);
    await GoRouter.of(context).push("/mobile/doc/edit", extra: {"doc": doc});
    fetchDoc(refreshList: true);
  }

  @override
  void onDidUpdateWidget(BuildContext context, MvcController oldController) {
    super.onDidUpdateWidget(context, oldController);
    var old = (oldController as MobileTodayController);
    showDoc = old.showDoc;
    showNote = old.showNote;
    searchList = old.searchList;
    searchList = old.searchList;
    orderType = old.orderType;
    orderParam = old.orderParam;
    showDoc = old.showDoc;
    showNote = old.showNote;
    scrollController = old.scrollController;
    searchController = old.searchController;
    searchFocusNode = old.searchFocusNode;
    searchText = old.searchText;
    fetchDoc();
  }

  Widget getUserIcon(
    BuildContext context, [
    double size = 32,
  ]) {
    return serviceManager.userService.buildUserIcon(context, size);
  }
}
