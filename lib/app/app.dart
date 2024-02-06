import 'dart:io';

import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:oktoast/oktoast.dart';
import 'package:wenznote/app/mobile/controller/settings/mobile_settings_controller.dart';
import 'package:wenznote/app/mobile/controller/user/mobile_user_info_controller.dart';
import 'package:wenznote/app/mobile/controller/user/mobile_user_login_controller.dart';
import 'package:wenznote/app/mobile/controller/user/mobile_user_sign_controller.dart';
import 'package:wenznote/app/mobile/view/card/detail/mobile_card_detail_controller.dart';
import 'package:wenznote/app/mobile/view/card/detail/mobile_card_detail_page.dart';
import 'package:wenznote/app/mobile/view/card/edit/mobile_card_edit_controller.dart';
import 'package:wenznote/app/mobile/view/card/mobile_card_page.dart';
import 'package:wenznote/app/mobile/view/card/mobile_card_page_controller.dart';
import 'package:wenznote/app/mobile/view/card/settings/mobile_card_settings_controller.dart';
import 'package:wenznote/app/mobile/view/card/settings/mobile_card_settings_page.dart';
import 'package:wenznote/app/mobile/view/card/study/mobile_study_controller.dart';
import 'package:wenznote/app/mobile/view/card/study/mobile_study_page.dart';
import 'package:wenznote/app/mobile/view/doc/mobile_doc_page.dart';
import 'package:wenznote/app/mobile/view/doc/mobile_doc_page_controller.dart';
import 'package:wenznote/app/mobile/view/edit/doc_edit_controller.dart';
import 'package:wenznote/app/mobile/view/edit/doc_edit_widget.dart';
import 'package:wenznote/app/mobile/view/home/mobile_home_page.dart';
import 'package:wenznote/app/mobile/view/settings/mobile_settings_page.dart';
import 'package:wenznote/app/mobile/view/today/mobile_today_controller.dart';
import 'package:wenznote/app/mobile/view/user/mobile_user_forget_password_page.dart';
import 'package:wenznote/app/mobile/view/user/mobile_user_info_page.dart';
import 'package:wenznote/app/mobile/view/user/mobile_user_sign_page.dart';
import 'package:wenznote/commons/mvc/controller.dart';
import 'package:wenznote/commons/mvc/view.dart';
import 'package:wenznote/commons/widget/ignore_parent_pointer.dart';
import 'package:wenznote/service/service_manager.dart';
import 'package:wenznote/widgets/root_widget.dart';
import 'package:wenznote/widgets/window_border_widget.dart';

import 'mobile/controller/user/mobile_user_forget_password_controller.dart';
import 'mobile/view/today/mobile_today_page.dart';
import 'mobile/view/user/mobile_user_login_page.dart';
import 'windows/controller/home/win_home_controller.dart';
import 'windows/view/export/export_controller.dart';
import 'windows/view/export/export_widget.dart';
import 'windows/view/home/win_home_page.dart';
import 'windows/view/import/import_controller.dart';
import 'windows/view/import/import_widget.dart';

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

final GlobalKey<NavigatorState> _appNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'app');

class AppWidget extends MvcView<AppController> {
  AppWidget({super.key, required super.controller});

  static StatefulShellRoute buildHomeRoute() {
    return StatefulShellRoute.indexedStack(
      builder: (BuildContext context, GoRouterState state,
          StatefulNavigationShell navigationShell) {
        return MobileHomePage(navigationShell: navigationShell);
      },
      branches: [
        // today
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: 'today',
              onExit: (context) async {
                return true;
              },
              builder: (BuildContext context, GoRouterState state) {
                return MobileTodayPageWidget(
                    controller: MobileTodayController());
              },
            ),
          ],
        ),
        // note
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: 'doc',
              onExit: (context) async {
                return ServiceManager.of(context).canPop();
              },
              pageBuilder: (context, state) {
                return CustomTransitionPage(
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                  child: MobileDocPage(controller: MobileDocPageController()),
                  transitionsBuilder: (BuildContext context,
                      Animation<double> animation,
                      Animation<double> secondaryAnimation,
                      Widget child) {
                    return child;
                  },
                );
              },
              routes: [
                GoRoute(
                  path: "dir/:pid",
                  pageBuilder: (context, state) {
                    return CustomTransitionPage(
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                      child: MobileDocPage(
                        controller: MobileDocPageController(
                          pid: state.pathParameters['pid'],
                        ),
                      ),
                      transitionsBuilder: (BuildContext context,
                          Animation<double> animation,
                          Animation<double> secondaryAnimation,
                          Widget child) {
                        return child;
                      },
                    );
                  },
                )
              ],
            ),
          ],
        ),
        // card
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: 'card',
              builder: (BuildContext context, GoRouterState state) {
                return MobileCardPage(controller: MobileCardPageController());
              },
            ),
          ],
        ),
      ],
    );
  }

  final GoRouter _router = GoRouter(
    navigatorKey: _appNavigatorKey,
    initialLocation:
        (Platform.isIOS || Platform.isAndroid) ? "/mobile/today" : "/windows",
    routes: [
      GoRoute(
        path: "/mobile",
        redirect: (context, state) {
          return null;
        },
        routes: [
          buildHomeRoute(),
          GoRoute(
            path: "doc/edit",
            builder: (context, state) {
              var params = state.extra as Map;
              return MobileDocEditWidget(
                controller: MobileDocEditController(
                  doc: params['doc'],
                  editOnOpen: params["editOnOpen"] ?? false,
                ),
              );
            },
          ),
          GoRoute(
            path: "card/edit",
            builder: (context, state) {
              var params = state.extra as Map;
              return MobileDocEditWidget(
                controller: MobileCardEditController(
                  card: params['card'],
                  editOnOpen: params['editOnOpen'],
                ),
              );
            },
          ),
          GoRoute(
            path: "cardSet/:cardSetId",
            builder: (context, state) {
              return MobileCardDetailPage(
                controller: MobileCardDetailController(
                    cardSetId: state.pathParameters["cardSetId"]),
              );
            },
          ),
          GoRoute(
            path: "cardSet/:cardSetId/settings",
            builder: (context, state) {
              var map = state.extra as Map;
              return MobileCardSettingsPage(
                controller:
                    MobileCardSettingsController(cardSet: map['cardSet']),
              );
            },
          ),
          GoRoute(
            path: "cardSet/:cardSetId/study",
            builder: (context, state) {
              var map = state.extra as Map;
              return MobileStudyPage(
                controller: MobileStudyController(cardSet: map['cardSet']),
              );
            },
          ),
          GoRoute(
            path: "login",
            builder: (context, state) {
              return MobileUserLoginPage(
                  controller: MobileUserLoginController());
            },
          ),
          GoRoute(
            path: "sign",
            builder: (context, state) {
              return MobileUserSignPage(controller: MobileUserSignController());
            },
          ),
          GoRoute(
            path: "forgetPassword",
            builder: (context, state) {
              return MobileUserForgetPasswordPage(
                  controller: MobileUserForgetPasswordController());
            },
          ),
          GoRoute(
            path: "userInfo",
            builder: (context, state) {
              return MobileUserInfoPage(controller: MobileUserInfoController());
            },
          ),
          GoRoute(
            path: "settings",
            builder: (context, state) {
              return MobileSettingsPage(controller: MobileSettingsController());
            },
          ),
        ],
      ),
      GoRoute(
        path: "/windows",
        builder: (context, state) {
          return WinHomePage(
            controller: WinHomeController(),
          );
        },
      ),
      GoRoute(
        path: "/windows/export",
        builder: (context, state) {
          return ExportWidget(
            controller: ExportController(),
          );
        },
      ),
      GoRoute(
        path: "/windows/import",
        builder: (context, state) {
          return ImportWidget(
            controller: ImportController(),
          );
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return ServiceManagerWidget(builder: (context) {
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
              routerConfig: _router,
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                // fontFamily: "MiSans",
                brightness: brightness,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.blue,
                  brightness: brightness,
                ),
                textTheme: const TextTheme().useSystemChineseFont(brightness),
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
