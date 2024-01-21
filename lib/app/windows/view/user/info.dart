import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:wenznote/app/windows/controller/user/info.dart';
import 'package:wenznote/commons/mvc/view.dart';
import 'package:wenznote/editor/widget/drop_menu.dart';

class WinUserInfoDialog extends MvcView<WinUserInfoController> {
  const WinUserInfoDialog({
    super.key,
    required super.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          //user name,user icon
          buildUserNameWidget(context),
          // 登录状态：在线、离线
          buildNetStatusWidget(context),
          // 订阅状态，到期时间，订阅/续订
          buildVipStatusWidget(context),
          Expanded(child: Container()),
          // 编辑信息按钮，退出登录按钮，切换账号按钮
          buildActionButtonWidget(context),
        ],
      ),
    );
  }

  Widget buildUserNameWidget(BuildContext context) {
    return Row(
      children: [
        Container(
            margin: EdgeInsets.all(10),
            width: 50,
            height: 50,
            child: FlutterLogo()),
        Text("${controller.getUserName()}"),
      ],
    );
  }

  Widget buildVipStatusWidget(BuildContext context) {
    // 订阅状态，到期时间，订阅/续订
    return Container(
      margin: EdgeInsets.all(10),
      child: Row(
        children: [
          Text("订阅状态: 未订阅"),
        ],
      ),
    );
  }

  Widget buildNetStatusWidget(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Row(
        children: [
          Text("状态：在线"),
        ],
      ),
    );
  }

  Widget buildActionButtonWidget(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          fluent.FilledButton(
            onPressed: () {
              hideDropMenu(context);
              controller.logout(context);
            },
            child: Text("退出登录"),
          ),
        ],
      ),
    );
  }
}
