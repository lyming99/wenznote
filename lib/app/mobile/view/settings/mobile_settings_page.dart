import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:wenznote/app/mobile/controller/settings/mobile_settings_controller.dart';
import 'package:wenznote/app/mobile/theme/mobile_theme.dart';
import 'package:wenznote/app/mobile/widgets/menu_group.dart';
import 'package:wenznote/commons/mvc/view.dart';
import 'package:wenznote/editor/widget/drop_menu.dart';

class MobileSettingsPage extends MvcView<MobileSettingsController> {
  const MobileSettingsPage({super.key, required super.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("设置"),
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: Icon(
            Icons.arrow_back,
            size: 24,
          ),
        ),
        backgroundColor: MobileTheme.of(context).mobileNavBgColor,
        foregroundColor: MobileTheme.of(context).fontColor,
        shadowColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildMenuGroup(
              context,
              ListTile.divideTiles(context: context, tiles: [
                // fluent.FluentIcons.crown,
                Builder(builder: (context) {
                  return ListTile(
                    tileColor: MobileTheme.of(context).mobileNavBgColor,
                    leading: Icon(
                      fluent.FluentIcons.clear_night,
                      size: 24,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Obx(() {
                          return Text(
                            controller.brightnessString,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.grey),
                          );
                        }),
                        SizedBox(
                          width: 8,
                        ),
                        Icon(Icons.arrow_forward_ios_outlined),
                      ],
                    ),
                    title: Text("夜间模式"),
                    onTap: () {
                      showBrightnessDropMenu(context);
                    },
                  );
                }),
                Builder(builder: (context) {
                  return ListTile(
                    tileColor: MobileTheme.of(context).mobileNavBgColor,
                    leading: Icon(
                      fluent.FluentIcons.font_size,
                      size: 24,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Obx(() {
                          return Text(
                            controller.fontSizeString,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.grey),
                          );
                        }),
                        SizedBox(
                          width: 8,
                        ),
                        Icon(Icons.arrow_forward_ios_outlined),
                      ],
                    ),
                    title: Text("字体大小"),
                    onTap: () {
                      showFontSizeDropMenu(context);
                    },
                  );
                }),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  void showBrightnessDropMenu(BuildContext context) {
    showDropMenu(
      context,
      childrenHeight: 48,
      childrenWidth: 160,
      popupAlignment: Alignment.bottomRight,
      overflowAlignment: Alignment.topRight,
      modal: true,
      menus: [
        DropMenu(
          text: Row(
            children: [
              Expanded(
                child: Text(
                  "跟随系统",
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (controller.brightness.value == "system") Icon(Icons.check),
            ],
          ),
          onPress: (ctx) {
            controller.brightness.value = "system";
            hideDropMenu(ctx);
          },
        ),
        DropMenu(
          text: Row(
            children: [
              Expanded(
                child: Text(
                  "日间模式",
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (controller.brightness.value == "light") Icon(Icons.check),
            ],
          ),
          onPress: (ctx) {
            controller.brightness.value = "light";
            hideDropMenu(ctx);
          },
        ),
        DropMenu(
          text: Row(
            children: [
              Expanded(
                child: Text(
                  "夜间模式",
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (controller.brightness.value == "dark") Icon(Icons.check),
            ],
          ),
          onPress: (ctx) {
            controller.brightness.value = "dark";
            hideDropMenu(ctx);
          },
        ),
      ],
    );
  }

  void showFontSizeDropMenu(BuildContext context) {
    showDropMenu(
      context,
      childrenHeight: 48,
      childrenWidth: 160,
      popupAlignment: Alignment.bottomRight,
      overflowAlignment: Alignment.topRight,
      modal: true,
      menus: [
        DropMenu(
          text: Row(
            children: [
              Expanded(
                child: Text(
                  "小",
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (controller.fontSize.value == "minimal") Icon(Icons.check),
            ],
          ),
          onPress: (ctx) {
            controller.fontSize.value = "minimal";
            hideDropMenu(ctx);
          },
        ),
        DropMenu(
          text: Row(
            children: [
              Expanded(
                child: Text(
                  "中",
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (controller.fontSize.value == "medium") Icon(Icons.check),
            ],
          ),
          onPress: (ctx) {
            controller.fontSize.value = "medium";
            hideDropMenu(ctx);
          },
        ),
        DropMenu(
          text: Row(
            children: [
              Expanded(
                child: Text(
                  "大",
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (controller.fontSize.value == "maximal") Icon(Icons.check),
            ],
          ),
          onPress: (ctx) {
            controller.fontSize.value = "maximal";
            hideDropMenu(ctx);
          },
        ),
      ],
    );
  }
}
