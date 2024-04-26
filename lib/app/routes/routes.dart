import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wenznote/app/mobile/controller/settings/mobile_settings_controller.dart';
import 'package:wenznote/app/mobile/controller/settings/mobile_sync_password_settings_controller.dart';
import 'package:wenznote/app/mobile/controller/user/mobile_user_forget_password_controller.dart';
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
import 'package:wenznote/app/mobile/view/settings/mobile_sync_password_page.dart';
import 'package:wenznote/app/mobile/view/today/mobile_today_controller.dart';
import 'package:wenznote/app/mobile/view/today/mobile_today_page.dart';
import 'package:wenznote/app/mobile/view/user/mobile_user_forget_password_page.dart';
import 'package:wenznote/app/mobile/view/user/mobile_user_info_page.dart';
import 'package:wenznote/app/mobile/view/user/mobile_user_login_page.dart';
import 'package:wenznote/app/mobile/view/user/mobile_user_sign_page.dart';
import 'package:wenznote/app/windows/controller/home/win_home_controller.dart';
import 'package:wenznote/app/windows/view/export/export_controller.dart';
import 'package:wenznote/app/windows/view/export/export_widget.dart';
import 'package:wenznote/app/windows/view/home/win_home_page.dart';
import 'package:wenznote/app/windows/view/import/import_controller.dart';
import 'package:wenznote/app/windows/view/import/import_widget.dart';
import 'package:wenznote/service/service_manager.dart';

final appNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'app');

final appRouter = GoRouter(
  navigatorKey: appNavigatorKey,
  initialLocation:
      (Platform.isIOS || Platform.isAndroid) ? "/mobile/today" : "/windows",
  routes: [
    GoRoute(
      path: "/mobile",
      redirect: (context, state) {
        return null;
      },
      routes: [
        buildMobileHomeRoute(),
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
              controller: MobileCardSettingsController(cardSet: map['cardSet']),
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
            return MobileUserLoginPage(controller: MobileUserLoginController());
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
        GoRoute(
          path: "settings/sync/password",
          builder: (context, state) {
            return MobileSyncPasswordSettingsPage(
                controller: MobileSyncPasswordSettingsController());
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

StatefulShellRoute buildMobileHomeRoute() {
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
              return MobileTodayPageWidget(controller: MobileTodayController());
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
