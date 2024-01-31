import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:window_manager/window_manager.dart';

import 'app/app.dart';
import 'commons/service/device_utils.dart';

Future<void> loadResources() async {
  await readDeviceInfo();
  if (isDesktop) {
    await flutter_acrylic.Window.initialize();
    await flutter_acrylic.Window.hideWindowControls();
    await WindowManager.instance.ensureInitialized();
    if (isWin11()) {
      await flutter_acrylic.Window.setEffect(
        effect: flutter_acrylic.WindowEffect.acrylic,
        color: Colors.transparent,
        dark: false,
      );
    }
    windowManager.waitUntilReadyToShow(
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
      if (isCustomWindowBorder()) {
        await windowManager.setAsFrameless();
      }
      await windowManager.show();
    });
  }
}

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadResources();
  runApp(
    AppWidget(
      controller: AppController(),
    ),
  );
}
