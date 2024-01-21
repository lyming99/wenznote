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
    await windowManager.center();
    await windowManager.waitUntilReadyToShow();
    await windowManager.setTitle("温知笔记");
    await windowManager.setTitleBarStyle(
      TitleBarStyle.hidden,
      windowButtonVisibility: false,
    );
    await windowManager.setMinimumSize(const Size(720, 480));
    await windowManager.show();
    await windowManager.setSkipTaskbar(false);
    if (isWin11()) {
      await flutter_acrylic.Window.setEffect(
        effect: flutter_acrylic.WindowEffect.acrylic,
        color: Colors.transparent,
        dark: false,
      );
    }
  }
}

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadResources();
  runApp(AppWidget(controller: AppController()));
}
