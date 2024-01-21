import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:wenznote/app/windows/controller/user/login.dart';
import 'package:wenznote/app/windows/controller/user/sign.dart';
import 'package:wenznote/app/windows/theme/colors.dart';
import 'package:wenznote/app/windows/view/user/sign.dart';
import 'package:wenznote/commons/mvc/view.dart';
import 'package:wenznote/service/service_manager.dart';
import 'package:oktoast/oktoast.dart';

class WinLoginDialog extends MvcView<WinLoginController> {
  const WinLoginDialog({
    super.key,
    required super.controller,
  });

  @override
  Widget build(BuildContext context) {
    return fluent.ContentDialog(
      constraints: BoxConstraints(
        minWidth: 320,
        minHeight: 240,
        maxWidth: 320,
      ),
      title: Text("登录"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          fluent.TextBox(
            placeholder: "邮箱/用户名",
            controller: controller.usernameController,
            prefix: Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(
                Icons.email_outlined,
                color: systemColor(context, "hintColor"),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          fluent.PasswordBox(
            placeholder: "密码",
            controller: controller.passwordController,
            leadingIcon: Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(
                Icons.key,
                color: systemColor(context, "hintColor"),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(child: Container()),
              TextButton(
                  onPressed: () {
                    openSignDialog(context);
                  },
                  child: Text("注册")),
              TextButton(
                  onPressed: () {
                    openForgetPasswordDialog(context);
                  },
                  child: Text("忘记密码?")),
            ],
          ),
        ],
      ),
      actions: [
        fluent.OutlinedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("取消"),
        ),
        fluent.FilledButton(
          onPressed: () {
            doLogin(context);
          },
          child: Text("登录"),
        ),
      ],
    );
  }

  void doLogin(BuildContext context) async {
    var result = false;
    await showDialog(
        useSafeArea: true,
        context: context,
        builder: (context) => FutureProgressDialog(
              message: const Text("正在登录中..."),
              () async {
                result = await controller.doLogin();
              }(),
            ));
    if (result == true) {
      showToast("登录成功！");
      ServiceManager.of(context).restartService();
    } else {
      showToast("登录失败！");
    }
  }

  void openSignDialog(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) {
        return WinSignDialog(
          controller: WinSignController(),
        );
      },
    );
  }

  void openForgetPasswordDialog(BuildContext context) {}
}
