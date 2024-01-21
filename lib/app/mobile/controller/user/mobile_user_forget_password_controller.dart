import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:wenznote/service/service_manager.dart';

class MobileUserForgetPasswordController extends ServiceManagerController {
  var usernameController = TextEditingController();
  var verifyCodeController = TextEditingController();
  var passwordController = TextEditingController();
  var verifyPasswordController = TextEditingController();
  var hasSend = false.obs;

  Future<bool> doUpdatePassword() async {
    bool result = await serviceManager.userService.updatePassword(usernameController.text,
        verifyCodeController.text, passwordController.text);
    return result;
  }

  Future<bool> sendEmailVerifyCode() async {
    return serviceManager.userService.sendSignCode(usernameController.text);
  }
}
