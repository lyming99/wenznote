import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note/app/windows/controller/card/win_card_set_controller.dart';
import 'package:note/app/windows/controller/doc_list/win_doc_page_controller.dart';
import 'package:note/app/windows/controller/home/win_home_controller.dart';
import 'package:note/app/windows/controller/today/win_today_controller.dart';
import 'package:note/app/windows/controller/user/info.dart';
import 'package:note/app/windows/controller/user/login.dart';
import 'package:note/app/windows/theme/colors.dart';
import 'package:note/app/windows/view/card/win_card_set_page.dart';
import 'package:note/app/windows/view/doc_list/win_doc_page.dart';
import 'package:note/app/windows/view/today/win_today_page.dart';
import 'package:note/app/windows/view/user/info.dart';
import 'package:note/app/windows/view/user/login.dart';
import 'package:note/commons/service/device_utils.dart';
import 'package:note/commons/widget/split_pane.dart';
import 'package:note/commons/widget/window_buttons.dart';
import 'package:note/editor/theme/theme.dart';
import 'package:note/editor/widget/drop_menu.dart';
import 'package:note/editor/widget/toggle_item.dart';
import 'package:note/editor/widget/window_button.dart';
import 'package:note/service/service_manager.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:window_manager/window_manager.dart';

class WinHomePage extends GetView<WinHomeController> {
  const WinHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        buildAppContent(context),
        buildAppBar(context),
      ],
    );
  }

  Widget buildAppBar(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Obx(() {
        return Row(
          children: [
            Expanded(
                child: controller.showNavPage.isTrue ||
                        controller.showSettings.isFalse
                    ? DragToMoveArea(child: Container())
                    : Container()),
            if (controller.showSettings.isFalse)
              SizedBox(
                width: 50,
                height: 30,
                child: WindowUserButton(
                  onPressed: () {
                    controller.showNavPage.value =
                        !controller.showNavPage.value;
                  },
                  icon: const RotatedBox(
                      quarterTurns: 0,
                      child: fluent.Icon(
                        fluent.FluentIcons.column_right_two_thirds,
                        size: 16,
                      )),
                ),
              ),
            const WindowButtons(),
          ],
        );
      }),
    );
  }

  Widget buildAppContent(BuildContext context) {
    return Obx(() {
      return Row(
        children: [
          if (controller.showNavPage.value) buildNavBar(context),
          Expanded(
            child: buildPage(context),
          ),
        ],
      );
    });
  }

  Widget buildNavBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 30),
      width: 60,
      color: isWin11()
          ? systemColor(context,"winNavColor").withOpacity(0.6)
          : systemColor(context,"winNavColor"),
      child: Column(
        children: [
          buildAccountLogo(context),
          buildTodayNavButton(context),
          buildNoteNavButton(context),
          buildCardNavButton(context),
          Expanded(
              child: DragToMoveArea(
            child: Container(),
          )),
          buildNavMenu(context),
        ],
      ),
    );
  }

  Widget buildAccountLogo(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: ToggleItem(
        onTap: (ctx) async {
          if (controller.isLogin) {
            showUserInfo(ctx);
          } else {
            showLoginDialog(ctx);
          }
        },
        itemBuilder:
            (BuildContext context, bool checked, bool hover, bool pressed) {
          return Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset("assets/images/app_logo.png"),
              ),
              if (controller.isLogin)
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    width: 10,
                    height: 10,
                    margin: EdgeInsets.only(right: 2),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget buildTodayNavButton(BuildContext context) {
    return Obx(
      () {
        controller.navIndex.value;
        return fluent.Tooltip(
          message: "今天",
          triggerMode: TooltipTriggerMode.manual,
          useMousePosition: false,
          displayHorizontally: true,
          style: fluent.TooltipThemeData(
              waitDuration: Duration.zero,
              margin: EdgeInsets.only(
                top: 16,
                left: 10,
              )),
          child: Container(
            width: 36,
            height: 36,
            margin: EdgeInsets.only(top: 20),
            child: ToggleItem(
              onTap: (ctx) {
                controller.navIndex.value = 0;
              },
              itemBuilder: (BuildContext context, bool checked, bool hover,
                  bool pressed) {
                return Container(
                  decoration: controller.navIndex.value != 0 && hover == false
                      ? null
                      : BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                  child: Icon(
                    Icons.today,
                    size: 24,
                    color: controller.navIndex.value != 0
                        ? Colors.black
                        : Colors.blueAccent,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget buildNoteNavButton(BuildContext context) {
    return Obx(
      () {
        controller.navIndex.value;
        return fluent.Tooltip(
          message: "笔记",
          triggerMode: TooltipTriggerMode.manual,
          useMousePosition: false,
          displayHorizontally: true,
          style: fluent.TooltipThemeData(
              waitDuration: Duration.zero,
              margin: EdgeInsets.only(
                top: 16,
                left: 10,
              )),
          child: Container(
            width: 36,
            height: 36,
            margin: EdgeInsets.only(top: 20),
            child: ToggleItem(
              onTap: (ctx) {
                controller.navIndex.value = 1;
              },
              itemBuilder: (BuildContext context, bool checked, bool hover,
                  bool pressed) {
                return Container(
                  decoration: controller.navIndex.value != 1 && hover == false
                      ? null
                      : BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                  child: Icon(
                    Icons.sticky_note_2_outlined,
                    size: 24,
                    color: controller.navIndex.value != 1
                        ? Colors.black
                        : Colors.blueAccent,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget buildCardNavButton(BuildContext context) {
    return Obx(
      () {
        controller.navIndex.value;
        return fluent.Tooltip(
          message: "卡片",
          triggerMode: TooltipTriggerMode.manual,
          useMousePosition: false,
          displayHorizontally: true,
          style: fluent.TooltipThemeData(
              waitDuration: Duration.zero,
              margin: EdgeInsets.only(
                top: 16,
                left: 10,
              )),
          child: Container(
            width: 36,
            height: 36,
            margin: EdgeInsets.only(top: 20),
            child: ToggleItem(
              onTap: (ctx) {
                controller.navIndex.value = 2;
              },
              itemBuilder: (BuildContext context, bool checked, bool hover,
                  bool pressed) {
                return Container(
                  decoration: controller.navIndex.value != 2 && hover == false
                      ? null
                      : BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                  child: Icon(
                    Icons.drafts_outlined,
                    size: 24,
                    color: controller.navIndex.value != 2
                        ? Colors.black87
                        : Colors.blueAccent,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget buildPage(BuildContext context) {
    return Obx(() {
      if (controller.showNavPage.isFalse) {
        return buildEditPane(context);
      }
      return SplitPane(
        primaryIndex: PaneIndex.one,
        primaryMinSize: 240,
        subMinSize: 340,
        onlyShowIndex: controller.showEditPane.value ? null : PaneIndex.one,
        one: buildNavPane(context),
        two: buildEditPane(context),
      );
    });
  }

  Widget buildNavPane(BuildContext context) {
    var navPages = [
      buildTodayPage(context),
      buildNotePage(context),
      buildCardPage(context),
    ];
    return Obx(() {
      return IndexedStack(
        index: controller.navIndex.value,
        children: navPages,
      );
    });
  }

  Widget buildTodayPage(BuildContext context) {
    return DropRegion(
      formats: Formats.standardFormats,
      onDropOver: (DropOverEvent event) {
        controller.isDropOver.value = true;
        if (event.session.allowedOperations.contains(DropOperation.copy)) {
          return DropOperation.copy;
        }
        if (event.session.allowedOperations.contains(DropOperation.move)) {
          return DropOperation.copy;
        }
        return DropOperation.none;
      },
      onDropEnter: (event) {
        controller.isDropOver.value = true;
      },
      onDropLeave: (event) {
        controller.isDropOver.value = false;
      },
      onDropEnded: (event) {
        controller.isDropOver.value = false;
      },
      onPerformDrop: (PerformDropEvent event) async {
        await controller.dropIn(event);
      },
      child: Obx(() {
        return Stack(
          children: [
            Container(
                decoration: BoxDecoration(
                  color: EditTheme.of(context).bgColor2,
                  border: Border(
                      right: BorderSide(
                    color: Colors.grey.shade100,
                  )),
                ),
                child: GetBuilder(
                  init: WinTodayController(ServiceManager.of(context)),
                  builder: (c) {
                    return WinTodayPage();
                  },
                )),
            if (controller.isDropOver.value)
              Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withOpacity(0.1),
              ),
          ],
        );
      }),
    );
  }

  Widget buildNotePage(BuildContext context) {
    print('build note page...');
    return Container(
        decoration: BoxDecoration(
          color: EditTheme.of(context).bgColor2,
          border: Border(
              right: BorderSide(
            color: Colors.grey.shade100,
          )),
        ),
        child: GetBuilder(
          init: WinDocPageController(),
          builder: (c) {
            return WinDocPage();
          },
        ));
  }

  Widget buildCardPage(BuildContext context) {
    print('build card page...');
    return Container(
        decoration: BoxDecoration(
          color: EditTheme.of(context).bgColor2,
          border: Border(
              right: BorderSide(
            color: Colors.grey.shade100,
          )),
        ),
        child: GetBuilder(
          init: WinCardSetController(),
          builder: (c) {
            return WinCardSetPage();
          },
        ));
  }

  Widget buildEditPane(BuildContext context) {
    return Container(
      color: EditTheme.of(context).bgColor3,
      padding: controller.showSettings.isTrue
          ? null
          : const EdgeInsets.only(top: 30),
      child: Obx(() {
        if (controller.editTabList.isEmpty) {
          return DragToMoveArea(child: Container());
        }
        return IndexedStack(
          index: min(controller.editTabList.length, controller.editTabIndex),
          children: [
            for (var item in controller.editTabList) item.buildWidget(context),
          ],
        );
      }),
    );
  }

  Widget buildNavMenu(BuildContext context) {
    return fluent.Tooltip(
      message: "菜单",
      triggerMode: TooltipTriggerMode.manual,
      useMousePosition: false,
      displayHorizontally: true,
      style: fluent.TooltipThemeData(
          waitDuration: Duration.zero,
          margin: EdgeInsets.only(
            top: 16,
            left: 10,
          )),
      child: Container(
        width: 36,
        height: 36,
        margin: EdgeInsets.only(
          bottom: 10,
        ),
        child: ToggleItem(
          onTap: (ctx) {
            showNavContextMenu(ctx);
          },
          itemBuilder:
              (BuildContext context, bool checked, bool hover, bool pressed) {
            return Container(
              decoration: hover == false
                  ? null
                  : BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
              child: Icon(
                Icons.menu_rounded,
                size: 24,
                color: Colors.black87,
              ),
            );
          },
        ),
      ),
    );
  }

  void showNavContextMenu(BuildContext context) {
    showDropMenu(
      context,
      childrenWidth: 150,
      childrenHeight: 32,
      offset: const Offset(2, 0),
      margin: 10,
      menus: [
        DropMenu(
          text: Text("文件"),
          children: [
            DropMenu(
              text: Text("导入笔记"),
              onPress: (ctx) {
                hideDropMenu(ctx);
                Get.toNamed("/import");
              },
            ),
            DropMenu(
              text: Text("导出笔记"),
              onPress: (ctx) {
                hideDropMenu(ctx);
                Get.toNamed("/export");
              },
            ),
          ],
        ),
        DropMenu(
          text: Text("帮助"),
          onPress: (ctx) async {
            hideDropMenu(ctx);
            controller.openHelpTab();
          },
        ),
        DropMenu(
          text: Text("设置"),
          onPress: (ctx) async {
            hideDropMenu(ctx);
            controller.openSettings();
          },
        ),
        DropMenu(
          text: Text("关于"),
          onPress: (ctx) {
            hideDropMenu(ctx);
            showAboutDialog(
              context: context,
              applicationName: "温知笔记",
              applicationVersion: "1.1.beta(2023.09.24)",
              applicationIcon: SizedBox(
                  width: 60,
                  height: 60,
                  child: Image.asset(
                    "assets/images/app_logo.png",
                    width: 100,
                    height: 100,
                    alignment: Alignment.center,
                  )),
            );
          },
        ),
      ],
      popupAlignment: Alignment.centerRight,
      overflowAlignment: Alignment.topRight,
    );
  }

  void showUserInfo(BuildContext context) {
    showCustomDropMenu(
      context: context,
      width: 300,
      height: 400,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: EditTheme.of(context).fontColor.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          clipBehavior: Clip.antiAlias,
          child: WinUserInfoDialog(
            controller: WinUserInfoController(),
          ),
        );
      },
      alignment: Alignment.centerRight,
      offset: Offset(10, 0),
      modal: true,
    );
  }

  void showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return WinLoginDialog(
          controller: WinLoginController(),
        );
      },
    );
  }
}

class Keep extends StatefulWidget {
  final Widget child;

  const Keep({Key? key, required this.child}) : super(key: key);

  @override
  State<Keep> createState() => _KeepState();
}

class _KeepState extends State<Keep> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
