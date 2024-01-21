import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:wenznote/app/mobile/controller/user/mobile_user_forget_password_controller.dart';
import 'package:wenznote/app/mobile/theme/mobile_theme.dart';
import 'package:wenznote/commons/mvc/view.dart';
import 'package:oktoast/oktoast.dart';

class MobileUserForgetPasswordPage
    extends MvcView<MobileUserForgetPasswordController> {
  const MobileUserForgetPasswordPage({super.key, required super.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("忘记密码"),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 30,
            ),
            buildLogo(),
            SizedBox(
              height: 30,
            ),
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 4,
              ),
              child: TextField(
                controller: controller.usernameController,
                autofocus: true,
                decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.email_outlined,
                    ),
                    hintText: "请输入邮箱"),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 4,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      child: TextField(
                        controller: controller.verifyCodeController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.sms_sharp,
                          ),
                          hintText: "请输入邮箱验证码",
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Obx(
                    () => fluent.FilledButton(
                      style: fluent.ButtonStyle(
                        padding: fluent.ButtonState.all(
                          EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 20,
                          ),
                        ),
                      ),
                      onPressed: controller.hasSend.isTrue
                          ? null
                          : () {
                              doSendEmailVerifyCode(context);
                            },
                      child: Text(controller.hasSend.isTrue ? "已发送" : "发送"),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 4,
              ),
              child: TextField(
                obscureText: true,
                controller: controller.passwordController,
                decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.key,
                    ),
                    hintText: "请输入新密码"),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 20,
              ),
              width: double.infinity,
              child: fluent.FilledButton(
                style: fluent.ButtonStyle(
                  padding: fluent.ButtonState.all(
                    EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                  ),
                ),
                onPressed: () {
                  doUpdatePassword(context);
                },
                child: Text("修改密码"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 60,
        ),
        Container(
          width: 60,
          height: 60,
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            "assets/images/app_logo.png",
          ),
        ),
        Container(
          alignment: Alignment.topLeft,
          width: 60,
          height: 60,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              "预览版",
              style: TextStyle(
                fontSize: 10,
                color: Colors.white,
              ),
            ),
          ),
        )
      ],
    );
  }

  void doSendEmailVerifyCode(BuildContext context) async {
    controller.hasSend.value = true;
    var result = await controller.sendEmailVerifyCode();
    if (result) {
      showToast("发送成功！");
    } else {
      controller.hasSend.value = false;
      showToast("发送失败，请稍后再试！");
    }
  }

  void doUpdatePassword(BuildContext context) async {
    var result = false;
    var future = () async {
      result = await controller.doUpdatePassword();
      return result;
    }();
    await showDialog(
        context: context,
        builder: (context) {
          return FutureProgressDialog(
            message: const Text("正在修改中..."),
            future,
          );
        });
    if (result == true) {
      showToast("修改成功！");
      Navigator.of(context).pop();
    } else {
      showToast("修改失败！");
    }
  }
}
