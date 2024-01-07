import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:get/get.dart';
import 'package:note/app/windows/view/doc_list/win_note_edit_tab.dart';
import 'package:note/app/windows/view/settings/settings_controller.dart';
import 'package:note/app/windows/view/settings/settings_widget.dart';
import 'package:note/app/windows/view/tabs/help_tab.dart';
import 'package:note/app/windows/widgets/win_edit_tab.dart';
import 'package:note/service/file/file_manager.dart';
import 'package:note/commons/util/markdown/markdown.dart';
import 'package:note/editor/crdt/doc_utils.dart';
import 'package:note/model/note/enum/note_type.dart';
import 'package:note/model/note/po/doc_po.dart';
import 'package:note/service/service_manager.dart';
import 'package:note/service/user/user_service.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:uuid/uuid.dart';
import 'package:window_manager/window_manager.dart';

class WinHomeController extends GetxController {
  var navIndex = 0.obs;
  var showEditPane = true.obs;
  var currentNoteEditor = Rx<WinNoteEditTab?>(null);
  var editTabList = RxList<WinEditTabMixin>();
  var editTabIndex = 0;
  var recentOpenTabList = <WinEditTabMixin>[];
  var maxOpenTab = 20;
  var showNavPage = true.obs;
  var showSettings = false.obs;
  late UserService userService;
  ServiceManager serviceManager;

  var isDropOver = false.obs;

  bool get isLogin => userService.hasLogin;

  WinHomeController(this.serviceManager);

  @override
  void onInit() {
    super.onInit();
    userService = serviceManager.userService;
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

  void onOpenPage(int index) {
    if (index < editTabList.length) {
      var tab = editTabList[index];
      if (tab is WinNoteEditTab) {
        currentNoteEditor.value = tab;
      } else {
        currentNoteEditor.value = null;
      }
    } else {
      currentNoteEditor.value = null;
      return;
    }
    var currentItem = editTabList[index];
    recentOpenTabList.remove(currentItem);
    recentOpenTabList.add(currentItem);
    if (recentOpenTabList.length > maxOpenTab) {
      var removeItem = recentOpenTabList.removeAt(0);
      editTabIndex = recentOpenTabList.length - 1;
      editTabList.remove(removeItem);
      removeItem.onClosePage();
    }
    currentItem.onOpenPage();
  }

  void openDoc(DocPO doc, [bool isCreateMode = false]) {
    openTab(
      "doc-${doc.uuid}",
      () => WinNoteEditTab(
        controller: WinNoteEditTabController(
            serviceManager: serviceManager,
            doc: doc,
            isCreateMode: isCreateMode,
            onUpdate: () {
              getDocTab(doc.uuid)?.notifyListeners();
            }),
      ),
    );
  }

  void closeDoc(DocPO doc) {
    closeTab("doc-${doc.uuid}");
  }

  void closeTab(String id) {
    var editIndex = editTabList.indexWhere((element) => element.tabId == id);
    if (editIndex != -1) {
      recentOpenTabList.removeLast();
      editTabList.removeAt(editIndex).onClosePage();
      if (recentOpenTabList.isNotEmpty) {
        var nextOpen = recentOpenTabList.last;
        var nextIndex = editTabList
            .indexWhere((element) => element.tabId == nextOpen.tabId);
        if (nextIndex == -1) {
          editTabIndex = max(0, editTabList.length - 1);
          return;
        }
        editTabIndex = nextIndex;
        onOpenPage(nextIndex);
      }
    }
  }

  void openTab(String tabId, WinEditTabMixin Function() tabBuild) {
    var tabIndex = editTabList.indexWhere((element) => element.tabId == tabId);
    if (tabIndex != -1) {
      editTabIndex = tabIndex;
      onOpenPage(tabIndex);
      editTabList.refresh();
    } else {
      editTabIndex = editTabList.length;
      editTabList.add(tabBuild.call());
      onOpenPage(editTabIndex);
    }
  }

  void openSettings() {
    showNavPage.value = false;
    showSettings.value = true;
    openTab("settings", () {
      Get.put(WinSettingsController());
      return WinTabWidget(
        tabId: "settings",
        child: const WinSettingsWidget(),
        onTabClose: () {
          showNavPage.value = true;
          showSettings.value = false;
        },
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
    await serviceManager.editService.writeDoc(doc.uuid, yDoc);
    await serviceManager.docService.createDoc(doc);
    openDoc(doc);
  }

  WinNoteEditTab? getDocTab(String? uuid) {
    var tab =
        editTabList.firstWhere((element) => element.tabId == "doc-${uuid}");
    if (tab is WinNoteEditTab) {
      return tab;
    }
    return null;
  }

  void openHelpTab() {
    openTab("help_windows", () {
      return WinEditTab(
        id: "help_windows",
        builder: (context, controller) {
          return const WindowsHelpTab();
        },
      );
    });
  }

  Future<void> readUserInfo() async {
    await userService.readUserInfo();
  }
}
