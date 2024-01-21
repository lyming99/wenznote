import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note/app/windows/controller/home/win_home_controller.dart';
import 'package:note/app/windows/widgets/custom_tab_view.dart';
import 'package:note/commons/mvc/controller.dart';
import 'package:note/commons/mvc/view.dart';
import 'package:window_manager/window_manager.dart';

class WinTabController extends MvcController {
  WinHomeController homeController;

  WinTabController(this.homeController);

  int currentIndex = 0;

  List<CustomTab> tabs = [];

  void openTab({
    required String id,
    required Widget text,
    required Widget body,
    Widget? icon,
    String? semanticLabel,
  }) {
    for (var i = 0; i < tabs.length; i++) {
      var tab = tabs[i];
      if (tab.key == ValueKey(id)) {
        currentIndex = i;
        notifyListeners();
        return;
      }
    }
    tabs.add(CustomTab(
      key: ValueKey(id),
      text: text,
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
  }

  void selectTab(int x) {
    currentIndex = x;
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
              header: fluent.IconButton(
                onPressed: () {
                  controller.homeController.showNavPage.value =
                      !controller.homeController.showNavPage.value;
                },
                icon: Icon(Icons.menu_outlined),
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
                      width: 54 * 3,
                      child: DragToMoveArea(
                        child: Container(),
                      ),
                    ),
            ),
          );
  }
}
