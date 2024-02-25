import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wenznote/service/service_manager.dart';

class MobileUserLoginController extends ServiceManagerController {
  var usernameController = TextEditingController();
  var passwordController = TextEditingController();

  Future<bool> doLogin() async {
    bool result = await serviceManager.userService.login(
        email: usernameController.text, password: passwordController.text);
    return result;
  }

  void openSignPage() {
    context.push("/mobile/sign");
  }

  void openForgetPasswordPage() {
    context.push("/mobile/forgetPassword");
  }

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    usernameController.addListener(() {
      serviceManager.configManager
          .saveConfig("lastLoginUser", usernameController.text);
    });
    fetchData();
  }

  Future<void> fetchData() async {
    usernameController.text =
        await serviceManager.configManager.readConfig("lastLoginUser", "");
  }
}
