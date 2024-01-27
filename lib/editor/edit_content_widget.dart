import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:wenznote/commons/widget/popup_stack.dart';
import 'package:wenznote/editor/edit_controller.dart';
import 'package:wenznote/editor/mouse/mouse.dart';

class EditContentWidget extends StatefulWidget {
  EditController controller;
  ViewportOffset viewportOffset;

  EditContentWidget({
    Key? key,
    required this.controller,
    required this.viewportOffset,
  }) : super(key: key);

  @override
  State<EditContentWidget> createState() => EditContentWidgetState();
}

class EditContentWidgetState extends State<EditContentWidget> {
  static EditContentWidgetState of(BuildContext context) {
    return context.findRootAncestorStateOfType<EditContentWidgetState>()!;
  }

  @override
  void initState() {
    super.initState();
    widget.controller.onWidgetInitState(this);
    widget.viewportOffset.addListener(updateState);
  }

  void updateState() {
    setState(() {});
  }

  @override
  void dispose() {
    widget.viewportOffset.removeListener(updateState);
    widget.controller.onWidgetDispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant EditContentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.onWidgetDispose();
      widget.controller.onWidgetInitState(this);
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.controller.viewContext = context;
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth =
            min(widget.controller.maxEditWidth, constraints.maxWidth);
        var blockConstrains = constraints.copyWith(maxWidth: maxWidth);
        widget.controller.onLayoutBuild(context, constraints, blockConstrains);
        widget.viewportOffset.applyViewportDimension(constraints.maxHeight);
        var maxExtend = max(
            0.0, widget.controller.getContentHeight() - constraints.maxHeight);
        widget.viewportOffset.applyContentDimensions(0, maxExtend);
        // 通知卡片高度更新，以便列表更新卡片高度
        EditContentHeightNotification(widget.controller.getContentHeight())
            .dispatch(context);
        //显示blockWidgets
        var blockWidgets = widget.controller
            .buildContentBlocksWidget(context, constraints, blockConstrains);
        //计算滚动最大位置
        var cursorWidget = widget.controller.buildCursorWidget();
        if (cursorWidget != null) {
          blockWidgets.add(cursorWidget);
        }
        var contentWidgets = <Widget>[];
        var singleWidgets = <Widget>[];
        for (var widget in blockWidgets) {
          if (widget is SingleWidget) {
            singleWidgets.add(widget);
          } else {
            contentWidgets.add(widget);
          }
        }
        var floatWidgetXOffset =
            (constraints.maxWidth - blockConstrains.maxWidth) / 2;
        widget.controller.floatWidgetXOffset = floatWidgetXOffset;
        List<PopupPositionWidget> floatWidgets =
            EditController.translatePopupPositionWidget(
                widget.controller.buildFloatWidgets(), floatWidgetXOffset, 0.0);
        var backgroundWidgets = EditController.translatePopupPositionWidget(
            widget.controller.buildBackgroundWidgets(),
            floatWidgetXOffset,
            0.0);
        return PopupStack(
          children: [
            //block背景渲染
            ...backgroundWidgets,
            //镶嵌的block
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: blockConstrains.maxWidth,
                height: blockConstrains.maxHeight,
                child: Focus(
                  focusNode: widget.controller.focusNode,
                  autofocus: widget.controller.initFocus,
                  onFocusChange: (focus) {
                    widget.controller.onFocusChanged(focus);
                  },
                  onKey: (node, event) {
                    var result = widget.controller.onKey(node, event);
                    if (widget.controller.inputManager.hasComposing) {
                      return KeyEventResult.skipRemainingHandlers;
                    }
                    return result;
                  },
                  child: GestureDetector(
                    onLongPress: () {
                      HapticFeedback.selectionClick();
                      var eventQueue = widget
                          .controller.mouseKeyboardState.mouseDownEvent1;
                      if (eventQueue.isNotEmpty) {
                        widget.controller
                            .selectWord(eventQueue.last.localPosition);
                      }
                    },
                    child: MouseEventListenerWidget(
                      eventListener: (event, entry) {
                        widget.controller.onMouseEvent(event.copyWith(
                          position: event.position,
                        ));
                      },
                      behavior: HitTestBehavior.opaque,
                      child: SizedBox(
                        width: blockConstrains.maxWidth,
                        height: blockConstrains.maxHeight,
                        child: Stack(
                          children: contentWidgets,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            //独立控制事件的block
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: blockConstrains.maxWidth,
                height: blockConstrains.maxHeight,
                child: Stack(
                  children: singleWidgets,
                ),
              ),
            ),
            //悬浮控件
            ...floatWidgets,
          ],
        );
      },
    );
  }
}

class DeleteAction extends Action<DeleteCharacterIntent> {
  EditController controller;

  DeleteAction(this.controller);

  @override
  Object? invoke(Intent intent) {
    controller.delete(false);
  }
}
