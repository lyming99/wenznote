import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:wenznote/app/mobile/controller/settings/mobile_settings_controller.dart';
import 'package:wenznote/app/mobile/theme/mobile_theme.dart';
import 'package:wenznote/app/mobile/widgets/menu_group.dart';
import 'package:wenznote/commons/mvc/view.dart';
import 'package:wenznote/editor/widget/drop_menu.dart';
import 'package:wenznote/editor/widget/toggle_item.dart';

class MobileSettingsPage extends MvcView<MobileSettingsController> {
  const MobileSettingsPage({super.key, required super.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("设置"),
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(
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
                Obx(
                  () => _SimpleItemWidget(
                    icon: const Icon(
                      fluent.FluentIcons.clear_night,
                      size: 24,
                    ),
                    title: "主题模式",
                    content: controller.brightnessString,
                    onTap: (context) {
                      showBrightnessDropMenu(context);
                    },
                  ),
                ),
                Obx(
                  () => _SimpleItemWidget(
                    icon: const Icon(
                      fluent.FluentIcons.font_size,
                      size: 24,
                    ),
                    title: "字体大小",
                    content: controller.fontSizeString,
                    onTap: (context) {
                      showFontSizeDropMenu(context);
                    },
                  ),
                ),
                Obx(
                  () => _SimpleItemWidget(
                    icon: const Icon(
                      fluent.FluentIcons.folder,
                      size: 24,
                    ),
                    title: "存储路径",
                    content: controller.savePath.value,
                    onTap: (context) {
                      showSavePathDialog(context);
                    },
                  ),
                ),
                _SimpleItemWidget(
                  icon: const Icon(
                    fluent.FluentIcons.text_field,
                    size: 24,
                  ),
                  title: "同步密钥",
                  onTap: (context) {
                    openSyncPasswordPage(context);
                  },
                )
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
              const Expanded(
                child: Text(
                  "跟随系统",
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (controller.brightness.value == "system")
                const Icon(Icons.check),
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
              const Expanded(
                child: Text(
                  "日间模式",
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (controller.brightness.value == "light")
                const Icon(Icons.check),
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
              const Expanded(
                child: Text(
                  "夜间模式",
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (controller.brightness.value == "dark")
                const Icon(Icons.check),
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
              const Expanded(
                child: Text(
                  "小",
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (controller.fontSize.value == "minimal")
                const Icon(Icons.check),
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
              const Expanded(
                child: Text(
                  "中",
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (controller.fontSize.value == "medium")
                const Icon(Icons.check),
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
              const Expanded(
                child: Text(
                  "大",
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (controller.fontSize.value == "maximal")
                const Icon(Icons.check),
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

  void showSavePathDialog(BuildContext context) {
    controller.savePathEditController.text = controller.savePath.value;
    showDialog(
      context: context,
      useSafeArea: true,
      builder: (context) => _SavePathEditDialog(
        controller: controller,
      ),
    );
  }

  void openSyncPasswordPage(BuildContext context) {
    context.push("/mobile/settings/sync/password");
  }
}

class _SimpleItemWidget extends StatelessWidget {
  final Function(BuildContext context)? onTap;
  final Widget? icon;
  final String? title;
  final String? content;

  const _SimpleItemWidget({
    this.onTap,
    this.title,
    this.content,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: MobileTheme.of(context).mobileNavBgColor,
      leading: icon,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 240),
            child: Text(
              content ?? "",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.grey,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          const Icon(Icons.arrow_forward_ios_outlined),
        ],
      ),
      title: Text(title ?? ""),
      onTap: () {
        onTap?.call(context);
      },
    );
  }
}

class _SavePathEditDialog extends StatelessWidget {
  final MobileSettingsController controller;

  const _SavePathEditDialog({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return fluent.ContentDialog(
      constraints: (Platform.isIOS || Platform.isAndroid)
          ? const BoxConstraints(maxWidth: 300, maxHeight: 200)
          : const BoxConstraints(maxWidth: 320, maxHeight: 200),
      title: const Text("修改存储路径"),
      content: Column(
        children: [
          Expanded(child: Container()),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 5,
              ),
              Expanded(
                child: fluent.TextBox(
                  placeholder: "请选择存储路径",
                  readOnly: true,
                  controller: controller.savePathEditController,
                  suffix: ToggleItem(
                    onTap: (ctx) {
                      selectPath(ctx);
                    },
                    itemBuilder: (BuildContext context, bool checked,
                        bool hover, bool pressed) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 6),
                        child: Icon(
                          fluent.FluentIcons.more,
                          color: hover
                              ? Colors.grey.shade600
                              : Colors.grey.shade500,
                          size: 16,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
            ],
          ),
          Expanded(child: Container()),
        ],
      ),
      actions: [
        fluent.OutlinedButton(
          child: const Text("取消"),
          onPressed: () {
            context.pop();
          },
        ),
        fluent.FilledButton(
          child: const Text("确定"),
          onPressed: () {
            context.pop();
            doChangeSavePath(context);
          },
        ),
      ],
    );
  }

  void doChangeSavePath(BuildContext context) {
    var directory = controller.savePathEditController.text;
    if (!Directory(directory).existsSync()) {
      showInfo(context, '设置失败:', '文件夹不存在！');
      return;
    }
    if (Directory(directory).listSync().isNotEmpty) {
      showInfo(context, '设置失败:', '文件夹非空！');
      return;
    }
    var future = () async {
      await controller.changeSavePath(controller.savePathEditController.text);
      SchedulerBinding.instance.scheduleFrameCallback((timeStamp) {
        controller.serviceManager.restartService(context);
      });
    }();
    showDialog(
      context: context,
      builder: (context) => FutureProgressDialog(
        future,
        message: const Text("正在修改中..."),
      ),
    );
  }

  void showInfo(BuildContext ctx, String title, String content) {
    fluent.displayInfoBar(
      ctx,
      builder: (BuildContext context, void Function() close) {
        return fluent.InfoBar(
          title: Text(title),
          content: Text(content),
          action: IconButton(
            icon: const Icon(fluent.FluentIcons.clear),
            onPressed: close,
          ),
          severity: fluent.InfoBarSeverity.warning,
        );
      },
    );
  }

  Future<void> selectPath(BuildContext context) async {
    var directory = await getDirectoryPath(
        initialDirectory: controller.savePath.value, confirmButtonText: "选择");
    if (directory == null) {
      return;
    }
    var current = controller.savePath.value;
    var old = Directory(current).absolute.path;
    var select = Directory(directory).absolute.path;
    if (select.startsWith(old) && select != old) {
      showInfo(context, '文件选择错误:', '不能选择当前存储路径下的文件夹！');
      return;
    }
    controller.savePathEditController.text = directory;
  }
}
