import 'dart:io';

import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:oktoast/oktoast.dart';

import 'package:wenznote/commons/mvc/controller.dart';
import 'package:wenznote/commons/mvc/view.dart';
import 'package:wenznote/commons/widget/ignore_parent_pointer.dart';
import 'package:wenznote/service/service_manager.dart';
import 'package:wenznote/widgets/root_widget.dart';
import 'package:wenznote/widgets/window_border_widget.dart';


import 'routes/routes.dart';

class AppController extends MvcController {
  @override
  void onInitState(fluent.BuildContext context) {
    super.onInitState(context);
    try {
      FlutterDisplayMode.setHighRefreshRate();
    } catch (e) {
      print(e);
    }
  }
}



class AppWidget extends MvcView<AppController> {
  AppWidget({super.key, required super.controller});


  @override
  Widget build(BuildContext context) {
    return ServiceManagerWidget(
        router: appRouter,
        builder: (context) {
          var serviceManager = ServiceManager.of(context);
          return OKToast(
            backgroundColor: Colors.transparent,
            child: IgnoreParentMousePointerContainer(
              child: Obx(() {
                var brightness = serviceManager.themeManager.getBrightness();
                if (serviceManager.themeManager.themeMode.value ==
                    ThemeMode.system) {
                  brightness = MediaQuery.of(context).platformBrightness;
                }
                return MaterialApp.router(
                  title: "温知笔记",
                  routerConfig: appRouter,
                  debugShowCheckedModeBanner: false,
                  theme: ThemeData(
                    // fontFamily: "MiSans",
                    brightness: brightness,
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: Colors.blue,
                      brightness: brightness,
                    ),
                    textTheme:
                        const TextTheme().useSystemChineseFont(brightness),
                  ),
                  locale: const Locale('zh', 'CN'),
                  supportedLocales: const [
                    Locale('zh', 'CN'),
                    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
                    Locale('en', ''),
                  ],
                  localizationsDelegates: const [
                    GlobalMaterialLocalizations.delegate,
                    fluent.FluentLocalizations.delegate,
                  ],
                  builder: (context, child) {
                    return fluent.FluentTheme(
                      data: fluent.FluentThemeData(
                        // fontFamily: "MiSans",
                        brightness: brightness,
                        acrylicBackgroundColor: Colors.grey.withAlpha(10),
                      ),
                      child: WindowBorderWidget(
                        brightness: brightness,
                        child: Container(child: child ?? Container()),
                      ),
                    );
                  },
                );
              }),
            ),
          );
        });
  }
}
