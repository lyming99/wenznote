import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_crdt/flutter_crdt.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:note/app/mobile/view/move/move_controller.dart';
import 'package:note/commons/mvc/controller.dart';
import 'package:note/model/note/enum/note_order_type.dart';
import 'package:note/model/note/enum/note_type.dart';
import 'package:note/model/note/po/doc_po.dart';
import 'package:note/service/search/search_result_vo.dart';
import 'package:note/service/service_manager.dart';
import 'package:uuid/uuid.dart';

import '../move/move_widget.dart';
import 'mobile_today_model.dart';

/// 日记、便签、笔记、卡片*、待办*、重点*
class MobileTodayController extends ServiceManagerController {
  var searchList = RxList(<SearchResultVO>[]);
  var orderType = OrderType.desc.obs;
  var orderParam = OrderProperty.updateTime.obs;

  var showDoc = true.obs;
  var showTagNote = true.obs;
  var showDiary = true.obs;
  var showCard = false.obs;
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
      // sortDoc(docList);
    });
    orderType.listen((val) {
      // sortDoc(docList);
    });

    showDoc.listen((val) {
      fetchDoc();
    });

    showTagNote.listen((val) {
      fetchDoc();
    });

    showDiary.listen((val) {
      fetchDoc();
    });
    showCard.listen((val) {
      fetchDoc();
    });
    Timer(const Duration(milliseconds: 100), () {
      fetchDoc();
    });
  }

  void fetchDoc({bool refreshList = true}) async {
    searchList.clear();
    serviceManager.searchService.searchDoc(
        text: searchText.value,
        callback: (doc, list) {
          searchList.add(list.first);
        });
  }

  void sortDoc(List<MobileTodayModel> docList) {
    var comparators = <Comparator<MobileTodayModel>>[];
    switch (orderParam.value) {
      case OrderProperty.createTime:
        comparators.add((a, b) => a.createTime.compareTo(b.createTime));
        comparators.add((a, b) => a.updateTime.compareTo(b.updateTime));
        comparators.add((a, b) => a.reviewTime.compareTo(b.reviewTime));
        break;
      case OrderProperty.updateTime:
        comparators.add((a, b) => a.updateTime.compareTo(b.updateTime));
        comparators.add((a, b) => a.createTime.compareTo(b.createTime));
        comparators.add((a, b) => a.reviewTime.compareTo(b.reviewTime));
        break;
      case OrderProperty.memo:
        comparators.add((a, b) => a.reviewTime.compareTo(b.reviewTime));
        comparators.add((a, b) => a.createTime.compareTo(b.createTime));
        comparators.add((a, b) => a.updateTime.compareTo(b.updateTime));
        break;
    }
    bool reverse = orderType.value == OrderType.desc;
    docList.sort((MobileTodayModel a, MobileTodayModel b) {
      if (reverse) {
        return -compareMultiProperties(a, b, comparators);
      }
      return compareMultiProperties(a, b, comparators);
    });
  }

  void openDoc(SearchResultVO docModel) {
    context.push("/mobile/local/doc/edit", extra: {"doc": docModel.doc});
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

  void saveToDocTree(BuildContext context, int index) async {
    var doc = searchList[index];
    var po = doc.doc;
    var result = await showModalBottomSheet(
        context: context,
        enableDrag: false,
        builder: (context) {
          return MoveWidget(
            controller: MoveController(),
          );
        });
    if (result != null) {
      var pid = result["pid"];
      po.type = "doc";
      po.pid = pid;
      await serviceManager.docService.updateDoc(po);
      fetchDoc(refreshList: false);
    }
  }

  void doSearch(String text) {
    searchList.clear();
    serviceManager.searchService.searchDoc(
      text: text,
      callback: (doc, list) {
        if (list.isNotEmpty) {
          searchList.add(list.first);
        }
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
    GoRouter.of(context).push("/mobile/local/doc/edit", extra: {"doc": doc});
  }

  @override
  void onDidUpdateWidget(BuildContext context, MvcController oldController) {
    super.onDidUpdateWidget(context, oldController);
    fetchDoc();
  }
}
