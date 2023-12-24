import 'package:flutter/material.dart';
import 'package:flutter_crdt/flutter_crdt.dart';
import 'package:get/get.dart';
import 'package:note/app/windows/controller/home/win_home_controller.dart';
import 'package:note/app/windows/view/doc_list/win_note_edit_tab.dart';
import 'package:note/app/windows/model/today/search_result_vo.dart';
import 'package:note/app/windows/service/today/win_today_service.dart';
import 'package:note/commons/service/copy_service.dart';
import 'package:note/editor/crdt/YsText.dart';
import 'package:note/model/note/enum/note_order_type.dart';
import 'package:note/model/note/enum/note_type.dart';
import 'package:note/model/note/po/doc_dir_po.dart';
import 'package:note/model/note/po/doc_po.dart';
import 'package:note/model/task/task.dart';
import 'package:note/service/file/wen_file_service.dart';
import 'package:note/service/service_manager.dart';
import 'package:note/service/user/user_service.dart';
import 'package:note/widgets/ticker_widget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:uuid/uuid.dart';

class WinTodayController extends GetxController {
  ServiceManager serviceManager;
  BaseTask? searchTask;
  RxList<WinTodaySearchResultVO> searchResultList =
      RxList(<WinTodaySearchResultVO>[]);
  Rx<String> searchContent = Rx("");
  RxList<NoteType> noteType =
      RxList([NoteType.note, NoteType.doc, NoteType.dayNote]);
  Rx<NoteOrderProperty> orderProperty = Rx(NoteOrderProperty.updateTime);
  Rx<OrderType> orderType = Rx(OrderType.desc);
  TextEditingController searchController = TextEditingController();
  TabController? tabBarController;

  WinTodayController(this.serviceManager);

  @override
  void onInit() {
    super.onInit();
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
  }

  int sortDoc(DocPO a, DocPO b) {
    var aValue = 0;
    var bValue = 0;
    if (orderProperty.value == NoteOrderProperty.createTime) {
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
        var openNotes = Get.find<WinHomeController>()
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
      uuid: Uuid().v1(),
      type: NoteType.note.name,
      createTime: DateTime.now().millisecondsSinceEpoch,
      updateTime: DateTime.now().millisecondsSinceEpoch,
    );
    await serviceManager.todayService.createDoc(doc);
    var docContent = Doc();
    docContent.getArray("blocks").insert(0, [createEmptyTextYMap()]);
    await serviceManager.wenFileService.writeDoc(doc.uuid, docContent);
    Get.find<WinHomeController>().openDoc(doc);
    startSearchTask();
  }

  void openDoc(DocPO doc) {
    Get.find<WinHomeController>().openDoc(doc);
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
    Get.find<WinHomeController>().closeDoc(searchItem.doc);
    await serviceManager.todayService.deleteNote(searchItem.doc);
    await serviceManager.wenFileService.deleteDoc(searchItem.doc.uuid!);
    startSearchTask();
  }

  TabController createTabController(BuildContext context) {
    return TabController(length: 4, vsync: findTickerProvider(context));
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
}
