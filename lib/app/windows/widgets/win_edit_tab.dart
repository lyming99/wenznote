import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:note/app/windows/controller/home/win_home_controller.dart';

mixin WinEditTabMixin {
  String get tabId;

  Widget buildWidget(BuildContext context);

  void onOpenPage() {}

  void onClosePage() {}

  void closeTab() {
    Get.find<WinHomeController>().closeTab(tabId);
  }
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

class WinEditTab<T extends WinEditTabController> with WinEditTabMixin {
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

  @override
  Widget buildWidget(BuildContext context) {
    return _EditTabWidget(editTab: this);
  }

  @override
  void onOpenPage() {
    super.onOpenPage();
    controller?.onOpenTab();
  }

  @override
  void onClosePage() {
    super.onClosePage();
    controller?.onCloseTab();
  }

  Widget build(BuildContext context) {
    return Container();
  }
}

class _EditTabWidget extends StatefulWidget {
  final WinEditTab editTab;

  const _EditTabWidget({
    Key? key,
    required this.editTab,
  }) : super(key: key);

  @override
  State<_EditTabWidget> createState() => _EditTabWidgetState();
}

class _EditTabWidgetState extends State<_EditTabWidget> {
  @override
  void initState() {
    super.initState();
    widget.editTab.controller?.onInitState(context);
  }

  @override
  void dispose() {
    widget.editTab.controller?.onStateDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.editTab.builder?.call(context, widget.editTab.controller) ??
        widget.editTab.build(context);
  }
}

abstract class WinEditTabController {
  String get tabId;

  void onInitState(BuildContext context) {}

  void onOpenTab() {}

  void onTabHide() {}

  void onCloseTab() {}

  void onStateDispose() {}

  void closeTab() {
    Get.find<WinHomeController>().closeTab(tabId);
  }
}
