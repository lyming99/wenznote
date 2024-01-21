import 'dart:async';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:wenznote/commons/widget/popup_stack.dart';
import 'package:wenznote/editor/widget/toggle_item.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

import '../theme/theme.dart';

class DropSplit extends DropMenu {
  DropSplit({
    Color? color,
  }) {
    super.height = 10;
    super.text = Builder(
      builder: (context) {
        var lineColor = fluent.FluentTheme.of(context).resources.cardStrokeColorDefaultSolid;
        return Container(
          color: color ?? lineColor,
          margin: const EdgeInsets.symmetric(vertical: 4),
          height: 1,
        );
      }
    );
    super.enable = false;
  }
}

class DropMenu {
  List<DropMenu>? children;
  Widget? icon;
  Widget? text;
  Widget? description;
  double? height;
  bool enable;
  bool? checked;
  ScrollController? scrollController;

  VoidCallback? onPress;
  double? childrenWidth;
  double? childrenHeight;

  DropMenu({
    this.children,
    this.icon,
    this.text,
    this.description,
    this.onPress,
    this.childrenWidth,
    this.childrenHeight,
    this.enable = true,
    this.checked,
    this.height,
    this.scrollController,
  });
}

class DropMenuWidget extends StatefulWidget {
  BuildContext buttonContext;
  Rect anchorRect;
  List<DropMenu> menus;
  bool modal;
  double childrenWidth;
  double childrenHeight;
  double margin;
  double maxHeight;
  OverlayEntry? entry;
  Alignment? popupAlignment;
  Alignment? overflowAlignment;
  ScrollController? rootScrollController;

  DropMenuWidget({
    Key? key,
    required this.buttonContext,
    required this.menus,
    required this.anchorRect,
    required this.childrenWidth,
    required this.childrenHeight,
    required this.margin,
    this.maxHeight = double.infinity,
    this.modal = false,
    this.popupAlignment,
    this.overflowAlignment,
    this.rootScrollController,
  }) : super(key: key);

  @override
  State<DropMenuWidget> createState() => DropMenuWidgetState();
}

class DropMenuWidgetState extends State<DropMenuWidget> {
  List<List<DropMenu>> levelList = [];
  List<Rect> levelHoverRect = [];
  List<DropMenu?> levelHoverMenu = [];

  @override
  void initState() {
    super.initState();
    levelList.clear();
    levelHoverRect.clear();
    levelHoverMenu.clear();
    levelList.add(widget.menus);
    levelHoverRect.add(widget.anchorRect);
    levelHoverMenu.add(null);
  }

  @override
  Widget build(BuildContext context) {
    return PopupStack(
      children: [
        for (var i = 0; i < levelList.length; i++)
          buildPopupWidgets(context, i),
      ],
    );
  }

  PopupPositionWidget buildPopupWidgets(BuildContext context, int level) {
    var children = <Widget>[];
    var menus = levelList[level];
    for (var menu in menus) {
      var menuHeight = menu.height ??
          (levelHoverMenu[level]?.childrenHeight ?? widget.childrenHeight);
      children.add(
        Builder(builder: (context) {
          return ToggleItem(
            checked: menu.checked == true,
            onTap: (ctx) {
              if (menu.enable) {
                menu.onPress?.call(ctx);
              }
              if (Platform.isAndroid || Platform.isIOS) {
                showChildrenMenu(level, menu, context);
              }
            },
            onHoverEnter: (ctx) {
              //清除下一个level的menu即可
              showChildrenMenu(level, menu, context);
            },
            itemBuilder:
                (BuildContext context, bool checked, bool hover, bool pressed) {
              return Container(
                height: menuHeight,
                padding: EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: menu.enable &&
                          ((hover || pressed || checked) ||
                              (levelHoverMenu.length > level + 1 &&
                                  levelHoverMenu[level + 1] == menu))
                      ? EditTheme.of(context).treeItemHoverColor
                      : null,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (menu.icon != null) menu.icon!,
                    if (menu.text != null) Expanded(child: menu.text!),
                    if (menu.description != null) menu.description!,
                    if (menu.children?.isNotEmpty == true)
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: menu.enable
                            ? EditTheme.of(context).fontColor
                            : EditTheme.of(context).fontColor2,
                      ),
                  ],
                ),
              );
            },
          );
        }),
      );
    }
    return PopupPositionWidget(
      anchorRect: levelHoverRect[level],
      keepVision: true,
      popupAlignment: level == 0
          ? (widget.popupAlignment ?? Alignment.bottomLeft)
          : Alignment.centerRight,
      overflowAlignment: level == 0
          ? (widget.overflowAlignment ?? Alignment.bottomRight)
          : Alignment.centerLeft,
      verticalAlignment: VerticalAlignment.top,
      child: Container(
        width: levelHoverMenu[level]?.childrenWidth ?? widget.childrenWidth,
        constraints: BoxConstraints(
          maxHeight: widget.maxHeight,
        ),
        margin: level == 0
            ? EdgeInsets.all(widget.margin)
            : const EdgeInsets.only(
                left: 4,
                right: 4,
              ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade900
              : Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              // blurStyle: BlurStyle.outer,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withAlpha(200)
                  : Colors.grey.shade500,
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(4),
              controller: level == 0
                  ? widget.rootScrollController
                  : levelHoverMenu[level]?.scrollController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: children,
              ),
            );
          },
        ),
      ),
    );
  }

  void showChildrenMenu(int level, DropMenu menu, BuildContext context) {
    if (levelHoverMenu.length > level + 1 &&
        levelHoverMenu[level + 1] == menu) {
      return;
    }
    var box = context.findRenderObject() as RenderBox;
    var itemRect = box.localToGlobal(Offset.zero) & box.size;
    levelList.removeRange(level + 1, levelList.length);
    levelHoverRect.removeRange(level + 1, levelHoverRect.length);
    levelHoverMenu.removeRange(level + 1, levelHoverMenu.length);
    WidgetsBinding.instance.scheduleFrameCallback((timeStamp) {
      setState(() {
        if (menu.children != null && menu.enable) {
          levelList.add(menu.children!);
          levelHoverRect.add(itemRect);
          levelHoverMenu.add(menu);
        }
      });
    });
  }
}

class PopupWindowWidget extends StatefulWidget {
  final OverlayEntry? entry;
  final Widget child;
  final bool modal;
  final bool focus;

  const PopupWindowWidget({
    Key? key,
    this.focus = true,
    this.modal = false,
    required this.entry,
    required this.child,
  }) : super(key: key);

  @override
  State<PopupWindowWidget> createState() => _PopupWindowWidgetState();
}

class _PopupWindowWidgetState extends State<PopupWindowWidget> {
  @override
  void initState() {
    super.initState();
    GestureBinding.instance.pointerRouter.addGlobalRoute(onEvent);
  }

  @override
  void dispose() {
    GestureBinding.instance.pointerRouter.removeGlobalRoute(onEvent);
    super.dispose();
  }

  void onEvent(PointerEvent event) {
    if (mounted && event is PointerDownEvent) {
      var box = context.findRenderObject();
      if (box is RenderBox) {
        if (!box.hitTest(BoxHitTestResult(), position: event.position)) {
          widget.entry?.remove();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      child: Focus(
        autofocus: widget.focus,
        child: widget.child,
      ),
    );
  }
}

Future<void> showCustomDropMenu({
  required BuildContext context,
  required WidgetBuilder builder,
  Rect? anchor,
  Alignment alignment = Alignment.bottomLeft,
  Alignment overflowAlignment = Alignment.bottomRight,
  Offset offset = Offset.zero,
  double width = 200,
  double height = 200,
  double margin = 0,
  bool modal = false,
}) async {
  if (anchor == null) {
    var box = context.findRenderObject() as RenderBox;
    anchor = box.localToGlobal(offset) & box.size;
  }
  var popupWidget = PopupStack(
    children: [
      PopupPositionWidget(
        anchorRect: anchor,
        keepVision: true,
        width: width,
        height: height,
        popupAlignment: alignment,
        overflowAlignment: overflowAlignment,
        verticalAlignment: VerticalAlignment.top,
        child: Builder(
          builder: builder,
        ),
      )
    ],
  );
  if (modal) {
    await showDialog(
        barrierColor: Colors.transparent,
        useSafeArea: false,
        context: context,
        builder: (context) {
          return PopupWindowWidget(
            entry: null,
            modal: true,
            child: popupWidget,
          );
        });
    return;
  }
  await showPopupWindow(context, popupWidget);
}

Future<void> showDropMenu(
  BuildContext context, {
  required List<DropMenu> menus,
  double childrenWidth = 200,
  double childrenHeight = 30,
  double margin = 0,
  Offset offset = Offset.zero,
  bool modal = false,
  Alignment? popupAlignment,
  Alignment? overflowAlignment,
}) async {
  var box = context.findRenderObject() as RenderBox;
  var anchorRect = box.localToGlobal(offset) & box.size;
  var widget = DropMenuWidget(
    buttonContext: context,
    menus: menus,
    anchorRect: anchorRect,
    childrenWidth: childrenWidth,
    childrenHeight: childrenHeight,
    margin: margin,
    popupAlignment: popupAlignment,
    overflowAlignment: overflowAlignment,
  );
  if (modal) {
    await showDialog(
        barrierColor: Colors.transparent,
        useSafeArea: false,
        context: context,
        builder: (context) {
          return PopupWindowWidget(
            entry: null,
            modal: true,
            child: widget,
          );
        });
    return;
  }
  await showPopupWindow(
    context,
    widget,
  );
}

Future<void> showMouseDropMenu(
  BuildContext context,
  Rect anchorRect, {
  required List<DropMenu> menus,
  double childrenWidth = 200,
  double childrenHeight = 30,
  double margin = 0,
  bool modal = false,
  Alignment? popupAlignment,
  Alignment? overflowAlignment,
}) async {
  var widget = DropMenuWidget(
    buttonContext: context,
    menus: menus,
    anchorRect: anchorRect,
    childrenWidth: childrenWidth,
    childrenHeight: childrenHeight,
    margin: margin,
    popupAlignment: popupAlignment,
    overflowAlignment: overflowAlignment,
  );
  if (modal) {
    await showDialog(
        barrierColor: Colors.transparent,
        useSafeArea: false,
        context: context,
        builder: (context) {
          return PopupWindowWidget(
            entry: null,
            modal: true,
            child: widget,
          );
        });
    return;
  }
  await showPopupWindow(context, widget);
}

void hideDropMenu(BuildContext context) {
  var widget = context.findAncestorWidgetOfExactType<PopupWindowWidget>();
  if (widget == null) {
    return;
  }
  widget.entry?.remove();
  if (widget.modal) {
    Navigator.of(context).pop();
  }
}

bool hasDropMenu(BuildContext context) {
  var widget = context.findAncestorWidgetOfExactType<PopupWindowWidget>();
  return widget != null;
}

Future<void> showPopupWindow(BuildContext context, Widget widget) async {
  var comp = Completer();
  OverlayEntry? entry;
  entry = OverlayEntry(builder: (context) {
    return PopupWindowWidget(
      entry: entry!,
      child: widget,
    );
  });
  Overlay.of(context, rootOverlay: true).insert(entry);
  entry.addListener(() {
    if (!entry!.mounted) {
      comp.complete();
    }
  });
  await comp.future;
}

void closePopupWindow(BuildContext context) {
  var widget = context.findAncestorWidgetOfExactType<PopupWindowWidget>();
  if (widget == null) {
    return;
  }
  widget.entry?.remove();
  if (widget.modal) {
    Navigator.of(context).pop();
  }
}
