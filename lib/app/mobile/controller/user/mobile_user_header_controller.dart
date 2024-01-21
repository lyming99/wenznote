import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:wenznote/service/service_manager.dart';

class MobileUserHeaderController extends ServiceManagerController {
  var avatar = "".obs;

  Image getUserIcon() {
    if (File(avatar.value).existsSync()) {
      return Image.file(File(avatar.value));
    }
    return Image.asset(
      "assets/images/app_logo.png",
    );
  }

  bool get hasLogin => serviceManager.userService.hasLogin;

  String? get userName =>
      serviceManager.userService.currentUser?.nickname ??
      serviceManager.userService.currentUser?.username ??
      serviceManager.userService.currentUser?.email;

  String? get userNote => serviceManager.userService.currentUser?.sign;

  void openLoginPage() {
    Scaffold.of(context).closeDrawer();
    Timer(200.milliseconds, () {
      context.push("/mobile/login");
    });
  }

  void openUserInfoPage() {
    Scaffold.of(context).closeDrawer();
    Timer(200.milliseconds, () {
      context.push("/mobile/userInfo");
    });
  }
  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    fetchData();
  }
  Future<void> fetchData()async{
    avatar.value = await serviceManager.userService.getAvatarFile();
  }
}
