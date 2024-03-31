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
    return Scaffold(
      appBar: AppBar(
        title: Text("用户信息"),
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: Icon(
            Icons.arrow_back,
            size: 24,
          ),
        ),
        titleSpacing: 0,
        backgroundColor: MobileTheme.of(context).mobileNavBgColor,
        foregroundColor: MobileTheme.of(context).fontColor,
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
                  ListTile(
                    tileColor: MobileTheme.of(context).mobileNavBgColor,
                    title: const Text("邮箱",style: TextStyle(fontSize: 14),),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Obx(() {
                          return fluent.Container(
                            constraints: BoxConstraints(maxWidth: 180),
                            child: Text(
                              controller.email.value,
                              style: TextStyle(
                                color: MobileTheme.of(context)
                                    .fontColor
                                    .withAlpha(200),
                                fontSize: 14,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        }),
                        const SizedBox(
                          width: 8,
                        ),
                        const Icon(Icons.arrow_forward_ios_outlined),
                      ],
                    ),
                    onTap: () {
                      // showWarningDialog(context);
                    },
                  ),
                  ListTile(
                    tileColor: MobileTheme.of(context).mobileNavBgColor,
                    title: const Text("昵称",style: TextStyle(fontSize: 14),),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Obx(() {
                          return Container(
                            constraints: const BoxConstraints(maxWidth: 180),
                            child: Text(
                              controller.username.value,
                              style: TextStyle(
                                color: MobileTheme.of(context)
                                    .fontColor
                                    .withAlpha(200),
                                fontSize: 14,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        }),
                        const SizedBox(
                          width: 8,
                        ),
                        const Icon(Icons.arrow_forward_ios_outlined),
                      ],
                    ),
                    onTap: () {
                      showUpdateNicknameDialog(context);
                    },
                  ),
                  ListTile(
                    tileColor: MobileTheme.of(context).mobileNavBgColor,
                    title: const Text("个性签名",style: TextStyle(fontSize: 14),),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Obx(() {
                          return Container(
                            constraints: const BoxConstraints(maxWidth: 180),
                            child: Text(
                              controller.sign.value,
                              style: TextStyle(
                                color: MobileTheme.of(context)
                                    .fontColor
                                    .withAlpha(200),
                                fontSize: 14,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        }),
                        const SizedBox(
                          width: 8,
                        ),
                        const Icon(Icons.arrow_forward_ios_outlined),
                      ],
                    ),
                    onTap: () {
                      // controller.openBakView(context);
                      showUpdateSignDialog(context);
                    },
                  ),
                  ListTile(
                    tileColor: MobileTheme.of(context).mobileNavBgColor,
                    title: const Text("身份标识",style: TextStyle(fontSize: 14),),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Obx(() {
                          return fluent.Container(
                            constraints: const BoxConstraints(maxWidth: 180),
                            child: Text(
                              controller.userType.value,
                              style: TextStyle(
                                color: MobileTheme.of(context)
                                    .fontColor
                                    .withAlpha(200),
                                fontSize: 14,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        }),
                        const SizedBox(
                          width: 8,
                        ),
                        const Icon(Icons.arrow_forward_ios_outlined),
                      ],
                    ),
                    onTap: () {
                      // controller.openBakView(context);
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
                    tileColor: MobileTheme.of(context).mobileNavBgColor,
                    title: Text(
                      "退出登录",
                      style: TextStyle(color: Colors.red.shade400,fontSize: 14),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios_outlined),
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
          margin: const EdgeInsets.symmetric(
            vertical: 40,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
          ),
          clipBehavior: Clip.antiAlias,
          child: MobileUserIcon(size: 80,),
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
              constraints: BoxConstraints(
                minWidth: 320,
                maxWidth: 320,
              ),
              title: Text("修改签名"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  fluent.TextBox(
                    autofocus: true,
                    placeholder: "请输入个性签名",
                    maxLines: 2,
                    maxLength: 255,
                    controller: controller.signInfoController,
                  ),
                ],
              ),
              actions: [
                fluent.OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("取消"),
                ),
                fluent.FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    controller.updateSign();
                  },
                  child: Text("确定"),
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
              constraints: BoxConstraints(
                minWidth: 320,
                maxWidth: 320,
              ),
              title: Text("修改昵称"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  fluent.TextBox(
                    autofocus: true,
                    placeholder: "请输入昵称",
                    maxLines: 1,
                    maxLength: 16,
                    controller: controller.nicknameController,
                  ),
                ],
              ),
              actions: [
                fluent.OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("取消"),
                ),
                fluent.FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    controller.updateNickname();
                  },
                  child: Text("确定"),
                ),
              ],
            ),
          );
        });
  }
}
