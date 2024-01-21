import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:wenznote/service/service_manager.dart';
import 'package:wenznote/service/user/user_service.dart';

class MobileUserController extends ServiceManagerController {
  var accountName = "lyming".obs;

  var accountEmail = "".obs;
  late UserService userService;

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    userService = serviceManager.userService;
    fetchData();
  }

  Future<void> fetchData() async {
    accountEmail.value = userService.currentUser?.email ?? "";
  }

  void logout() async {
    await userService.logout();
    await serviceManager.restartService();
    SchedulerBinding.instance.scheduleFrameCallback((timeStamp) {
      GoRouter.of(context).go("/mobile/today");
    });
  }

  void openSettingsPage() {
    Scaffold.of(context).closeDrawer();
    Timer(200.milliseconds,(){
      context.push("/mobile/settings");
    });
  }

  void openHelpPage() {
    Scaffold.of(context).closeDrawer();
    Timer(200.milliseconds,(){
      context.push("/mobile/help");
    });
  }

  void openLifelongLearningPage() {
    Scaffold.of(context).closeDrawer();
    Timer(200.milliseconds,(){
      context.push("/mobile/lifelongLearning");
    });
  }
}
