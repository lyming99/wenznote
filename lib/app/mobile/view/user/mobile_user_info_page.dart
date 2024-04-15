import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:wenznote/app/mobile/controller/user/mobile_user_info_controller.dart';
import 'package:wenznote/app/mobile/theme/mobile_theme.dart';
import 'package:wenznote/app/mobile/widgets/menu_group.dart';
import 'package:wenznote/commons/mvc/view.dart';

import 'mobile_user_icon.dart';

class MobileUserInfoPage extends MvcView<MobileUserInfoController> {
  const MobileUserInfoPage({super.key, required super.controller});

  @override
  Widget build(BuildContext context) {
    var backgroundColor = MobileTheme.of(context).mobileNavBgColor;
    var fontColor = MobileTheme.of(context).fontColor;
    return Scaffold(
      appBar: AppBar(
        title: const Text("用户信息"),
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(
            Icons.arrow_back,
            size: 24,
          ),
        ),
        titleSpacing: 0,
        backgroundColor: backgroundColor,
        foregroundColor: fontColor,
        shadowColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildUserIconEdit(context),
            buildMenuGroup(
              context,
              ListTile.divideTiles(
                context: context,
                tiles: [
                  buildUserInfoTile(
                    context,
                    "邮箱",
                    controller.email,
                    Icons.arrow_forward_ios_outlined,
                    () {},
                  ),
                  buildUserInfoTile(
                    context,
                    "昵称",
                    controller.username,
                    Icons.arrow_forward_ios_outlined,
                    () {
                      showUpdateNicknameDialog(context);
                    },
                  ),
                  buildUserInfoTile(
                    context,
                    "个性签名",
                    controller.sign,
                    Icons.arrow_forward_ios_outlined,
                    () {
                      showUpdateSignDialog(context);
                    },
                  ),
                  buildUserInfoTile(
                    context,
                    "会员订阅",
                    controller.vipLimitTime,
                    Icons.arrow_forward_ios_outlined,
                    () {
                      showRechargeDialog(context);
                    },
                  ),
                ],
              ),
            ),
            buildMenuGroup(
              context,
              ListTile.divideTiles(
                context: context,
                tiles: [
                  ListTile(
                    tileColor: backgroundColor,
                    title: Text(
                      "退出登录",
                      style:
                          TextStyle(color: Colors.red.shade400, fontSize: 14),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_outlined),
                    onTap: () {
                      controller.logout();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildUserIconEdit(BuildContext context) {
    return InkWell(
      onTap: () {
        controller.selectUserIconImage();
      },
      child: Center(
        child: Container(
          width: 80,
          height: 80,
          margin: const EdgeInsets.symmetric(vertical: 40),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
          clipBehavior: Clip.antiAlias,
          child: const MobileUserIcon(size: 80),
        ),
      ),
    );
  }

  void showUpdateSignDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return Container(
            padding: MediaQuery.of(context).viewInsets,
            child: fluent.ContentDialog(
              constraints: BoxConstraints(minWidth: 320, maxWidth: 320),
              title: const Text("修改签名"),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  fluent.TextBox(
                    autofocus: true,
                    placeholder: "请输入个性签名",
                    maxLines: 2,
                    maxLength: 255,
                  ),
                ],
              ),
              actions: [
                fluent.OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("取消"),
                ),
                fluent.FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    controller.updateSign();
                  },
                  child: const Text("确定"),
                ),
              ],
            ),
          );
        });
  }

  void showUpdateNicknameDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return Container(
            padding: MediaQuery.of(context).viewInsets,
            child: fluent.ContentDialog(
              constraints: BoxConstraints(minWidth: 320, maxWidth: 320),
              title: const Text("修改昵称"),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  fluent.TextBox(
                    autofocus: true,
                    placeholder: "请输入昵称",
                    maxLines: 1,
                    maxLength: 16,
                  ),
                ],
              ),
              actions: [
                fluent.OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("取消"),
                ),
                fluent.FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    controller.updateNickname();
                  },
                  child: const Text("确定"),
                ),
              ],
            ),
          );
        });
  }

  Widget buildUserInfoTile(BuildContext context, String title, RxString value,
      IconData? trailingIcon, VoidCallback? onTap) {
    var backgroundColor = MobileTheme.of(context).mobileNavBgColor;
    var fontColor = MobileTheme.of(context).fontColor;
    return ListTile(
      tileColor: backgroundColor,
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: trailingIcon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(
                  () => Container(
                    constraints: const BoxConstraints(maxWidth: 180),
                    child: Text(
                      value.value,
                      style: TextStyle(
                        color: fontColor.withAlpha(200),
                        fontSize: 14,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(trailingIcon),
              ],
            )
          : null,
      onTap: onTap,
    );
  }

  void showRechargeDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (ctx) {
          return Container(
            padding: MediaQuery.of(context).viewInsets,
            child: fluent.ContentDialog(
              constraints: const BoxConstraints(minWidth: 320, maxWidth: 320),
              title: const Text("会员订阅"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                      "订阅会员后，您可以享受更多云存储空间，目前仅支持CKEY码兑换，兑换后CKEY码将失效，请妥善保存。\n"),
                  fluent.TextBox(
                    autofocus: true,
                    placeholder: "请输入CKEY码进行兑换",
                    maxLines: 1,
                    maxLength: 255,
                    controller: controller.ckeyEditController,
                  ),
                ],
              ),
              actions: [
                fluent.OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("取消"),
                ),
                fluent.FilledButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    var result = await controller.recharge();
                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                      showResultDialog(context, result);
                    });
                  },
                  child: const Text("确定"),
                ),
              ],
            ),
          );
        });
  }

  void showResultDialog(BuildContext context, bool result) {
    showDialog(
        context: context,
        builder: (ctx) {
          return Container(
            padding: MediaQuery.of(context).viewInsets,
            child: fluent.ContentDialog(
              constraints: const BoxConstraints(minWidth: 320, maxWidth: 320),
              title: const Text("会员订阅"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    result ? "订阅成功" : "订阅失败",
                  ),
                ],
              ),
              actions: [
                fluent.FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("确定"),
                ),
              ],
            ),
          );
        });
  }
}
