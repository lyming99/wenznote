import 'dart:io';
import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wenznote/app/windows/controller/home/win_home_controller.dart';
import 'package:wenznote/app/windows/widgets/custom_tab_view.dart';
import 'package:wenznote/commons/mvc/controller.dart';
import 'package:wenznote/commons/mvc/view.dart';
import 'package:wenznote/editor/widget/drop_menu.dart';
import 'package:wenznote/widgets/mac_window_button.dart';
import 'package:window_manager/window_manager.dart';

mixin Focusable {
  void focus() {}
}

class WinTabController extends MvcController {
  WinHomeController homeController;

  WinTabController(this.homeController);

  int currentIndex = 0;

  List<CustomTab> tabs = [];

  int findTabIndex(String id) {
    for (var i = 0; i < tabs.length; i++) {
      var tab = tabs[i];
      if (tab.key == ValueKey(id)) {
        return i;
      }
    }
    return -1;
  }

  bool isStartTab(int tabIndex) {
    return tabIndex == 0;
  }

  bool isEndTab(int tabIndex) {
    return tabIndex == tabs.length - 1;
  }

  void openTab({
    required String id,
    required Widget text,
    required Widget body,
    Widget? icon,
    String? semanticLabel,
  }) {
    int tabIndex = findTabIndex(id);
    if (tabIndex != -1) {
      var tab = tabs[tabIndex];
      currentIndex = tabIndex;
      var body = tab.body;
      if (body is Focusable) {
        (body as Focusable).focus();
      }
      notifyListeners();
      return;
    }
    tabs.add(CustomTab(
      key: ValueKey(id),
      text: GestureDetector(
        child: text,
        onSecondaryTapUp: (d) {
          showTabContextMenu(d, id);
        },
      ),
      semanticLabel: semanticLabel,
      icon: icon,
      body: body,
      onClosed: () {
        closeTab(id);
      },
    ));
    currentIndex = tabs.length - 1;
    notifyListeners();
  }

  void showTabContextMenu(TapUpDetails event, String id) {
    int tabIndex = findTabIndex(id);
    showMouseDropMenu(
      context,
      event.globalPosition & Size.zero,
      menus: [
        DropMenu(
          text: Text("关闭标签页"),
          onPress: (ctx) {
            hideDropMenu(ctx);
            closeTab(id);
          },
        ),
        DropMenu(
          text: Text("关闭其它标签页"),
          onPress: (ctx) {
            hideDropMenu(ctx);
            closeOtherTabs(tabIndex);
          },
        ),
        DropMenu(
          text: Text("关闭所有标签页"),
          onPress: (ctx) {
            hideDropMenu(ctx);
            closeAllTab(tabIndex);
          },
        ),
        if (!isStartTab(tabIndex))
          DropMenu(
            text: Text("关闭左侧标签页"),
            onPress: (ctx) {
              hideDropMenu(ctx);
              closeLeftTabs(tabIndex);
            },
          ),
        if (!isEndTab(tabIndex))
          DropMenu(
            text: Text("关闭右侧侧标签页"),
            onPress: (ctx) {
              hideDropMenu(ctx);
              closeRightTabs(tabIndex);
            },
          ),
      ],
    );
  }

  void closeOtherTabs(int index) {
    var current = tabs[index];
    tabs.removeWhere((element) => element != current);
    currentIndex = 0;
    notifyListeners();
  }

  void closeAllTab(int index) {
    currentIndex = 0;
    tabs.clear();
    notifyListeners();
    homeController.showNavPage.value = true;
  }

  void closeLeftTabs(int index) {
    tabs.removeRange(0, index);
    currentIndex = 0;
    notifyListeners();
  }

  void closeRightTabs(int index) {
    tabs.removeRange(index + 1, tabs.length);
    currentIndex = index;
    notifyListeners();
  }

  void closeTab(String id) {
    for (var i = 0; i < tabs.length; i++) {
      var tab = tabs[i];
      if (tab.key == ValueKey(id)) {
        tabs.removeAt(i);
        currentIndex = max(0, min(currentIndex, tabs.length - 1));
        notifyListeners();
        break;
      }
    }
    if (tabs.isEmpty) {
      homeController.showNavPage.value = true;
    }
  }

  void selectTab(int x) {
    currentIndex = x;
    var body = tabs[x].body;
    if (body is Focusable) {
      (body as Focusable).focus();
    }
    notifyListeners();
  }

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = tabs.removeAt(oldIndex);
    tabs.insert(newIndex, item);
    if (currentIndex == newIndex) {
      currentIndex = oldIndex;
    } else if (currentIndex == oldIndex) {
      currentIndex = newIndex;
    }
    notifyListeners();
  }
}

class WinTabView extends MvcView<WinTabController> {
  const WinTabView({super.key, required super.controller});

  @override
  Widget build(BuildContext context) {
    var isShowNav = controller.homeController.showNavPage.isTrue;
    return controller.tabs.isEmpty && isShowNav
        ? DragToMoveArea(child: Container())
        : Material(
            color: Colors.transparent,
            child: DragMoveTabView(
              tabs: controller.tabs,
              tabWidthBehavior: TabWidthBehavior.equal,
              currentIndex: controller.currentIndex,
              onReorder: (oldIndex, newIndex) {
                controller.reorder(oldIndex, newIndex);
              },
              header: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (Platform.isMacOS && !isShowNav)
                    buildMacWindowButton(context),
                  if (Platform.isMacOS && !isShowNav)
                    SizedBox(
                      width: 10,
                    ),
                  fluent.IconButton(
                    onPressed: () {
                      controller.homeController.showNavPage.value =
                          !controller.homeController.showNavPage.value;
                    },
                    icon: Icon(
                      CupertinoIcons.sidebar_left,
                      size: 16,
                    ),
                  ),
                ],
              ),
              onChanged: (x) {
                controller.selectTab(x);
              },
              shortcutsEnabled: false,
              showScrollButtons: false,
              onNewPressed: () {
                controller.homeController.todayController.createNote();
              },
              footer: isShowNav
                  ? null
                  : SizedBox(
                      width: Platform.isWindows ? 54 * 3 : 32,
                      child: DragToMoveArea(
                        child: Container(),
                      ),
                    ),
            ),
          );
  }
}
