import 'package:fluent_ui/fluent_ui.dart';
import 'package:wenznote/app/windows/controller/home/win_home_controller.dart';
import 'package:wenznote/commons/mvc/controller.dart';
import 'package:wenznote/commons/mvc/view.dart';
import 'package:window_manager/window_manager.dart';

mixin WinEditTabMixin {
  String get tabId;

  Widget buildWidget(BuildContext context);

  void onOpenPage() {}

  void onClosePage() {}
}

class WinTabWidget with WinEditTabMixin {
  @override
  String tabId;
  Widget child;
  Function? onTabOpen;
  Function? onTabClose;

  WinTabWidget({
    required this.tabId,
    required this.child,
    this.onTabOpen,
    this.onTabClose,
  });

  @override
  Widget buildWidget(BuildContext context) {
    return child;
  }

  @override
  void onOpenPage() {
    super.onOpenPage();
    onTabOpen?.call();
  }

  @override
  void onClosePage() {
    super.onClosePage();
    onTabClose?.call();
  }
}

typedef WinEditTabBuilder = Widget Function(
    BuildContext context, WinEditTabController? controller);

class WinEditTab<T extends WinEditTabController> extends MvcController {
  String? id;
  T? controller;
  WinEditTabBuilder? builder;

  @override
  String get tabId => controller?.tabId ?? id!;

  WinEditTab({
    this.controller,
    this.builder,
    this.id,
  });

  Widget buildWidget(BuildContext context) {
    return _EditTabWidget(editTab: this);
  }

  Widget build(BuildContext context) {
    return Container();
  }
}

class _EditTabWidget extends StatelessWidget {
  final WinEditTab editTab;

  const _EditTabWidget({
    Key? key,
    required this.editTab,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MvcView(
      controller: editTab.controller!,
      builder: (controller) {
        return editTab.builder?.call(context, editTab.controller) ??
            editTab.build(context);
      },
    );
  }
}

abstract class WinEditTabController extends MvcController {
  WinHomeController homeController;

  WinEditTabController({required this.homeController});

  String get tabId;

  void onOpenTab() {
  }

  void onTabHide() {}

  void onCloseTab() {}

  void closeTab() {
    homeController.closeTab(tabId);
  }
}
