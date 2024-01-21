import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wenznote/app/mobile/controller/user/mobile_user_header_controller.dart';
import 'package:wenznote/app/mobile/theme/mobile_theme.dart';
import 'package:wenznote/app/mobile/view/user/mobile_user_info_header.dart';
import 'package:wenznote/commons/mvc/view.dart';

import '../../controller/user/mobile_user_controller.dart';

class MobileUserPage extends MvcView<MobileUserController> {
  const MobileUserPage({super.key, required super.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: min(300, MediaQuery.of(context).size.width * 0.8),
      color: MobileTheme.of(context).mobileBgColor,
      child: Column(
        children: [
          MobileUserHeaderWidget(controller: MobileUserHeaderController()),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  buildCountInfo(context),
                  buildMenu(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCountInfo(BuildContext context) {
    return Container(
      height: 10,
    );
  }

  Widget buildMenu(BuildContext context) {
    return Column(
      children: [
        // 会员
        buildMenuGroup(
          context,
          ListTile.divideTiles(context: context, tiles: [
            // fluent.FluentIcons.crown,
            ListTile(
              tileColor: MobileTheme.of(context).mobileNavBgColor,
              leading: Icon(
                fluent.FluentIcons.info,
                size: 24,
              ),
              title: Text("预览版"),
              trailing: Icon(Icons.arrow_forward_ios_outlined),
              onTap: () {
                // controller.openBakView(context);
                // controller.openLifelongLearningPage();
                showDialog(
                    context: context,
                    builder: (context) {
                      return fluent.ContentDialog(
                        constraints: BoxConstraints(maxWidth: 300,),
                        content: Text("预览版，有些功能可能无法正常使用，不过可以加QQ群(568359924)反馈你想要用的功能~"),
                        title: Text("预览版"),
                        actions: [
                          fluent.FilledButton(
                            onPressed: () {
                              context.pop();
                            },
                            child: Text("知道了"),
                          )
                        ],
                      );
                    });
              },
            ),
          ]),
        ),
        //关于
        buildMenuGroup(
          context,
          ListTile.divideTiles(context: context, tiles: [
            ListTile(
              tileColor: MobileTheme.of(context).mobileNavBgColor,
              leading: Icon(
                fluent.FluentIcons.settings,
                size: 24,
              ),
              trailing: Icon(Icons.arrow_forward_ios_outlined),
              title: Text("设置"),
              onTap: () {
                controller.openSettingsPage();
              },
            ),
            ListTile(
              tileColor: MobileTheme.of(context).mobileNavBgColor,
              leading: Icon(
                fluent.FluentIcons.help,
                size: 24,
              ),
              trailing: Icon(Icons.arrow_forward_ios_outlined),
              title: Text("帮助"),
              onTap: () {
                // controller.openHelpPage();
                showDialog(
                    context: context,
                    builder: (context) {
                      return fluent.ContentDialog(
                        constraints: BoxConstraints(maxWidth: 300,),
                        content: Text("建设中~"),
                        title: Text("帮助"),
                        actions: [
                          fluent.FilledButton(
                            onPressed: () {
                              context.pop();
                            },
                            child: Text("知道了"),
                          )
                        ],
                      );
                    });
              },
            ),
            ListTile(
              tileColor: MobileTheme.of(context).mobileNavBgColor,
              leading: Icon(
                fluent.FluentIcons.location_outline,
                size: 24,
              ),
              trailing: Icon(Icons.arrow_forward_ios_outlined),
              title: Text("关于"),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: "温知笔记",
                  applicationVersion: "1.0.beta(预览版)",
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
          ]),
        ),
      ],
    );
  }

  Widget buildMenuGroup(BuildContext context, Iterable<Widget> widgets) {
    return Container(
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        child: Column(
          children: [
            ...widgets,
          ],
        ),
      ),
    );
  }
}
