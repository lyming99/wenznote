import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:wenznote/app/mobile/controller/user/mobile_user_info_controller.dart';
import 'package:wenznote/app/mobile/controller/user/mobile_user_login_controller.dart';
import 'package:wenznote/app/mobile/view/user/mobile_user_icon.dart';
import 'package:wenznote/app/mobile/view/user/mobile_user_info_page.dart';
import 'package:wenznote/app/mobile/view/user/mobile_user_login_page.dart';
import 'package:wenznote/app/windows/controller/home/win_home_controller.dart';
import 'package:wenznote/app/windows/view/card/win_card_set_page.dart';
import 'package:wenznote/app/windows/view/doc/win_doc_page.dart';
import 'package:wenznote/app/windows/view/today/win_today_page.dart';
import 'package:wenznote/app/windows/widgets/win_tab_view.dart';
import 'package:wenznote/commons/mvc/view.dart';
import 'package:wenznote/commons/util/device_utils.dart';
import 'package:wenznote/commons/widget/split_pane.dart';
import 'package:wenznote/commons/widget/window_buttons.dart';
import 'package:wenznote/editor/widget/drop_menu.dart';
import 'package:wenznote/editor/widget/toggle_item.dart';
import 'package:wenznote/widgets/mac_window_button.dart';
import 'package:window_manager/window_manager.dart';

class WinHomePage extends MvcView<WinHomeController> {
  const WinHomePage({super.key, required super.controller});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          child: buildAppContent(context),
        ),
        buildAppBar(context),
      ],
    );
  }

  Widget buildAppBar(BuildContext context) {
    return SizedBox(
      height: 32,
      child: Obx(() {
        return Row(
          children: [
            if (Platform.isMacOS && controller.showNavPage.isTrue)
              SizedBox(
                width: 60,
              ),
            Expanded(
                child: controller.showNavPage.isTrue
                    ? DragToMoveArea(child: Container())
                    : Container()),
            if (Platform.isWindows) const WindowButtons(),
          ],
        );
      }),
    );
  }

  /// app内容：导航栏(左) + 一级内容(中) + 二级内容(右)
  Widget buildAppContent(BuildContext context) {
    return Obx(() {
      return Row(
        children: [
          if (!Platform.isMacOS && controller.showNavPage.value)
            buildWindowsNavBar(context),
          if (Platform.isMacOS && controller.showNavPage.value)
            buildWindowsNavBar(context),
          Expanded(
            child: buildPage(context),
          ),
        ],
      );
    });
  }

  /// 导航栏
  Widget buildWindowsNavBar(BuildContext context) {
    var theme = fluent.FluentTheme.of(context);
    return Container(
      width: 60,
      color: isWin11()
          ? theme.resources.solidBackgroundFillColorBase
          : theme.resources.systemFillColorSolidNeutralBackground,
      child: Column(
        children: [
          buildMacWindowButton(context),
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
                child: MobileUserIcon(),
              ),
              if (controller.isLogin)
                Obx(
                  () => Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      width: 10,
                      height: 10,
                      margin: EdgeInsets.only(right: 2),
                      decoration: BoxDecoration(
                        color: controller.isConnected
                            ? Colors.greenAccent
                            : Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
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
    var theme = fluent.FluentTheme.of(context);
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
                        ? theme.resources.textFillColorSecondary
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
    var theme = fluent.FluentTheme.of(context);
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
                    Icons.edit_document,
                    size: 24,
                    color: controller.navIndex.value != 1
                        ? theme.resources.textFillColorSecondary
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
    var theme = fluent.FluentTheme.of(context);
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
                    Icons.card_giftcard,
                    size: 24,
                    color: controller.navIndex.value != 2
                        ? theme.resources.textFillColorSecondary
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

  ///主页分割内容界面：导航|内容
  Widget buildPage(BuildContext context) {
    return Obx(() {
      if (controller.showNavPage.isFalse) {
        return buildEditTabsPane(context);
      }
      return SplitPane(
        primaryIndex: PaneIndex.one,
        primaryMinSize: 240,
        subMinSize: 340,
        onlyShowIndex: controller.showEditPane.value ? null : PaneIndex.one,
        one: buildNavPane(context),
        two: buildEditTabsPane(context),
      );
    });
  }

  ///导航内容：今天、笔记、卡片
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

  ///今天列表界面
  Widget buildTodayPage(BuildContext context) {
    var theme = fluent.FluentTheme.of(context);
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
                  color: theme.resources.solidBackgroundFillColorTertiary,
                  border: Border(
                    left: BorderSide(
                      color: theme.resources.cardStrokeColorDefaultSolid,
                    ),
                    right: BorderSide(
                      color: theme.resources.cardStrokeColorDefaultSolid,
                    ),
                  ),
                ),
                child: WinTodayPage(
                  controller: controller.todayController,
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

  /// 编辑列表页面
  Widget buildNotePage(BuildContext context) {
    var theme = fluent.FluentTheme.of(context);
    return Container(
        decoration: BoxDecoration(
          color: theme.resources.solidBackgroundFillColorTertiary,
          border: Border(
            left: BorderSide(
              color: theme.resources.cardStrokeColorDefaultSolid,
            ),
            right: BorderSide(
              color: theme.resources.cardStrokeColorDefaultSolid,
            ),
          ),
        ),
        child: WinDocPage(
          controller: controller.docController,
        ));
  }

  /// 卡片列表页面
  Widget buildCardPage(BuildContext context) {
    var theme = fluent.FluentTheme.of(context);
    return Container(
        decoration: BoxDecoration(
          color: theme.resources.solidBackgroundFillColorTertiary,
          border: Border(
            left: BorderSide(
              color: theme.resources.cardStrokeColorDefaultSolid,
            ),
            right: BorderSide(
              color: theme.resources.cardStrokeColorDefaultSolid,
            ),
          ),
        ),
        child: WinCardSetPage(
          controller: controller.cardController,
        ));
  }

  /// 编辑区域,多标签界面
  Widget buildEditTabsPane(BuildContext context) {
    var theme = fluent.FluentTheme.of(context);
    return Material(
      color: theme.resources.solidBackgroundFillColorSecondary,
      child: Container(
        padding: controller.showNavPage.isTrue
            ? EdgeInsets.only(top: Platform.isMacOS ? 26 : 30)
            : null,
        child: WinTabView(
          controller: controller.tabController,
        ),
      ),
    );
  }

  /// 侧边导航栏菜单按钮
  Widget buildNavMenu(BuildContext context) {
    var theme = fluent.FluentTheme.of(context);
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
                color: theme.resources.textFillColorSecondary,
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
                context.push("/windows/import");
              },
            ),
            DropMenu(
              text: Text("导出笔记"),
              onPress: (ctx) {
                hideDropMenu(ctx);
                context.push("/windows/export");
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
              applicationVersion: "1.0",
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
    var shadowColor =
        fluent.FluentTheme.of(context).resources.cardStrokeColorDefault;
    showCustomDropMenu(
      context: context,
      width: 360,
      height: 500,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
            borderRadius: BorderRadius.circular(10),
          ),
          clipBehavior: Clip.antiAlias,
          child: MobileUserInfoPage(controller: MobileUserInfoController()),
        );
      },
      alignment: Alignment.centerRight,
      offset: Offset(10, 0),
      modal: true,
    );
  }

  void showLoginDialog(BuildContext context) {
    var shadowColor =
        fluent.FluentTheme.of(context).resources.cardStrokeColorDefault;
    showCustomDropMenu(
      context: context,
      width: 360,
      height: 500,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
            borderRadius: BorderRadius.circular(10),
          ),
          clipBehavior: Clip.antiAlias,
          child: MobileUserLoginPage(controller: MobileUserLoginController()),
        );
      },
      alignment: Alignment.centerRight,
      offset: Offset(10, 0),
      modal: true,
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
