import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:wenznote/app/mobile/controller/user/mobile_user_login_controller.dart';
import 'package:wenznote/app/mobile/theme/mobile_theme.dart';
import 'package:wenznote/commons/mvc/view.dart';
import 'package:oktoast/oktoast.dart';

class MobileUserLoginPage extends MvcView<MobileUserLoginController> {
  const MobileUserLoginPage({super.key, required super.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("登录"),
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
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 30,
          ),
          Row(
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
          ),
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
              ),
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
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(child: Container()),
                TextButton(
                    onPressed: () {
                      controller.openSignPage();
                    },
                    child: Text("注册")),
                TextButton(
                    onPressed: () {
                      controller.openForgetPasswordPage();
                    },
                    child: Text("忘记密码?")),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(
              vertical: 5,
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
              onPressed: () async {
                doLogin(context);
              },
              child: Text("登录"),
            ),
          ),
        ],
      ),
    );
  }

  void doLogin(BuildContext context) async {
    var result = false;
    var future = () async {
      result = await controller.doLogin();
    }();
    await showDialog(
        useSafeArea: true,
        context: context,
        builder: (context) => FutureProgressDialog(
              message: const Text("正在登录中..."),
              future,
            ));
    if (result == true) {
      showToast("登录成功！");
    } else {
      showToast("登录失败！");
    }
  }
}
