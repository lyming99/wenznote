import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:wenznote/app/mobile/controller/settings/mobile_settings_controller.dart';
import 'package:wenznote/app/mobile/controller/settings/mobile_sync_password_settings_controller.dart';
import 'package:wenznote/app/mobile/theme/mobile_theme.dart';
import 'package:wenznote/app/mobile/widgets/menu_group.dart';
import 'package:wenznote/commons/mvc/view.dart';
import 'package:wenznote/editor/widget/toggle_item.dart';

class MobileSyncPasswordSettingsPage
    extends MvcView<MobileSyncPasswordSettingsController> {
  const MobileSyncPasswordSettingsPage({super.key, required super.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("修改同步密钥"),
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
                _SimpleItemWidget(
                  title: "查看当前密钥",
                  onTap: (context) {
                    showPwdDialog(context);
                  },
                ),
                _SimpleItemWidget(
                  title: "生成随机密钥",
                  onTap: (context) {
                    showGeneratePwdDialog(context);
                  },
                ),
                _SimpleItemWidget(
                  title: "通过密码生成密钥",
                  onTap: (context) {
                    showInputPwdDialog(context);
                  },
                ),
                _SimpleItemWidget(
                  title: "导入密钥",
                  onTap: (context) {
                    showImportPwdDialog(context);
                  },
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  void showPwdDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return fluent.ContentDialog(
          title: const Text("当前密钥"),
          content: Text(controller.hasPwd
              ? "密钥版本:${controller.pwdVersion}\n密钥:${controller.pwd}\nsha256:${controller.pwdSha256}"
              : "未设置密钥"),
          actions: [
            fluent.OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("取消"),
            ),
            fluent.FilledButton(
              onPressed: controller.hasPwd
                  ? () {
                      Navigator.of(context).pop();
                      controller.copyPwd();
                    }
                  : null,
              child: const Text("复制密钥"),
            ),
          ],
        );
      },
    );
  }

  void showGeneratePwdDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (context) {
        return fluent.ContentDialog(
          title: const Text("生成随机密钥"),
          constraints: const BoxConstraints(maxWidth: 300, maxHeight: 240),
          content: const Text("是否生成随机密钥？"),
          actions: [
            fluent.OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("取消"),
            ),
            fluent.FilledButton(
              onPressed: () {
                context.pop();
                var pwd = controller.generateRandomPwd();
                showChangePwdProgressDialog(ctx, pwd);
              },
              child: const Text("确定"),
            ),
          ],
        );
      },
    );
  }

  void showInputPwdDialog(BuildContext ctx) {
    controller.pwdInput1Controller.text = "";
    controller.pwdInput2Controller.text = "";
    showDialog(
      context: ctx,
      builder: (context) {
        return fluent.ContentDialog(
          title: const Text("通过密码生成密钥"),
          constraints: const BoxConstraints(maxWidth: 300, maxHeight: 240),
          content: fluent.Column(
            children: [
              fluent.TextBox(
                placeholder: "请输入密码",
                controller: controller.pwdInput1Controller,
                onChanged: (value) {},
              ),
              const SizedBox(
                height: 10,
              ),
              fluent.TextBox(
                placeholder: "请再次输入密码",
                controller: controller.pwdInput2Controller,
                onChanged: (value) {},
              ),
            ],
          ),
          actions: [
            fluent.OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("取消"),
            ),
            fluent.FilledButton(
              onPressed: () {
                if (controller.pwdInput1Controller.text.isEmpty) {
                  showDialog(
                      context: ctx,
                      builder: (context) {
                        return fluent.ContentDialog(
                          title: const Text("密码不能为空"),
                          content: const Text("请重新输入密码"),
                          actions: [
                            fluent.OutlinedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("确定"),
                            ),
                          ],
                        );
                      });
                  return;
                }
                if (controller.pwdInput1Controller.text !=
                    controller.pwdInput2Controller.text) {
                  showDialog(
                      context: ctx,
                      builder: (context) {
                        return fluent.ContentDialog(
                          title: const Text("密码不一致"),
                          content: const Text("请重新输入密码"),
                          actions: [
                            fluent.OutlinedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("确定"),
                            ),
                          ],
                        );
                      });
                  return;
                }
                context.pop();
                var pwd =
                    controller.generatePwd(controller.pwdInput1Controller.text);
                showChangePwdProgressDialog(ctx, pwd);
              },
              child: const Text("确定"),
            ),
          ],
        );
      },
    );
  }

  void showImportPwdDialog(BuildContext ctx) {
    controller.pwdInput1Controller.text = "";
    showDialog(
      context: ctx,
      builder: (context) {
        return fluent.ContentDialog(
          title: const Text("导入密钥"),
          constraints: const BoxConstraints(maxWidth: 300, maxHeight: 240),
          content: fluent.TextBox(
            placeholder: "请粘贴密钥内容",
            controller: controller.pwdInput1Controller,
            maxLines: 3,
            onChanged: (value) {},
          ),
          actions: [
            fluent.OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("取消"),
            ),
            fluent.FilledButton(
              onPressed: () {
                if (controller.pwdInput1Controller.text.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return fluent.ContentDialog(
                        title: const Text("密钥不能为空"),
                        content: const Text("请重新输入密钥"),
                        actions: [
                          fluent.OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("确定"),
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }
                context.pop();
                showChangePwdProgressDialog(
                    ctx, controller.pwdInput1Controller.text);
              },
              child: const Text("确定"),
            ),
          ],
        );
      },
    );
  }

  void showChangePwdProgressDialog(BuildContext context, String pwd) async {
    var future = controller.changePwd(pwd);
    var value = await showDialog(
      context: context,
      builder: (context) {
        return FutureProgressDialog(future, message: const Text("正在更新密钥"));
      },
    );
    if (value) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        showChangeSuccessDialog(context);
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        showChangeFailDialog(context);
      });
    }
  }

  void showChangeSuccessDialog(fluent.BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return fluent.ContentDialog(
          title: const Text("提示"),
          content: const Text("密钥更新成功"),
          actions: [
            fluent.OutlinedButton(
              onPressed: () {
                context.pop();
              },
              child: const Text("取消"),
            ),
            fluent.FilledButton(
              onPressed: () {
                context.pop();
                showPwdDialog(context);
              },
              child: const Text("查看密钥"),
            ),
          ],
        );
      },
    );
  }

  void showChangeFailDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return fluent.ContentDialog(
              title: const Text("提示"),
              content: const Text("密钥更新失败"),
              actions: [
                fluent.OutlinedButton(
                  onPressed: () {
                    context.pop();
                  },
                  child: const Text("确定"),
                ),
              ]);
        });
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
