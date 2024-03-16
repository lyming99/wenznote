import 'package:flutter/material.dart';
import 'package:wenznote/test/service_test.dart';
import 'package:window_manager/window_manager.dart';
import 'app/app.dart';
import 'commons/util/device_utils.dart';
import 'commons/util/log_util.dart';

Future<void> loadResources() async {
  printLog("readDeviceInfo start");
  await readDeviceInfo();
  printLog("readDeviceInfo end");
  if (isDesktop) {
    printLog("init windowManager start");
    await windowManager.ensureInitialized();
    printLog("waitUntilReadyToShow start");
    await windowManager.waitUntilReadyToShow(
        const WindowOptions(
          size: Size(800, 560),
          center: true,
          skipTaskbar: false,
          minimumSize: Size(720, 480),
          title: "温知笔记",
          titleBarStyle: TitleBarStyle.hidden,
          windowButtonVisibility: false,
          backgroundColor: Colors.transparent,
        ), () async {
      printLog("isCustomWindowBorder start");
      if (isCustomWindowBorder()) {
        printLog("setAsFrameless start");
        await windowManager.setAsFrameless();
      }
      printLog("windowManager show start");
      await windowManager.show();
      printLog("windowManager show end");
    });
  }
}

const test = false;

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  printLog("loadResources start");
  await loadResources();
  printLog("loadResources end");
  if (test) {
    await testService();
    return;
  }
  printLog("runApp start");
  runApp(
    AppWidget(
      controller: AppController(),
    ),
  );
  printLog("runApp end");
}
