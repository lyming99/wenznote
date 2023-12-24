import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:get/get.dart';
import 'package:note/app/windows/routes.dart';
import 'package:note/commons/widget/ignore_parent_pointer.dart';
import 'package:note/commons/widget/theme_listner.dart';
import 'package:note/config/theme_settings.dart';
import 'package:note/service/service_manager.dart';
import 'package:note/widgets/root_widget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:window_manager/window_manager.dart';

import '../../commons/service/device_utils.dart';

bool get isDesktop {
  if (kIsWeb) return false;
  return [
    TargetPlatform.windows,
    TargetPlatform.linux,
    TargetPlatform.macOS,
  ].contains(defaultTargetPlatform);
}

Future<void> windowsMain(
    {bool test = false, List<String> args = const []}) async {
  if (!kIsWeb &&
      [
        TargetPlatform.windows,
        TargetPlatform.android,
      ].contains(defaultTargetPlatform)) {
    // SystemTheme.accentColor.load();
  }
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
  runApp(ValueListenableBuilder<dynamic>(
    valueListenable: ThemeSettings.instance,
    builder: (context, config, widget) {
      var brightness = ThemeSettings.instance.getBrightness();
      return OKToast(
        child: IgnoreParentMousePointerContainer(
          child: GetMaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              fontFamily: "MiSans",
              brightness: brightness,
            ),
            locale: const Locale('en', ''),
            supportedLocales: const [
              Locale('en', ''), // English, no country code
            ],
            localizationsDelegates: const [
              fluent.FluentLocalizations.delegate,
            ],
            title: '温知笔记',
            initialRoute: test ? "/test" : "/",
            getPages: WindowsAppRoutes.routes,
            builder: (context, child) {
              return ServiceManagerWidget(
                builder: (context) {
                  return fluent.FluentTheme(
                    data: fluent.FluentThemeData(
                      fontFamily: "MiSans",
                      brightness: brightness,
                      acrylicBackgroundColor: Colors.grey.withAlpha(10),
                    ),
                    child: Container(child: child ?? Container()),
                  );
                }
              );
            },
          ),
        ),
      );
    },
  ));
}
