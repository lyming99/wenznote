import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:get/get.dart';
import 'package:note/app/windows/controller/user/login.dart';
import 'package:note/app/windows/controller/user/sign.dart';
import 'package:note/app/windows/theme/colors.dart';
import 'package:note/app/windows/view/user/login.dart';
import 'package:note/commons/mvc/view.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:oktoast/oktoast.dart';

class WinSignDialog extends MvcView<WinSignController> {
  const WinSignDialog({
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
      title: Text("注册"),
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
                color: systemColor(context,"hintColor"),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                child: fluent.TextBox(
                  placeholder: "邮箱验证码",
                  controller: controller.codeController,
                  prefix: Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.sms_sharp,
                      color: systemColor(context,"hintColor"),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 5,
              ),
              Obx(() {
                return fluent.FilledButton(
                  onPressed: (controller.sendEnable.isFalse)
                      ? null
                      : () {
                          if (controller.sendEnable.isTrue) {
                            sendCode(context);
                          }
                        },
                  child: Text(controller.sendEnable.isTrue ? "发送" : "已发送"),
                );
              }),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          fluent.PasswordBox(
            placeholder: "密码",
            controller: controller.password1Controller,
            leadingIcon: Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(
                Icons.key,
                color: systemColor(context,"hintColor"),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          fluent.PasswordBox(
            placeholder: "再次输入密码",
            controller: controller.password2Controller,
            leadingIcon: Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(
                Icons.key,
                color: systemColor(context,"hintColor"),
              ),
            ),
          ),
        ],
      ),
      actions: [
        fluent.OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (context) {
                return WinLoginDialog(
                  controller: WinLoginController(),
                );
              },
            );
          },
          child: Text("取消"),
        ),
        fluent.FilledButton(
          onPressed: () {
            doSign(context);
          },
          child: Text("注册"),
        ),
      ],
    );
  }

  void doSign(BuildContext context) async {
    var result = false;
    await showDialog(
        useSafeArea: true,
        context: context,
        builder: (context) => FutureProgressDialog(
              message: const Text("正在注册中..."),
              () async {
                result = await controller.doSign();
              }(),
            ));
    if (result == true) {
      showToast("注册成功！");
      Navigator.of(context).pop();
    } else {
      showToast("注册失败！");
    }
  }

  void sendCode(BuildContext context) async {
    controller.sendEnable.value = false;
    var sendResult = await controller.sendCode();
    if (sendResult) {
      showToast("发送成功！");
    } else {
      controller.sendEnable.value = true;
      showToast("发送失败！");
    }
  }
}
