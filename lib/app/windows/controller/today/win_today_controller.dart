import 'package:flutter/material.dart';
import 'package:flutter_crdt/flutter_crdt.dart';
import 'package:get/get.dart';
import 'package:wenznote/app/windows/controller/home/win_home_controller.dart';
import 'package:wenznote/app/windows/model/today/search_result_vo.dart';
import 'package:wenznote/app/windows/view/doc/win_note_edit_tab.dart';
import 'package:wenznote/commons/mvc/controller.dart';
import 'package:wenznote/model/note/enum/note_order_type.dart';
import 'package:wenznote/model/note/enum/note_type.dart';
import 'package:wenznote/model/note/po/doc_dir_po.dart';
import 'package:wenznote/model/note/po/doc_po.dart';
import 'package:wenznote/model/task/task.dart';
import 'package:wenznote/service/service_manager.dart';
import 'package:wenznote/widgets/ticker_widget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:uuid/uuid.dart';

class WinTodayController extends ServiceManagerController {
  BaseTask? searchTask;
  RxList<WinTodaySearchResultVO> searchResultList =
      RxList(<WinTodaySearchResultVO>[]);
  Rx<String> searchContent = Rx("");
  RxList<NoteType> noteType =
      RxList([NoteType.note, NoteType.doc, NoteType.dayNote]);
  Rx<OrderProperty> orderProperty = Rx(OrderProperty.updateTime);
  Rx<OrderType> orderType = Rx(OrderType.desc);
  TextEditingController searchController = TextEditingController();
  TabController? tabBarController;
  WinHomeController homeController;

  WinTodayController(this.homeController);

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    startSearchTask();
    searchContent.listen((val) {
      startSearchTask();
    });
    noteType.listen((p0) {
      startSearchTask();
    });
    orderProperty.listen((p0) {
      startSearchTask();
    });
    orderType.listen((p0) {
      startSearchTask();
    });
    serviceManager.docService.addListener(onDocListUpdate);
  }

  @override
  void onDispose() {
    super.onDispose();
    serviceManager.docService.removeListener(onDocListUpdate);
  }

  int sortDoc(DocPO a, DocPO b) {
    var aValue = 0;
    var bValue = 0;
    if (orderProperty.value == OrderProperty.createTime) {
      aValue = a.createTime ?? 0;
      bValue = b.createTime ?? 0;
    } else {
      aValue = a.updateTime ?? 0;
      bValue = b.updateTime ?? 0;
    }
    if (orderType.value == OrderType.asc) {
      return aValue.compareTo(bValue);
    }
    return -1 * aValue.compareTo(bValue);
  }

  void startSearchTask() {
    searchTask?.cancel = true;
    searchResultList.clear();
    var orderProperty = this.orderProperty.value;
    var searchContent = this.searchContent.value;
    var noteType = this.noteType;
    searchTask = BaseTask.start((BaseTask task) async {
      var docList = await serviceManager.todayService.queryDocList(
        noteType,
        orderProperty,
      );
      docList.sort(sortDoc);
      if (noteType.contains(NoteType.open)) {
        var openNotes = homeController
            .editTabList
            .whereType<WinNoteEditTab>()
            .map((e) => e.doc)
            .toList();
        docList.addAll(openNotes.reversed);
      }
      for (var doc in docList) {
        if (task.cancel) {
          break;
        }
        //对doc进行搜索
        var searchResult = await serviceManager.todayService
            .searchDocContent(doc, searchContent);
        if (task.cancel == false) {
          searchResultList.addAll(searchResult);
        }
      }
    });
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
    homeController.openDoc(doc);
    startSearchTask();
  }

  void openDoc(DocPO doc) {
    homeController.openDoc(doc);
  }

  Future<void> copyContent(
      BuildContext context, WinTodaySearchResultVO searchItem) async {
    await serviceManager.copyService
        .copyWenElements(context, searchItem.getAllWenElements());
    showToast(
      "复制成功",
      position: ToastPosition.bottom,
    );
  }

  Future<void> deleteNote(WinTodaySearchResultVO searchItem) async {
    homeController.closeDoc(searchItem.doc);
    await serviceManager.todayService.deleteNote(searchItem.doc);
    await serviceManager.editService.deleteDocFile(searchItem.doc.uuid!);
    startSearchTask();
  }

  TabController createTabController(BuildContext context) {
    return TabController(length: 3, vsync: findTickerProvider(context));
  }

  Future<void> moveToDocDir(
      WinTodaySearchResultVO searchItem, DocDirPO dir) async {
    var doc = searchItem.doc;
    doc.name = searchItem.getTitleString();
    doc.type = 'doc';
    doc.pid = dir.uuid;
    doc.updateTime = DateTime.now().millisecondsSinceEpoch;
    await serviceManager.todayService.updateDoc(doc);
    startSearchTask();
  }

  void onDocListUpdate() {
    startSearchTask();
  }

  void reloadDoc(DocPO doc, Doc content) {
    for(var searchItem in searchResultList){
      if(searchItem.doc.uuid==doc.uuid){
        searchItem.updateContent(content);
        break;
      }
    }
  }
}
