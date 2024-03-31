import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:uuid/uuid.dart';
import 'package:wenznote/app/mobile/controller/settings/mobile_settings_controller.dart';
import 'package:wenznote/app/mobile/view/settings/mobile_settings_page.dart';
import 'package:wenznote/app/windows/controller/card/win_card_set_controller.dart';
import 'package:wenznote/app/windows/controller/doc/win_doc_page_controller.dart';
import 'package:wenznote/app/windows/controller/today/win_today_controller.dart';
import 'package:wenznote/app/windows/view/doc/win_note_edit_tab.dart';
import 'package:wenznote/app/windows/view/tabs/help_tab.dart';
import 'package:wenznote/app/windows/widgets/win_edit_tab.dart';
import 'package:wenznote/app/windows/widgets/win_tab_view.dart';
import 'package:wenznote/commons/mvc/controller.dart';
import 'package:wenznote/commons/util/markdown/markdown.dart';
import 'package:wenznote/editor/crdt/doc_utils.dart';
import 'package:wenznote/model/note/enum/note_type.dart';
import 'package:wenznote/model/note/po/doc_po.dart';
import 'package:wenznote/service/file/file_manager.dart';
import 'package:wenznote/service/service_manager.dart';
import 'package:window_manager/window_manager.dart';

import '../../widgets/doc_title_widget.dart';

class WinHomeController extends ServiceManagerController {
  var navIndex = 0.obs;
  var showEditPane = true.obs;
  var currentNoteEditor = Rx<WinNoteEditTab?>(null);
  var editTabList = RxList<WinEditTabMixin>();
  var editTabIndex = 0;
  var recentOpenTabList = <WinEditTabMixin>[];
  var maxOpenTab = 20;
  var showNavPage = true.obs;
  var showSettings = false.obs;
  var isDropOver = false.obs;
  late WinCardSetController cardController;
  late WinDocPageController docController;
  late WinTodayController todayController;

  late WinTabController tabController;

  bool get isLogin => serviceManager.userService.hasLogin;

  bool get isConnected => serviceManager.p2pService.connected.isTrue;

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    docController = WinDocPageController(this);
    todayController = WinTodayController(this);
    cardController = WinCardSetController(this);
    tabController = WinTabController(this);
    showNavPage.listen((val) async {
      if (val) {
        await windowManager.setMinimumSize(const Size(720, 480));
        var size = await windowManager.getSize();
        if (size.width < 720) {
          windowManager.setSize(Size(720, size.height));
        }
      } else {
        windowManager.setMinimumSize(const Size(420, 480));
      }
    });
  }

  @override
  void onDidUpdateWidget(BuildContext context, MvcController oldController) {
    super.onDidUpdateWidget(context, oldController);
    var old = oldController as WinHomeController;
    navIndex = old.navIndex;
    showEditPane = old.showEditPane;
    currentNoteEditor = old.currentNoteEditor;
    editTabList = old.editTabList;
    editTabIndex = old.editTabIndex;
    recentOpenTabList = old.recentOpenTabList;
    maxOpenTab = old.maxOpenTab;
    showNavPage = old.showNavPage;
    showSettings = old.showSettings;
    isDropOver = old.isDropOver;
    cardController = old.cardController;
    docController = old.docController;
    todayController = old.todayController;
    tabController = old.tabController;
  }

  void openTab({
    required String id,
    required Widget text,
    required Widget body,
    Widget? icon,
    String? semanticLabel,
  }) {
    tabController.openTab(
      id: id,
      text: text,
      body: body,
      icon: icon,
      semanticLabel: semanticLabel,
    );
  }

  void openDoc(DocPO doc, [bool isCreateMode = false]) {
    openTab(
      id: "doc-${doc.uuid}",
      text: DocTitleWidget(
        controller: DocTitleController(doc),
      ),
      body: WinNoteEditTab(
        controller: WinNoteEditTabController(
            homeController: this,
            doc: doc,
            isCreateMode: isCreateMode,
            onUpdate: (content) {
              docController.reloadDoc(doc, content);
              todayController.reloadDoc(doc, content);
              getDocTab(doc.uuid)?.controller.notifyListeners();
            }),
      ),
    );
  }

  void closeDoc(DocPO doc) {
    closeTab("doc-${doc.uuid}");
  }

  void closeTab(String id) {
    tabController.closeTab(id);
  }

  void openSettings() {
    showDialog(
        context: context,
        builder: (context) {
          return MobileSettingsPage(
            controller: MobileSettingsController(),
          );
        });
  }

  void closeWhere(bool Function(WinEditTabMixin element) test) {
    var list = editTabList.where(test).toList();
    for (var value in list) {
      closeTab(value.tabId);
    }
  }

  Future<void> dropIn(PerformDropEvent event) async {
    for (var item in event.session.items) {
      item.dataReader?.getValue(Formats.fileUri, (value) {
        if (value is Uri) {
          var path = value.toFilePath();
          var stat = File(path).statSync();
          if (stat.type == FileSystemEntityType.file) {
            if (path.endsWith(".md")) {
              importMarkdownFile(serviceManager.fileManager, path);
            }
          }
        }
      });
    }
  }

  Future<void> importMarkdownFile(FileManager fileManager, String? path) async {
    if (path == null) {
      return;
    }
    var markInfo = await readMarkdownInfo(fileManager, path);
    var elements = markInfo?.elements;
    if (elements == null) {
      return;
    }
    var doc = DocPO(
      uuid: Uuid().v1(),
      createTime: DateTime.now().millisecondsSinceEpoch,
      updateTime: DateTime.now().millisecondsSinceEpoch,
      type: NoteType.note.name,
    );
    var yDoc = await elementsToYDoc(elements);
    await serviceManager.docService.createDoc(doc, yDoc);
    openDoc(doc);
  }

  WinNoteEditTab? getDocTab(String? uuid) {
    var tab = tabController.tabs
        .firstWhere((element) => element.key == ValueKey("doc-${uuid}"));
    var body = tab.body;
    if (body is WinNoteEditTab) {
      return body;
    }
    return null;
  }

  void openHelpTab() {
    openTab(id: "help_windows", text: Text("帮助文档"), body: WindowsHelpTab());
  }

  Future<void> readUserInfo() async {
    await serviceManager.userService.readUserInfo();
  }
}
