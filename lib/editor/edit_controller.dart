// ignore_for_file: use_build_context_synchronously, empty_catches

import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart' as image_size;
import 'package:pasteboard/pasteboard.dart';
import 'package:rich_clipboard/rich_clipboard.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wenznote/commons/service/copy_service.dart';
import 'package:wenznote/commons/util/file_utils.dart';
import 'package:wenznote/commons/util/html/html.dart';
import 'package:wenznote/commons/util/image.dart';
import 'package:wenznote/commons/util/markdown/markdown.dart';
import 'package:wenznote/commons/util/platform_util.dart';
import 'package:wenznote/commons/widget/flayout.dart';
import 'package:wenznote/commons/widget/popup_stack.dart';
import 'package:wenznote/editor/block/code/code.dart';
import 'package:wenznote/editor/block/image/image_block.dart';
import 'package:wenznote/editor/block/line/line_block.dart';
import 'package:wenznote/editor/block/line/line_element.dart';
import 'package:wenznote/editor/block/text/title.dart';
import 'package:wenznote/editor/theme/theme.dart';
import 'package:wenznote/editor/widget/drop_menu.dart';
import 'package:wenznote/editor/widget/formula_dialog.dart';
import 'package:wenznote/editor/widget/modal_widget.dart';

import '../service/file/file_manager.dart';
import 'block/block.dart';
import 'block/block_manager.dart';
import 'block/element/element.dart';
import 'block/image/image_element.dart';
import 'block/table/adjust_widget.dart';
import 'block/table/table_block.dart';
import 'block/table/table_cell.dart';
import 'block/table/table_element.dart';
import 'block/text/hide_text_mode.dart';
import 'block/text/text.dart';
import 'cursor/cursor.dart';
import 'edit_float_widget.dart';
import 'edit_widget.dart';
import 'event/manager.dart';
import 'input/input_manager.dart';
import 'popup_tool.dart';

typedef EditWriter = Future Function(List content);

typedef EditReader = Future<List> Function();

class EditContentHeightNotification extends Notification {
  double height;

  EditContentHeightNotification(this.height);
}

class MouseKeyboardState {
  int saveSize = 10;
  Queue<PointerHoverEvent> mouseHoverEvent = Queue();
  Queue<PointerDownEvent> mouseDownEvent1 = Queue();
  Queue<PointerMoveEvent> mouseMoveEvent1 = Queue();
  Queue<PointerEvent> mouseDownEvent2 = Queue();
  Queue<PointerEvent> mouseMoveEvent2 = Queue();
  Queue<PointerEvent> mouseUpEvent = Queue();
  Queue<KeyEvent> keyEvent = Queue();
  Queue<RawKeyEvent> rawKeyEvent = Queue();
  Queue<int> wheelScrollTime = Queue();
  Queue<double> wheelScrollDelta = Queue();
  bool mouseLeftDown = false;
  int mouseDownTime = 0;
  int mouseClickTime = 0;
  Offset? mouseDownOffset;
  Offset? mouseClickPosition;
  bool mouseDrag = false;
  double mouseClickCount = 0;
  bool enter = true;

  double mouseScrollSpeedX = 0;
  double mouseScrollSpeedY = 0;
  Timer? mouseScrollTimer;

  bool equalDirection(double a, double b) {
    if (a <= 0 && b <= 0) {
      return true;
    }
    if (a >= 0 && b >= 0) {
      return true;
    }
    return false;
  }

  void onMouseEvent(PointerEvent event) {
    if (event is PointerExitEvent) {
      enter = false;
    }
    if (event is PointerEnterEvent) {
      enter = true;
    }
    event = event.copyWith();
    if (event.buttons == 1) {
      if (event is PointerDownEvent) {
        mouseDownEvent1.addLast(event);
      } else if (event is PointerMoveEvent) {
        mouseMoveEvent1.addLast(event);
      }
    } else if (event.buttons == 2) {
      if (event is PointerDownEvent) {
        mouseDownEvent2.addLast(event);
      } else if (event is PointerMoveEvent) {
        mouseMoveEvent2.addLast(event);
      }
    }
    if (event is PointerHoverEvent) {
      mouseHoverEvent.addLast(event);
    }
    if (mouseDownEvent1.length > saveSize) {
      mouseDownEvent1.removeFirst();
    }
    if (mouseDownEvent2.length > saveSize) {
      mouseDownEvent2.removeFirst();
    }
    if (event is PointerUpEvent) {
      mouseUpEvent.addLast(event);
    }
    if (mouseMoveEvent1.length > saveSize) {
      mouseMoveEvent1.removeFirst();
    }
    if (mouseMoveEvent2.length > saveSize) {
      mouseMoveEvent2.removeFirst();
    }
    if (mouseUpEvent.length > saveSize) {
      mouseUpEvent.removeFirst();
    }
    if (mouseHoverEvent.length > saveSize) {
      mouseHoverEvent.removeFirst();
    }
  }

  void onKey(FocusNode node, RawKeyEvent event) {
    rawKeyEvent.addLast(event);
    if (rawKeyEvent.length > saveSize) {
      rawKeyEvent.removeFirst();
    }
  }

  void onKeyEvent(FocusNode node, KeyEvent event) {
    keyEvent.addLast(event);
    if (keyEvent.length > saveSize) {
      keyEvent.removeFirst();
    }
  }

  void stopMouseScrollTimer() {
    mouseScrollTimer?.cancel();
    mouseScrollTimer = null;
  }
}

class CursorRecord {
  int saveSize = 10;
  Queue<CursorPosition> cursorPositionStack = Queue();

  ///记录光标的窗口位置x坐标用于上下翻页光标计算
  double recordWindowX = 0;

  ///记录光标的窗口位置y坐标用于上下翻页光标计算
  double recordWindowY = 0;

  void updateCursorPosition(CursorPosition cursorPosition) {
    if (cursorPositionStack.isNotEmpty) {
      if (cursorPositionStack.last == cursorPosition &&
          false == cursorPositionStack.last.block?.element.updated) {
        cursorPositionStack.removeLast();
      }
    }
    cursorPositionStack.addLast(cursorPosition.copy);
    if (cursorPositionStack.length > saveSize) {
      cursorPositionStack.removeFirst();
    }
  }

  void updateCursorWindowPosition(
      CursorPosition cursorPosition, double scrollOffset) {
    recordWindowX = cursorPosition.rect?.center.dx ?? recordWindowX;
    recordWindowY = ((cursorPosition.rect?.center.dy ?? 0) +
            (cursorPosition.block?.top ?? 0)) -
        scrollOffset;
  }
}

class SelectState {
  EditController editController;
  CursorPosition? _start;
  CursorPosition? _end;
  PointerDownEvent? dragCursorStartEvent;
  Offset? dragCursorStartPosition;

  bool isCursorDragging = false;

  SelectState({
    required this.editController,
  });

  set start(CursorPosition? cursor) {
    _start = cursor;
    editController.onSelectChanged();
  }

  CursorPosition? get start {
    return _start;
  }

  set end(CursorPosition? cursor) {
    _end = cursor;
    editController.onSelectChanged();
  }

  CursorPosition? get end {
    return _end;
  }

  bool get shiftDown => isShiftPressed;

  /// Returns true if the given [KeyboardKey] is pressed.
  bool isKeyPressed(LogicalKeyboardKey key) =>
      RawKeyboard.instance.keysPressed.contains(key);

  /// Returns true if a CTRL modifier key is pressed, regardless of which side
  /// of the keyboard it is on.
  ///
  /// Use [isKeyPressed] if you need to know which control key was pressed.
  bool get isControlPressed {
    return isKeyPressed(LogicalKeyboardKey.controlLeft) ||
        isKeyPressed(LogicalKeyboardKey.controlRight);
  }

  bool get isShiftPressed {
    return isKeyPressed(LogicalKeyboardKey.shiftLeft) ||
        isKeyPressed(LogicalKeyboardKey.shiftRight);
  }

  bool get hasSelect {
    return start != null && end != null && start != end;
  }

  bool get hasSelectRange {
    var start = realStart;
    var end = realEnd;
    if (start == null || end == null) {
      return false;
    }
    if (start.block?.top != end.block?.top) {
      return true;
    }
    if (start.textPosition?.offset != end.textPosition?.offset) {
      return true;
    }
    return false;
  }

  void clearSelect() {
    start = null;
    end = null;
  }

  void clearSelectIfNoShift() {
    if (!shiftDown) {
      clearSelect();
    }
  }

  CursorPosition? get realStart {
    if ((start?.isValid ?? false) == false ||
        (end?.isValid ?? false) == false) {
      return null;
    }
    if (start!.block!.top < end!.block!.top) {
      return start;
    }
    if (start!.block!.top == end!.block!.top) {
      if (start!.textPosition!.offset < end!.textPosition!.offset) {
        return start;
      }
    }
    return end;
  }

  CursorPosition? get realEnd {
    if ((start?.isValid ?? false) == false ||
        (end?.isValid ?? false) == false) {
      return null;
    }
    if (start!.block!.top < end!.block!.top) {
      return end;
    }
    if (start!.block!.top == end!.block!.top) {
      if (start!.textPosition!.offset < end!.textPosition!.offset) {
        return end;
      }
    }
    return start;
  }

  int get selectLength {
    if (!hasSelect) {
      return 0;
    }
    var ans =
        (start?.textPosition?.offset ?? 0) - (end?.textPosition?.offset ?? 0);
    if (ans < 0) {
      return -ans;
    }
    return ans;
  }

  void swapToRealSelect(EditController controller) {
    var start = realStart;
    var end = realEnd;
    if (start == this.start) {
      return;
    }
    this.start = start;
    this.end = end;
    SchedulerBinding.instance.scheduleFrameCallback((timeStamp) {
      controller.updateWidgetState();
    });
  }
}

class SingleWidget extends Container {
  SingleWidget({super.key, super.child});
}

/// 选择拖动事件，通知select drag更新，需要屏蔽上层的滚动，而优先拖拽滚动
class SelectDragListener extends StatelessWidget {
  final VoidCallback? onStatusChanged;
  final Widget child;

  const SelectDragListener({
    super.key,
    this.onStatusChanged,
    required this.child,
  });

  static void emitChange(BuildContext context) {
    context.visitAncestorElements((element) {
      if (element.widget.runtimeType == SelectDragListener) {
        (element.widget as SelectDragListener).onStatusChanged?.call();
      }
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// 如果是searchKey的话，需要高亮背景为黄色
class SearchState {
  String? searchKey;

  bool get hasSearch => searchKey != null && searchKey!.isNotEmpty;
}

class EditController with ChangeNotifier {
  late BuildContext viewContext;
  late EventManager eventManager;
  late BlockManager blockManager;
  late CursorState cursorState;
  late InputManager inputManager;
  late SelectState selectState;
  late MouseKeyboardState mouseKeyboardState;
  late CursorRecord cursorRecord;
  late FocusNode focusNode;
  late SearchState searchState;
  late WenPopupTool popupTool;
  FileManager fileManager;
  CopyService copyService;

  Function? onContentChanged;
  ModalController modalController = ModalController();

  var fontColorPickerController = FlyoutController();
  var bgColorPickerController = FlyoutController();
  var contextMenuController = FlyoutController();
  bool showHeadList = false;
  EditReader? reader;
  EditWriter? writer;
  EdgeInsets padding;
  State? state;
  bool initFocus = false;
  bool editable = true;
  bool showTextLength = false;
  bool rightMenuShowing = false;
  PointerEvent? rightMenuEvent;
  int? initBlockIndex;
  int? initTextOffset;

  //可视宽度
  double visionWidth = 0;

  //可视高度
  double visionHeight = 0;

  //居中后的offset
  Offset visionOffset = Offset.zero;
  ScrollController? scrollController;
  bool isFloatWidgetDragging = false;

  //挖空
  List<HideTextMode>? hideTextModes;
  double floatWidgetXOffset = 0;
  double maxEditWidth = double.infinity;

  int get textLength => blockManager.textLength;

  static EditController of(BuildContext context) {
    var widget = context.widget;
    if (widget is EditWidget) {
      return widget.controller;
    }
    return context.findAncestorWidgetOfExactType<EditWidget>()!.controller;
  }

  EditController({
    this.reader,
    this.onContentChanged,
    this.writer,
    this.initFocus = false,
    this.editable = true,
    this.hideTextModes,
    this.padding = EdgeInsets.zero,
    this.initBlockIndex,
    this.initTextOffset,
    this.scrollController,
    this.maxEditWidth = double.infinity,
    this.showTextLength = false,
    required this.fileManager,
    required this.copyService,
  }) {
    popupTool = WenPopupTool(controller: this);
    scrollController ??= ScrollController();
    eventManager = EventManager();
    blockManager = BlockManager();
    cursorState = CursorState();
    inputManager = InputManager(
        inputCallback: onInputText,
        inputComposingCallback: onInputComposing,
        actionCallback: onInputAction,
        onDelete: () {
          delete(true);
        });
    selectState = SelectState(
      editController: this,
    );
    focusNode = FocusNode();
    mouseKeyboardState = MouseKeyboardState();
    cursorRecord = CursorRecord();
    searchState = SearchState();
  }

  EditTheme get editTheme {
    return Theme.of(viewContext).brightness == Brightness.dark
        ? EditTheme.dark
        : EditTheme.light;
  }

  double get blockMaxWidth => visionWidth - padding.horizontal;

  double get scrollOffset {
    if (scrollController?.positions.isEmpty == true) {
      return 0;
    }
    try {
      return scrollController?.offset ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<void> readContent(BuildContext context,
      {bool initContent = false}) async {
    var content = await reader?.call();
    blockManager.changeStack.reset(content ?? []);
    blockManager.parseContent(context, this);
    blockManager.onContentChanged(this);
    _restoreAllCursorPosition();
    //通知界面更新
    eventManager.emit(EventType.contentChanged);

    if (initContent) {
      var blockIndex = initBlockIndex;
      var textOffset = initTextOffset;
      if (blockIndex != null && textOffset != null) {
        gotoPosition(blockIndex, textOffset);
      }
    }
    updateWidgetState();
    notifyListeners();
  }

  Future<void> reset(List content) async {
    blockManager.changeStack.reset(content);
    blockManager.parseContent(viewContext, this);
    blockManager.onContentChanged(this);
  }

  /// 恢复光标、选择位置
  void _restoreAllCursorPosition() {
    _restoreCursorPosition(cursorState.cursorPosition);
    _restoreCursorPosition(cursorState.hoverPosition);
    _restoreCursorPosition(selectState.start);
    _restoreCursorPosition(selectState.end);
  }

  /// 恢复光标位置
  void _restoreCursorPosition(CursorPosition? cursorPosition) {
    if (cursorPosition == null) {
      return;
    }
    var blockIndex = cursorPosition.blockIndex;
    if (blockIndex == null) {
      return;
    }
    var textPosition = cursorPosition.textPosition;
    if (textPosition == null) {
      return;
    }
    if (blockIndex < blockManager.blocks.length) {
      var block = cursorPosition.block = blockManager.blocks[blockIndex];
      cursorPosition.rect = block.getCursorRect(textPosition);
    }
  }

  /// 跳转
  void gotoPosition(int blockIndex, int textOffset) {
    waitLayout(() {
      if (blockIndex < blockManager.blocks.length) {
        blockManager.layoutPreviousBlockWithHeight(viewContext,
            Size(visionWidth, visionHeight), blockIndex, visionWidth);
        var block = blockManager.blocks[blockIndex];
        scrollToBlock(block);
        toPosition(
            block.getCursorPosition(TextPosition(offset: textOffset)), true);
      }
    });
  }

  /// 等待布局完成
  void waitLayout(Function call, {int waitCount = 100}) {
    if (visionWidth > 0 && visionHeight > 0) {
      WidgetsBinding.instance.scheduleFrameCallback((timeStamp) {
        call.call();
      });
    } else {
      if (waitCount > 0) {
        WidgetsBinding.instance.scheduleFrameCallback((timeStamp) {
          waitLayout(call, waitCount: waitCount - 1);
        });
      }
    }
  }

  /// widget init state
  void onWidgetInitState(State state) {
    this.state = state;
    viewContext = state.context;
    eventManager.emit(EventType.initState);
    readContent(
      viewContext,
      initContent: true,
    );
    if (editable) {
      startCursorTimer();
    }
  }

  /// widget dispose
  void onWidgetDispose() {
    inputManager.closeInputMethod();
    eventManager.emit(EventType.disposed);
    stopCursorTimer();
  }

  /// 开始光标闪烁 timer
  void startCursorTimer() {
    cursorState.startCursorTimer(onFlushCursor);
  }

  /// 关闭光标闪烁 timer
  void stopCursorTimer() {
    cursorState.stopCursorTimer();
  }

  /// 刷新光标
  void onFlushCursor() {
    updateWidgetState();
  }

  int updateCount = 0;

  /// 更新 widget state
  void updateWidgetState() {
    try {
      state?.setState(() {});
    } catch (e) {}
  }

  /// 创建内容widget，背景绘制
  List<Widget> buildContentBlocksWidget(BuildContext context,
      BoxConstraints parentConstrains, BoxConstraints constrains) {
    viewContext = context;
    if (constrains.maxWidth < 0) {
      return [];
    }
    var blocks = blockManager.layout(
        context, scrollOffset, Size(blockMaxWidth, visionHeight), padding);
    var ret = <Widget>[];
    //构建搜索背景色(黄色)
    for (var block in blocks) {
      var ranges = block.searchRanges;
      if (ranges != null) {
        for (var selection in ranges) {
          var boxes = block.getBoxesForSelection(selection);
          for (var box in boxes) {
            var boxRect = box.toRect().translate(
                padding.left, block.top - scrollOffset + padding.top);
            //边界运算
            boxRect = Rect.fromLTWH(
                    padding.left - 1,
                    0,
                    visionWidth + 2 - padding.left - padding.right,
                    visionHeight)
                .intersect(boxRect);
            if (boxRect.width > 0 && boxRect.height > 0) {
              ret.add(Positioned(
                left: boxRect.left,
                top: boxRect.top,
                width: boxRect.width,
                height: boxRect.height,
                child: Container(
                  color: Colors.yellow,
                ),
              ));
            }
          }
        }
      }
    }
    //构建选择颜色
    var selectStart = selectState.realStart;
    var selectEnd = selectState.realEnd;
    for (var block in blocks) {
      block.selected = false;
    }
    if (selectStart != null &&
        selectEnd != null &&
        selectStart.isValid &&
        selectEnd.isValid) {
      var startBlock = selectStart.block!;
      var startPosition = selectStart.textPosition!;
      var endBlock = selectEnd.block!;
      var endPosition = selectEnd.textPosition!;
      if (startBlock.top > endBlock.top) {
        startBlock = selectEnd.block!;
        endBlock = selectStart.block!;
        startPosition = selectEnd.textPosition!;
        endPosition = selectStart.textPosition!;
      }
      //选择高亮
      for (var block in blocks) {
        //判断block的y是否在start block和end block之间
        if (block.top < startBlock.top || block.top > endBlock.top) continue;
        TextPosition drawStart, drawEnd;
        drawStart = block.startPosition;
        drawEnd = block.endPosition;
        if (block.top == startBlock.top) {
          drawStart = startPosition;
        }
        if (block.top == endBlock.top) {
          drawEnd = endPosition;
        }
        block.selected = true;
        block.selectedStart = drawStart;
        block.selectedEnd = drawEnd;
        //边界运算,在背景之后无需绘制
        var blockOffset = block.top - scrollOffset + padding.top;
        if (blockOffset + block.height < 0 || blockOffset > visionHeight) {
          continue;
        }
        var selection = TextSelection.fromPosition(drawStart).extendTo(drawEnd);
        var boxes = block.getBoxesForSelection(selection);
        for (var box in boxes) {
          var boxRect = box
              .toRect()
              .translate(padding.left, block.top - scrollOffset + padding.top);
          //边界运算
          boxRect = Rect.fromLTWH(padding.left - 1, 0,
                  visionWidth + 2 - padding.left - padding.right, visionHeight)
              .intersect(boxRect);
          if (boxRect.width > 0 && boxRect.height > 0) {
            ret.add(Positioned(
              left: boxRect.left,
              top: boxRect.top,
              width: boxRect.width,
              height: boxRect.height,
              child: Container(
                color: Colors.blueAccent,
              ),
            ));
          }
        }
      }
    }

    //构建block视图
    for (var block in blocks) {
      var pos = Positioned(
        key: ValueKey(block.hashCode),
        left: padding.left,
        top: block.top - scrollOffset + padding.top,
        width: max(0, constrains.maxWidth - padding.horizontal),
        height: block.height,
        child: constrains.maxWidth - padding.horizontal <= 0
            ? Container()
            : block.buildWidget(context),
      );
      if (block.isSingleBlock) {
        ret.add(SingleWidget(
          child: pos,
        ));
      } else {
        ret.add(pos);
      }
    }
    return ret;
  }

  Widget? buildCursorWidget() {
    if (editable == false) {
      return null;
    }
    if (!focusNode.hasFocus ||
        (focusNode.hasFocus && cursorState.freshShowing)) {
      var cursorPosition = cursorState.cursorPosition;
      if (cursorPosition == null) {
        return null;
      }
      var blockIndex = cursorPosition.blockIndex;
      var textPosition = cursorPosition.textPosition;
      if (blockIndex == null ||
          textPosition == null ||
          blockIndex >= blockManager.blocks.length) {
        return null;
      }
      var block = blockManager.blocks[blockIndex];
      var rect = block.getCursorRect(textPosition);
      if (rect == null) {
        return null;
      }
      double cursorY = block.top - scrollOffset;
      var cursorRect = rect.translate(padding.left, cursorY + padding.top);
      cursorRect = Rect.fromLTWH(padding.left - 1, 0,
              visionWidth + 2 - padding.left - padding.right, visionHeight)
          .intersect(cursorRect);
      return Positioned(
        left: cursorRect.left,
        top: cursorRect.top,
        width: cursorRect.width,
        height: cursorRect.height,
        child: Container(
          color: EditTheme.of(viewContext).cursorColor,
        ),
      );
    }
    return null;
  }

  void relayout() {
    for (var block in blockManager.blocks) {
      block.relayoutFlag = true;
    }
    blockManager.relayoutFlag = true;
    updateWidgetState();
  }

  /// 链接悬浮打开
  List<PopupPositionWidget> buildLinkFloatWidgets() {
    var hover = cursorState.hoverPosition;
    var result = <PopupPositionWidget>[];
    if (hover != null && hover.block != null && hover.textPosition != null) {
      var block = hover.block!;
      var position = hover.textPosition!;
      var link = block.getLink(position);
      if (link != null) {
        var rect = block.getCursorRect(TextPosition(offset: link.textOffset));
        if (rect != null) {
          double cursorY = block.top - scrollOffset;
          var cursorRect = rect.translate(0, cursorY);
          result.add(PopupPositionWidget(
            keepVision: true,
            left: cursorRect.left + padding.left,
            bottom: visionHeight - (cursorRect.top + padding.top),
            child: MouseRegion(
              hitTestBehavior: HitTestBehavior.opaque,
              onEnter: (event) {},
              onHover: (event) {},
              onExit: (event) {},
              cursor: MaterialStateMouseCursor.clickable,
              child: Container(
                height: 30,
                width: 150,
                color: Colors.black.withAlpha(155),
                child: Row(
                  children: [
                    //打开
                    GestureDetector(
                        onTap: () {
                          launchUrl(Uri.parse(link.textElement.url ?? ""));
                          cursorState.hoverPosition = null;
                          updateWidgetState();
                        },
                        child: const SizedBox(
                          width: 50,
                          height: 30,
                          child: Center(
                            child: Text(
                              "打开",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )),
                    //复制
                    GestureDetector(
                        onTap: () {
                          Clipboard.setData(
                              ClipboardData(text: link.textElement.url ?? ""));
                          cursorState.hoverPosition = null;
                          updateWidgetState();
                        },
                        child: const SizedBox(
                          width: 50,
                          height: 30,
                          child: Center(
                            child: Text(
                              "复制",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )),
                    //编辑
                    GestureDetector(
                        onTap: () {
                          cursorState.hoverPosition = null;
                          updateWidgetState();
                          showMobileDialog(
                              context: viewContext,
                              builder: (context) {
                                var linkController =
                                    fluent.TextEditingController(
                                        text: link.textElement.url);
                                var textController =
                                    fluent.TextEditingController(
                                        text: link.textElement.text);
                                return fluent.ContentDialog(
                                  constraints: isMobile
                                      ? const BoxConstraints(maxWidth: 300)
                                      : fluent.kDefaultContentDialogConstraints,
                                  content: fluent.Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      fluent.Container(
                                        margin: const EdgeInsets.only(
                                            bottom: 10, top: 10),
                                        child: fluent.TextBox(
                                          placeholder: link.textElement.text,
                                          controller: textController,
                                        ),
                                      ),
                                      fluent.Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 10),
                                        child: fluent.TextBox(
                                          placeholder: link.textElement.url,
                                          controller: linkController,
                                        ),
                                      ),
                                    ],
                                  ),
                                  title: const fluent.Text("编辑链接"),
                                  actions: [
                                    fluent.Button(
                                      child: const Text('取消'),
                                      onPressed: () {
                                        Navigator.pop(context, '取消');
                                        // Delete file here
                                      },
                                    ),
                                    fluent.FilledButton(
                                        onPressed: () {
                                          link.textElement.text =
                                              textController.text;
                                          link.textElement.url =
                                              linkController.text;
                                          if (block is TextBlock) {
                                            block.textElement.calcLength();
                                            block.relayoutFlag = true;
                                          } else if (block is TableBlock) {
                                            block.calcElementLength(position);
                                            block.calcLength();
                                            block.relayoutFlag = true;
                                          }
                                          Navigator.pop(context, '确定');
                                        },
                                        child: const Text("确定")),
                                  ],
                                );
                              });
                        },
                        child: SizedBox(
                          width: 50,
                          height: 30,
                          child: const Center(
                            child: Text(
                              "编辑",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ));
        }
      }
    }
    return result;
  }

  /// 获取悬浮组件(check box,代码复制按钮,图片复制按钮等控件)
  List<PopupPositionWidget> buildFloatWidgets() {
    var result = <PopupPositionWidget>[];
    for (var block in blockManager.layoutBlocks) {
      result.addAll(block.buildFloatWidgets());
    }
    result.addAll(buildLinkFloatWidgets());
    result.addAll(buildDragSelectFloatWidgets());
    var tool = buildDesktopFloatToolWidget();
    if (tool != null) {
      result.add(tool);
    }
    result.sort((a, b) => a.layerIndex.compareTo(b.layerIndex));
    return result;
  }

  List<PopupPositionWidget> buildDragSelectFloatWidgets() {
    if (!isMobile) {
      return [];
    }
    if (!selectState.hasSelect) {
      return [];
    }
    var result = <PopupPositionWidget>[];
    var startCursorSelectWidget =
        buildCursorSelectWidget(selectState.realStart, true);
    var endCursorSelectWidget =
        buildCursorSelectWidget(selectState.realEnd, false);
    if (startCursorSelectWidget != null) {
      result.add(startCursorSelectWidget);
    }
    if (endCursorSelectWidget != null) {
      result.add(endCursorSelectWidget);
    }
    return result;
  }

  PopupPositionWidget? buildCursorSelectWidget(
      CursorPosition? position, bool isStartMode) {
    if (position == null) {
      return null;
    }
    var block = position.block;
    if (block == null) {
      return null;
    }
    var pos = position.textPosition;
    if (pos == null) {
      return null;
    }
    var rect = block.getCursorRect(pos);
    if (rect == null) {
      return null;
    }
    final cursorEventStart =
        rect.bottomCenter.translate(0, block.top - scrollOffset - 10);
    rect = rect.translate(
        padding.left, padding.top + block.top - scrollOffset + rect.height);
    if (isStartMode) {
      rect = rect.translate(-23, 0);
    } else {
      rect = rect.translate(1, 0);
    }
    return PopupPositionWidget(
      key: ValueKey("$hashCode-$isStartMode"),
      keepVision: false,
      layerIndex: 10,
      left: rect.left,
      top: rect.top,
      width: 24,
      height: 24,
      child: MouseRegion(
        cursor: MaterialStateMouseCursor.clickable,
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (event) {
            selectState.swapToRealSelect(this);
            isFloatWidgetDragging = true;
            selectState.dragCursorStartEvent = event;
            selectState.dragCursorStartPosition = cursorEventStart;
            selectState.isCursorDragging = true;
            SelectDragListener.emitChange(viewContext);
            EditState.of(viewContext).updateState();
          },
          onPointerUp: (event) {
            selectState.isCursorDragging = false;
            isFloatWidgetDragging = false;
            EditState.of(viewContext).updateState();
            mouseKeyboardState.stopMouseScrollTimer();
            SelectDragListener.emitChange(viewContext);
          },
          onPointerCancel: (event) {
            isFloatWidgetDragging = false;
            EditState.of(viewContext).updateState();
            mouseKeyboardState.stopMouseScrollTimer();
            SelectDragListener.emitChange(viewContext);
          },
          onPointerMove: (event) {
            startMouseScrollTimer();
            calcMouseScrollSpeed(
                event.localPosition + Offset(rect?.left ?? 0, rect?.top ?? 0));
            var startEvent = selectState.dragCursorStartEvent;
            var startCursorPosition = selectState.dragCursorStartPosition;
            if (startEvent == null || startCursorPosition == null) {
              return;
            }
            var newCursorPosition = startCursorPosition +
                (event.localPosition - startEvent.localPosition);
            var newPosition = getCursorPosition(newCursorPosition);
            if (isStartMode) {
              //必须小于right
              var newBlockIndex = newPosition.blockIndex!;
              var endBlockIndex = selectState.realEnd!.blockIndex!;
              if (newBlockIndex < endBlockIndex) {
                if (selectState.start?.equalsCursorIndex(newPosition) != true) {
                  HapticFeedback.selectionClick();
                }
                selectState.start = newPosition;
                updateWidgetState();
              } else if (newBlockIndex == endBlockIndex) {
                var newTextIndex = newPosition.textPosition!.offset;
                var rightTextIndex = selectState.realEnd!.textPosition!.offset;
                if (newTextIndex <= rightTextIndex) {
                  if (selectState.start?.equalsCursorIndex(newPosition) !=
                      true) {
                    HapticFeedback.selectionClick();
                  }
                  selectState.start = newPosition;
                  updateWidgetState();
                }
              }
            } else {
              //必须大于于start
              var newBlockIndex = newPosition.blockIndex!;
              var startBlockIndex = selectState.realStart!.blockIndex!;
              if (newBlockIndex > startBlockIndex) {
                if (selectState.end?.equalsCursorIndex(newPosition) != true) {
                  HapticFeedback.selectionClick();
                }
                selectState.end = newPosition;
                updateWidgetState();
              } else if (newBlockIndex == startBlockIndex) {
                var newTextIndex = newPosition.textPosition!.offset;
                var leftTextIndex = selectState.realStart!.textPosition!.offset;
                if (newTextIndex >= leftTextIndex) {
                  if (selectState.end?.equalsCursorIndex(newPosition) != true) {
                    HapticFeedback.selectionClick();
                  }
                  selectState.end = newPosition;
                  updateWidgetState();
                }
              }
            }
          },
          child: Container(
            decoration: BoxDecoration(
                color: Colors.deepOrange.withOpacity(0.8),
                borderRadius: BorderRadius.only(
                  topLeft:
                      isStartMode ? Radius.circular(24) : Radius.circular(0),
                  topRight:
                      isStartMode ? Radius.circular(0) : Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                )),
          ),
        ),
      ),
    );
  }

  bool get isMobile {
    if (kIsWeb) return false;
    return [
      TargetPlatform.iOS,
      TargetPlatform.android,
    ].contains(defaultTargetPlatform);
  }

  /// 获取悬浮组件(check box,代码复制按钮,图片复制按钮等控件)
  List<PopupPositionWidget> buildBackgroundWidgets() {
    var result = <PopupPositionWidget>[];
    for (var block in blockManager.layoutBlocks) {
      result.addAll(block.buildBackgroundWidgets());
    }
    result.sort((a, b) => a.layerIndex.compareTo(b.layerIndex));
    return result;
  }

  Offset? getMousePosition() {
    var mousePosition = cursorState.mouseEventPosition;
    if (mouseKeyboardState.mouseHoverEvent.isNotEmpty) {
      var hoverLast = mouseKeyboardState.mouseHoverEvent.last;
      mousePosition = hoverLast.localPosition;
    }
    return mousePosition;
  }

  void updateWindowCursorRecordPosition() {
    var position = cursorState.cursorPosition;
    if (position == null) {
      return;
    }
    cursorRecord.updateCursorWindowPosition(position, scrollOffset);
  }

  ///鼠标事件
  void onMouseEvent(PointerEvent event) {
    var originEvent = event;
    event = originEvent.copyWith(
        position: event.position.translate(-padding.left, -padding.top));
    mouseKeyboardState.onMouseEvent(event);
    if (event is PointerDownEvent) {
      mouseKeyboardState.mouseDrag = false;
      //鼠标左键
      if (event.buttons == 1) {
        mouseKeyboardState.mouseLeftDown = true;
        mouseKeyboardState.mouseDownTime =
            DateTime.now().millisecondsSinceEpoch;
        mouseKeyboardState.mouseDownOffset = event.localPosition;
        if (!isMobile) {
          var position = getCursorPosition(event.localPosition);
          //点击down事件：更新光标位置，记录选择开始位置
          if (selectState.shiftDown && cursorState.cursorPosition != null) {
            if (selectState.start == null) {
              recordSelectStart(cursorState.cursorPosition);
            }
            recordSelectEnd(position);
          } else {
            recordSelectStart(position);
          }
          cursorRecord.updateCursorWindowPosition(position, scrollOffset);
          updateCursor(position, applyUpdate: true);
        }
      }
    }
    if (event is PointerMoveEvent) {
      if (mouseKeyboardState.mouseDrag == false) {
        if (event.buttons == 1) {
          var distance =
              (event.localPosition - mouseKeyboardState.mouseDownOffset!)
                  .distance;
          if (distance > 2) {
            mouseKeyboardState.mouseDrag = true;
          }
        }
      } else {
        if (event.buttons == 1) {
          if (!isMobile) {
            startMouseScrollTimer();
            calcMouseScrollSpeed(event.localPosition);
          }
          cursorState.mouseEventPosition = event.localPosition;
          var position = getCursorPosition(event.localPosition);
          if ((false == isMobile) && position.isValid) {
            //鼠标滑动事件：更新cursor位置
            updateCursor(position, applyUpdate: true);
            recordSelectEnd(position);
            updateWidgetState();
          }
        }
      }
    }
    if (event is PointerUpEvent) {
      if (mouseKeyboardState.mouseLeftDown) {
        if (DateTime.now().millisecondsSinceEpoch -
                mouseKeyboardState.mouseDownTime <
            300) {
          var dis = calcDistance(
              event.localPosition, mouseKeyboardState.mouseDownOffset);
          if (dis < 10) {
            //click
            if (calcDistance(mouseKeyboardState.mouseClickPosition,
                        event.localPosition) <
                    10 &&
                DateTime.now().millisecondsSinceEpoch -
                        mouseKeyboardState.mouseClickTime <
                    300) {
              mouseKeyboardState.mouseClickCount++;
              if (mouseKeyboardState.mouseClickCount == 2) {
                onDoubleClick(event.localPosition);
              }
            } else {
              mouseKeyboardState.mouseClickCount = 1;
              onOneClick(event.localPosition);
            }
            mouseKeyboardState.mouseClickTime =
                DateTime.now().millisecondsSinceEpoch;
            mouseKeyboardState.mouseClickPosition = event.localPosition;
          } else {
            mouseKeyboardState.mouseClickCount = 0;
            mouseKeyboardState.mouseClickTime = 0;
            mouseKeyboardState.mouseClickPosition = null;
          }
        }
        mouseKeyboardState.mouseDownTime = 0;
      }
      mouseKeyboardState.mouseLeftDown = false;
      mouseKeyboardState.stopMouseScrollTimer();
      if (!mouseKeyboardState.mouseDrag) {
        scrollToCursorPosition();
      }
      mouseKeyboardState.mouseDrag = false;
    }
    if (event is PointerHoverEvent ||
        event is PointerEnterEvent ||
        event is PointerExitEvent ||
        event is PointerMoveEvent) {
      updateHoverCursorPosition();
    }
  }

  ///计算2点的距离
  double calcDistance(Offset? a, Offset? b) {
    a = a ?? Offset.zero;
    b = b ?? Offset.zero;
    var dx = (a.dx) - (b.dx);
    var dy = (a.dy) - (b.dy);
    return sqrt(dy * dy + dx * dx);
  }

  ///双击选择词语
  void selectWord(Offset location) {
    //选择文字
    var cursor = getCursorPosition(location);
    if (cursor.isValid) {
      selectCursor(cursor);
    }
  }

  void selectCursor(CursorPosition cursorPosition) {
    var pos = cursorPosition.textPosition!;
    var block = cursorPosition.block!;
    var range = block.getWordBoundary(pos);
    if (range == null) {
      return;
    }
    var start = TextPosition(
      offset: range.start,
      affinity: TextAffinity.upstream,
    );
    var end = TextPosition(
      offset: range.end,
      affinity: TextAffinity.downstream,
    );
    recordSelectStart(CursorPosition(block: block, textPosition: start));
    updateCursor(
      CursorPosition(
          block: block, textPosition: end, rect: block.getCursorRect(end)),
      applyUpdate: true,
    );
    recordSelectEnd(CursorPosition(block: block, textPosition: end));
    updateWidgetState();
  }

  ///单击
  void onOneClick(Offset location) {
    //弹出输入法
    if (editable) {
      inputManager.composing = null;
      inputManager.closeInputMethod();
      inputManager.openInputMethod();
    }
    if (!selectState.shiftDown) {
      selectState.clearSelect();
    }
    var position = getCursorPosition(location);
    cursorRecord.updateCursorWindowPosition(position, scrollOffset);
    updateCursor(position, applyUpdate: true);
    visitSelectElement(
      (block, element) {
        if (block is TextBlock) {
          block.textElement.hideText = false;
        }
        if (element is WenTextElement) {
          element.hideText = false;
          block.relayoutFlag = true;
        }
      },
    );
  }

  ///双击
  void onDoubleClick(Offset location) {
    selectWord(location);
  }

  ///三击
  void onTripleClick(Offset location) {}

  void calcMouseScrollSpeed(Offset position) {
    cursorState.mouseEventPosition = position;
    var dy = position.dy;
    if (dy < 0) {
    } else if (dy > visionHeight) {
      dy -= visionHeight;
    } else {
      dy = 0;
    }
    dy /= 10;
    var dx = position.dx;
    if (dx < 0) {
    } else if (dx > visionWidth - padding.left - padding.right) {
      dx -= (visionWidth - padding.left - padding.right);
    } else {
      dx = 0;
    }
    dx /= 10;
    if (isMobile) {
      dx /= 2;
      dy /= 2;
    }
    mouseKeyboardState.mouseScrollSpeedX = dx;
    mouseKeyboardState.mouseScrollSpeedY = dy;
  }

  void startMouseScrollTimer() {
    if (mouseKeyboardState.mouseScrollTimer != null) {
      return;
    }
    mouseKeyboardState.mouseScrollTimer =
        Timer.periodic(const Duration(milliseconds: 10), (timer) {
      //根据速度滚动
      if (mouseKeyboardState.mouseScrollSpeedY != 0 ||
          mouseKeyboardState.mouseScrollSpeedX != 0) {
        scrollVertical(mouseKeyboardState.mouseScrollSpeedY);
        scrollHorizontal(mouseKeyboardState.mouseScrollSpeedX);
        if (isMobile) {
          return;
        }
        var eventPosition = cursorState.mouseEventPosition;
        if (eventPosition != null) {
          var position = getCursorPosition(eventPosition);
          if (position.isValid) {
            //鼠标滑动事件：更新cursor位置
            updateCursor(position, applyUpdate: true);
            recordSelectEnd(position);
            updateWidgetState();
          }
        }
      }
    });
  }

  /// 更新选择的光标
  void updateSelectCursor() {
    try {
      var start = selectState.start;
      var blockStart = blockManager.blocks[start!.blockIndex!];
      selectState.start = blockStart.getCursorPosition(start.textPosition!)
        ..blockIndex = start.blockIndex
        ..blockVisionTop = blockStart.top - scrollOffset;
    } catch (ignore) {}
    try {
      var end = selectState.end;
      var blockEnd = blockManager.blocks[end!.blockIndex!];
      selectState.end = blockEnd.getCursorPosition(end.textPosition!)
        ..blockIndex = end.blockIndex
        ..blockVisionTop = blockEnd.top - scrollOffset;
    } catch (ignore) {}
  }

  /// 刷新光标位置
  void refreshCursorPosition() {
    var cPos = cursorState.cursorPosition;
    var block = cPos?.block;
    var tPos = cPos?.textPosition;
    if (block != null && tPos != null) {
      var index = cPos?.blockIndex;
      if (index != null && index < blockManager.blocks.length) {
        updateCursor(blockManager.blocks[index].getCursorPosition(tPos),
            scrollToShowCursor: false, applyUpdate: false);
      } else {
        updateCursor(block.getCursorPosition(tPos),
            scrollToShowCursor: false, applyUpdate: false);
      }
    }
  }

  ///更新光标位置
  void updateCursor(CursorPosition position,
      {bool scrollToShowCursor = true, bool applyUpdate = false}) {
    var block = position.block;
    if (block != null) {
      position.blockIndex = blockManager.indexOfBlockByBlock(block);
      position.blockVisionTop = block.top - scrollOffset;
    }
    cursorRecord.updateCursorPosition(position);
    if (!focusNode.hasFocus && editable && viewContext.mounted) {
      FocusScope.of(viewContext).requestFocus(focusNode);
    }
    var old = cursorState.cursorPosition;
    if (old != null) {
      var oldBlock = old.block;
      if (oldBlock != null) {
        oldBlock.relayoutFlag = true;
        oldBlock.cursorPosition = null;
      }
    }
    cursorState.cursorPosition = position;
    position.block?.cursorPosition = position.textPosition;
    position.block?.relayoutFlag = true;
    startCursorTimer();
    if (!mouseKeyboardState.mouseDrag && scrollToShowCursor) {
      scrollToCursorPosition();
    }
  }

  ///更新鼠标划过位置：用于计算链接是否被划过，滚动时需要更新，鼠标移动时需要更新
  void updateHoverCursorPosition() {
    var event = <PointerEvent>[];
    if (mouseKeyboardState.mouseHoverEvent.isNotEmpty) {
      event.add(mouseKeyboardState.mouseHoverEvent.last);
    }
    if (event.isEmpty) {
      return;
    }
    event.sort((a, b) => a.timeStamp.compareTo(b.timeStamp));
    var location = event.last.localPosition;
    var hover = cursorState.hoverPosition;
    var hoverBlock = hover?.block;
    if (hoverBlock != null) {
      hoverBlock.relayoutFlag = true;
      hoverBlock.hoverPosition = null;
    }
    var position = getHoverCursorPosition(location);
    cursorState.hoverPosition = position;
    hoverBlock = position?.block;
    if (mouseKeyboardState.enter && hoverBlock != null) {
      hoverBlock.relayoutFlag = true;
      hoverBlock.hoverPosition = position?.textPosition;
    }
    updateWidgetState();
  }

  ///更新输入法位置
  void updateInputMethodWindowPosition() {
    if (!(Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
      return;
    }
    var position = cursorState.cursorPosition;
    if (selectState.hasSelectRange) {
      position = selectState.realStart;
    }
    var block = position?.block;
    if (position != null && block != null) {
      var composingLength = inputManager.composing?.text.length ?? 0;
      var inputPos =
          max(0, (position.textPosition?.offset ?? 0) - composingLength);
      var inputRect = block.getCursorRect(TextPosition(offset: inputPos));
      if (inputRect == null) {
        return;
      }
      inputManager.updateInputPosition(
        Size(blockMaxWidth, visionHeight),
        inputRect
            .shift(Offset(padding.left, block.top - scrollOffset + padding.top))
            .shift(visionOffset),
        getComposingRect()
            ?.shift(
                Offset(padding.left, block.top - scrollOffset + padding.top))
            .shift(visionOffset),
      );
    }
  }

  Rect? getComposingRect() {
    var composingLength = inputManager.composing?.text.length ?? 0;
    var position = cursorState.cursorPosition;
    var composingPos =
        max(0, (position?.textPosition?.offset ?? 0) - composingLength);
    var boxes = position?.block?.getBoxesForSelection(TextSelection(
        baseOffset: composingPos,
        extentOffset: composingPos + composingLength));
    if (boxes != null) {
      double left = position?.rect?.left ?? 0;
      double right = position?.rect?.right ?? 0;
      double top = position?.rect?.top ?? 0;
      double bottom = position?.rect?.bottom ?? 0;
      for (var box in boxes) {
        var boxRect = box.toRect();
        if (left == double.infinity || left > boxRect.left) {
          left = boxRect.left;
        }
        if (top == double.infinity || top > boxRect.top) {
          top = boxRect.top;
        }

        if (right == double.infinity || right < boxRect.right) {
          right = boxRect.right;
        }
        if (bottom == double.infinity || bottom < boxRect.bottom) {
          bottom = boxRect.bottom;
        }
      }
      return Rect.fromLTRB(left, top, right, bottom);
    }
    return null;
  }

  ///得到光标位置：用于显示光标
  CursorPosition getCursorPosition(Offset eventPosition) {
    var clickPosition = eventPosition.translate(0, scrollOffset);
    var cursorBlock = blockManager.getBlockByOffset(clickPosition.dy);
    TextPosition? textPosition;
    Rect? cursorRect;
    if (cursorBlock != null) {
      var pos = clickPosition.translate(0, -cursorBlock.top);
      textPosition = cursorBlock.getPositionForOffset(pos);
      if (textPosition != null) {
        cursorRect = cursorBlock.getCursorRect(textPosition);
      }
    }
    return CursorPosition(
        block: cursorBlock,
        textPosition: textPosition,
        rect: cursorRect,
        blockIndex: blockManager.indexOfBlock(clickPosition.dy));
  }

  ///得到光标位置：用于显示鼠标划过位置(链接)
  CursorPosition? getHoverCursorPosition(Offset eventPosition) {
    var clickPosition = eventPosition.translate(0, scrollOffset);
    var cursorBlock = blockManager.getBlockByOffset(clickPosition.dy);
    TextPosition? textPosition;
    if (cursorBlock != null) {
      if (cursorBlock.top + cursorBlock.height < clickPosition.dy ||
          cursorBlock.top > clickPosition.dy) {
        return null;
      }
      var pos = clickPosition.translate(0, -cursorBlock.top);
      textPosition = cursorBlock.getPositionForOffset(pos);
      if (textPosition != null) {
        var boxes = cursorBlock.getBoxesForSelection(TextSelection(
            baseOffset: max(textPosition.offset - 1, 0),
            extentOffset: min(
              textPosition.offset + 1,
              cursorBlock.length,
            )));
        var ret = false;
        if (boxes.isNotEmpty) {
          for (var box in boxes) {
            if (box.toRect().contains(pos)) {
              ret = true;
              break;
            }
          }
        }
        if (!ret) {
          return null;
        }
      }
    }
    return CursorPosition(
      block: cursorBlock,
      textPosition: textPosition,
    );
  }

  ///记录光标选择开始位置
  void recordSelectStart(CursorPosition? cursorPosition) {
    if (cursorPosition != null && cursorPosition.block != null) {
      cursorPosition.blockVisionTop = cursorPosition.block!.top - scrollOffset;
      cursorPosition.blockIndex =
          blockManager.indexOfBlockByBlock(cursorPosition.block!);
    }
    selectState.start = cursorPosition;
    selectState.end = null;
  }

  ///记录光标选择开始位置
  void recordSelectEnd(CursorPosition? cursorPosition) {
    if (cursorPosition != null && cursorPosition.block != null) {
      cursorPosition.blockVisionTop = cursorPosition.block!.top - scrollOffset;
      cursorPosition.blockIndex =
          blockManager.indexOfBlockByBlock(cursorPosition.block!);
    }
    selectState.end = cursorPosition;
  }

  ///布局构建事件
  void onLayoutBuild(
    BuildContext context,
    BoxConstraints parentConstrains,
    BoxConstraints constrains,
  ) {
    viewContext = context;
    inputManager.context = context;
    for (var block in blockManager.blocks) {
      block.context = context;
    }
    bool sizeChanged = visionWidth != constrains.maxWidth ||
        visionHeight != constrains.maxHeight;
    var oldHeight = visionHeight;
    visionWidth = constrains.maxWidth;
    visionHeight = constrains.maxHeight;
    visionOffset =
        Offset(parentConstrains.maxWidth / 2 - constrains.maxWidth / 2, 0);
    if (sizeChanged) {
      onSizeChanged(context, oldHeight > visionHeight);
    }
    blockManager.layout(context, scrollOffset,
        Size(blockMaxWidth, max(200, visionHeight * 1.5)), padding);
  }

  void onScrollerChanged() {}

  ///窗口大小发生变化
  void onSizeChanged(BuildContext context, bool showCursor) {
    SchedulerBinding.instance.scheduleFrameCallback((timeStamp) {
      var pos = cursorState.cursorPosition;
      if (pos != null && pos.isValid) {
        pos.rect = pos.block?.getCursorRect(pos.textPosition!);
        bool scrollToShowCursor = isMobile && showCursor;
        updateCursor(pos,
            scrollToShowCursor: scrollToShowCursor, applyUpdate: true);
      }
    });
  }

  ///焦点发生变化
  void onFocusChanged(bool focus) {
    if (!focus) {
      if (!isMobile) {
        inputManager.closeInputMethod();
        updateWidgetState();
      }
    } else {
      if (editable) {
        if (!isMobile) {
          inputManager.openInputMethod();
        }
        showCursorOnOpen();
      }
    }
  }

  ///键盘事件:与onKeyEvent不同的是，这个方法可以处理组合按键
  KeyEventResult onKey(FocusNode node, RawKeyEvent event) {
    var len = inputManager.composing?.text.length;
    if (len != null && len != 0) {
      return KeyEventResult.skipRemainingHandlers;
    }
    if (!focusNode.hasFocus) {
      return KeyEventResult.ignored;
    }
    mouseKeyboardState.onKey(node, event);
    if (event is RawKeyDownEvent) {
      if (event.physicalKey == PhysicalKeyboardKey.tab) {
        if (event.isShiftPressed) {
          removeIndent();
        } else {
          addIndent();
        }
        return KeyEventResult.handled;
      }
      if (event.physicalKey == PhysicalKeyboardKey.keyA) {
        if (event.isControlPressed || event.isMetaPressed) {
          selectAll();
          return KeyEventResult.handled;
        }
      }
      if (event.physicalKey == PhysicalKeyboardKey.pageDown) {
        //下一页
        toPageDown();
        return KeyEventResult.handled;
      }
      if (event.physicalKey == PhysicalKeyboardKey.pageUp) {
        //上一页
        toPageUp();
        return KeyEventResult.handled;
      }

      if (event.physicalKey == PhysicalKeyboardKey.home) {
        //home
        toHome();
        return KeyEventResult.handled;
      }
      if (event.physicalKey == PhysicalKeyboardKey.end) {
        //end
        toEnd();
        return KeyEventResult.handled;
      }
      if (event.physicalKey == PhysicalKeyboardKey.arrowLeft) {
        //left
        toLeft();
        return KeyEventResult.handled;
      }
      if (event.physicalKey == PhysicalKeyboardKey.arrowRight) {
        //right
        toRight();
        return KeyEventResult.handled;
      }
      if (event.physicalKey == PhysicalKeyboardKey.arrowUp) {
        //up
        toUp();
        return KeyEventResult.handled;
      }
      if (event.physicalKey == PhysicalKeyboardKey.arrowDown) {
        //down
        toDown();
        return KeyEventResult.handled;
      }
      if (event.physicalKey == PhysicalKeyboardKey.backspace ||
          event.physicalKey == PhysicalKeyboardKey.delete) {
        delete(event.physicalKey == PhysicalKeyboardKey.backspace);
        record();
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        delete(true);
        record();
        return KeyEventResult.handled;
      }
      if (event.physicalKey == PhysicalKeyboardKey.enter ||
          event.physicalKey == PhysicalKeyboardKey.numpadEnter ||
          event.logicalKey == LogicalKeyboardKey.enter) {
        if (event.isControlPressed || event.isMetaPressed) {
          if (event.isShiftPressed) {
            addTextBlockBefore();
          } else {
            addTextBlock();
          }
        } else {
          enter();
        }
        record();
        WidgetsBinding.instance.scheduleFrameCallback((timeStamp) {
          refreshCursorPosition();
        });
        return KeyEventResult.handled;
      }

      if (event.physicalKey == PhysicalKeyboardKey.keyC &&
          (event.isMetaPressed || event.isControlPressed)) {
        copy(copyText: event.isAltPressed);
        return KeyEventResult.handled;
      }
      if (event.physicalKey == PhysicalKeyboardKey.keyX &&
          (event.isMetaPressed || event.isControlPressed)) {
        cut();
        return KeyEventResult.handled;
      }
      if (event.physicalKey == PhysicalKeyboardKey.keyV &&
          (event.isMetaPressed || event.isControlPressed)) {
        paste();
        return KeyEventResult.handled;
      }

      if ((event.physicalKey == PhysicalKeyboardKey.numpad1 ||
              event.physicalKey == PhysicalKeyboardKey.digit1) &&
          (event.isMetaPressed || event.isControlPressed)) {
        changeTextLevel(1);
        record();
        return KeyEventResult.handled;
      }
      if ((event.physicalKey == PhysicalKeyboardKey.numpad2 ||
              event.physicalKey == PhysicalKeyboardKey.digit2) &&
          (event.isMetaPressed || event.isControlPressed)) {
        changeTextLevel(2);
        record();
        return KeyEventResult.handled;
      }
      if ((event.physicalKey == PhysicalKeyboardKey.numpad3 ||
              event.physicalKey == PhysicalKeyboardKey.digit3) &&
          (event.isMetaPressed || event.isControlPressed)) {
        changeTextLevel(3);
        record();
        return KeyEventResult.handled;
      }
      if ((event.physicalKey == PhysicalKeyboardKey.numpad4 ||
              event.physicalKey == PhysicalKeyboardKey.digit4) &&
          (event.isMetaPressed || event.isControlPressed)) {
        changeTextLevel(4);
        record();
        return KeyEventResult.handled;
      }
      if ((event.physicalKey == PhysicalKeyboardKey.numpad5 ||
              event.physicalKey == PhysicalKeyboardKey.digit5) &&
          (event.isMetaPressed || event.isControlPressed)) {
        changeTextLevel(5);
        record();
        return KeyEventResult.handled;
      }
      if ((event.physicalKey == PhysicalKeyboardKey.numpad6 ||
              event.physicalKey == PhysicalKeyboardKey.digit6) &&
          (event.isMetaPressed || event.isControlPressed)) {
        changeTextLevel(6);
        record();
        return KeyEventResult.handled;
      }
      if ((event.physicalKey == PhysicalKeyboardKey.numpad7 ||
              event.physicalKey == PhysicalKeyboardKey.digit7) &&
          (event.isMetaPressed || event.isControlPressed)) {
        changeTextLevel(0);
        record();
        return KeyEventResult.handled;
      }
      if ((event.physicalKey == PhysicalKeyboardKey.numpad8 ||
              event.physicalKey == PhysicalKeyboardKey.digit8) &&
          (event.isMetaPressed || event.isControlPressed)) {
        changeTextToQuote();
        record();
        return KeyEventResult.handled;
      }
      if ((event.physicalKey == PhysicalKeyboardKey.numpad9 ||
              event.physicalKey == PhysicalKeyboardKey.digit9) &&
          (event.isMetaPressed || event.isControlPressed)) {
        addFormula();
        return KeyEventResult.handled;
      }
      if ((event.physicalKey == PhysicalKeyboardKey.numpad0 ||
              event.physicalKey == PhysicalKeyboardKey.keyT) &&
          (event.isMetaPressed || event.isControlPressed) &&
          event.isShiftPressed) {
        showAddTableDialog();
        return KeyEventResult.handled;
      }

      if ((event.physicalKey == PhysicalKeyboardKey.keyZ) &&
          (event.isMetaPressed || event.isControlPressed)) {
        undo();
        return KeyEventResult.handled;
      }
      if ((event.physicalKey == PhysicalKeyboardKey.keyY) &&
          (event.isMetaPressed || event.isControlPressed)) {
        redo();
        return KeyEventResult.handled;
      }
      if ((event.physicalKey == PhysicalKeyboardKey.keyK) &&
          (event.isMetaPressed || event.isControlPressed) &&
          event.isAltPressed) {
        toggleCode();
        return KeyEventResult.handled;
      }
      if ((event.physicalKey == PhysicalKeyboardKey.keyL) &&
          (event.isMetaPressed || event.isControlPressed) &&
          event.isShiftPressed) {
        addLink();
        return KeyEventResult.handled;
      }
      if ((event.physicalKey == PhysicalKeyboardKey.keyI) &&
          (event.isMetaPressed || event.isControlPressed)) {
        setItemType();
        return KeyEventResult.handled;
      }
      if ((event.physicalKey == PhysicalKeyboardKey.keyT) &&
          (event.isMetaPressed || event.isControlPressed)) {
        setItemType(itemType: "check");
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  ///键盘事件
  KeyEventResult onKeyEvent(FocusNode node, KeyEvent event) {
    if (!focusNode.hasFocus) {
      return KeyEventResult.ignored;
    }
    mouseKeyboardState.onKeyEvent(node, event);
    return KeyEventResult.ignored;
  }

  void visitElement(
      WenElementVisitor visitor, CursorPosition start, CursorPosition end) {
    if (start.block! == end.block) {
      start.block!
          .visitElement(start.textPosition!, end.textPosition!, visitor);
    } else {
      start.block!
          .visitElement(start.textPosition!, start.block!.endPosition, visitor);
      var startBlockIndex =
          start.blockIndex ?? blockManager.indexOfBlockByBlock(start.block!);
      var endBlockIndex =
          end.blockIndex ?? blockManager.indexOfBlockByBlock(end.block!);
      for (var i = startBlockIndex + 1; i < endBlockIndex; i++) {
        var block = blockManager.blocks[i];
        block.visitElement(block.startPosition, block.endPosition, visitor);
      }
      end.block!
          .visitElement(end.block!.startPosition, end.textPosition!, visitor);
    }
  }

  void visitSelectElement(WenElementVisitor visitor) {
    if (selectState.hasSelect) {
      var start = selectState.realStart;
      var end = selectState.realEnd;
      visitElement(visitor, start!, end!);
    } else {
      var position = cursorState.cursorPosition;
      if (position != null && position.textPosition != null) {
        if (position.textPosition?.affinity == TextAffinity.downstream) {
          var end = position.copy;
          end.textPosition =
              TextPosition(offset: (position.textPosition?.offset ?? 0) + 1);
          visitElement(visitor, position, end);
        } else {
          var start = position.copy;
          start.textPosition =
              TextPosition(offset: (position.textPosition?.offset ?? 0) - 1);
          visitElement(visitor, start, position);
        }
      }
    }
  }

  void visitSelectBlock(WenBlockVisitor visitor, {bool visitCursor = false}) {
    if (selectState.hasSelect) {
      var start = selectState.realStart;
      var end = selectState.realEnd;
      var startBlockIndex =
          start!.blockIndex ?? blockManager.indexOfBlockByBlock(start.block!);
      var endBlockIndex =
          end!.blockIndex ?? blockManager.indexOfBlockByBlock(end.block!);
      for (var i = startBlockIndex; i <= endBlockIndex; i++) {
        var block = blockManager.blocks[i];
        visitor.call(block);
      }
    } else {
      if (visitCursor) {
        var block = cursorState.cursorPosition?.block;
        if (block != null) {
          visitor.call(block);
        }
      }
    }
  }

  /// 复制
  /// 将选择的富文本转为html和文本
  /// 难点：图片、代码、公式等特殊元素转换存在问题 简单解决只给复制文本、图片、代码元素，其他元素通过id复制
  void copy({
    bool copyText = false,
    bool copyMarkdown = false,
  }) async {
    if (selectState.hasSelect) {
      var start = selectState.realStart;
      var end = selectState.realEnd;
      if (start!.block! == end!.block) {
        WenElement element =
            start.block!.copyElement(start.textPosition!, end.textPosition!);
        await copyService.saveCopyCache(viewContext, [element]);
        String html = "<!DOCTYPE html>\n"
            "<html>\n<head>\n"
            "<meta charset=\"utf-8\"></meta></head><body copyid='${copyService.copyId}'>";
        html += element.getHtml();
        html += "</body></html>";
        RichClipboard.setData(
            RichClipboardData(html: html, text: element.getText()));
      } else {
        var copyId = copyService.generateCopyId();
        String html = "<!DOCTYPE html>\n"
            "<html>\n<head>\n"
            "<meta charset=\"utf-8\"></meta></head><body copyid='$copyId'>";
        String text = "";
        var copyElements = <WenElement>[];
        var startSubElement = start.block!
            .copyElement(start.textPosition!, start.block!.endPosition);
        copyElements.add(startSubElement);
        html += startSubElement.getHtml();
        text += startSubElement.getText();
        int startIndex = blockManager.indexOfBlockByBlock(start.block!);
        int endIndex = blockManager.indexOfBlockByBlock(end.block!);
        for (int i = startIndex + 1; i < endIndex; i++) {
          var element = blockManager.blocks[i].element;
          copyElements.add(element);
          html += element.getHtml();
          text += "\n" + element.getText();
        }
        var endSubElement =
            end.block!.copyElement(end.block!.startPosition, end.textPosition!);
        copyElements.add(endSubElement);
        await copyService.saveCopyCache(viewContext, copyElements,
            copyId: copyId);
        html += endSubElement.getHtml();
        text += "\n" + endSubElement.getText();
        html += "</body></html>";
        RichClipboard.setData(RichClipboardData(html: html, text: text));
      }
    }
  }

  void requestFocus() {
    FocusScope.of(viewContext).requestFocus(focusNode);
  }

  /// 由系统拖入事件响应
  Future<void> performDragIn(PerformDropEvent event) async {
    var fileList = <String>[];
    for (var item in event.session.items) {
      var dataReader = item.dataReader;
      if (dataReader == null) {
        continue;
      }
      if (!dataReader.canProvide(Formats.fileUri)) {
        continue;
      }
      var comp = Completer();
      dataReader.getValue(Formats.fileUri, (value) {
        if (value is Uri) {
          var path = value.toFilePath();
          fileList.add(path);
        }
        comp.complete();
      });
      await comp.future;
    }
    showMobileDialog(
        context: viewContext,
        builder: (context) => FutureProgressDialog(
              () async {
                for (var file in fileList) {
                  var stat = File(file).statSync();
                  if (stat.type == FileSystemEntityType.file) {
                    await pasteImage(File(file).readAsBytesSync(),
                        isFile: true, suffix: getFileSuffix(file));
                  }
                }
              }(),
            ));
  }

  ///更新光标位置
  void toPosition(CursorPosition? newPosition, bool updateCursorX,
      {bool scrollToShowCursor = true, bool applyUpdate = true}) {
    if (newPosition == null) {
      return;
    }
    var cursorPosition = cursorState.cursorPosition;
    if (selectState.shiftDown) {
      if (selectState.start == null) {
        recordSelectStart(cursorPosition);
      }
      recordSelectEnd(newPosition);
    } else {
      selectState.clearSelect();
    }
    updateCursor(
      newPosition,
      scrollToShowCursor: scrollToShowCursor,
      applyUpdate: applyUpdate,
    );
    if (updateCursorX) {
      cursorRecord.updateCursorWindowPosition(newPosition, scrollOffset);
    }
  }

  ///光标跳到行头
  void toHome() {
    var cursorPosition = cursorState.cursorPosition;
    if (cursorPosition == null || !cursorPosition.isValid) {
      return;
    }
    var block = cursorPosition.block!;
    var range = block.getLineBoundary(cursorPosition.textPosition!);
    if (range != null) {
      var pos = block.getCursorPosition(TextPosition(
        offset: range.start,
        affinity: TextAffinity.downstream,
      ));
      toPosition(pos, true);
    }
  }

  ///光标跳到行尾
  void toEnd() {
    var cursorPosition = cursorState.cursorPosition;
    if (cursorPosition == null || !cursorPosition.isValid) {
      return;
    }
    var block = cursorPosition.block!;
    var range = block.getLineBoundary(cursorPosition.textPosition!);
    if (range != null) {
      var pos = block.getCursorPosition(TextPosition(
        offset: range.end,
        affinity: TextAffinity.upstream,
      ));
      toPosition(pos, true);
    }
  }

  ///光标左移
  void toLeft() {
    if (!selectState.shiftDown && selectState.hasSelect) {
      var pos = selectState.realStart;
      pos = pos!.block!.getCursorPosition(pos.textPosition!);
      toPosition(pos, true);
      return;
    }
    var position = cursorState.cursorPosition;
    if (position == null || !position.isValid) {
      return;
    }
    var block = position.block!;
    layoutPreviousBlock(block);
    var textPosition = position.textPosition!;
    if (textPosition.offset > 0) {
      var newTextPosition = TextPosition(
          offset: textPosition.offset - 1, affinity: TextAffinity.downstream);
      var newRect = block.getCursorRect(newTextPosition);
      toPosition(
          CursorPosition(
            textPosition: newTextPosition,
            rect: newRect,
            block: block,
          ),
          true);
    } else {
      //如果选择了文字，则到选择开始的地方
      var index = blockManager.indexOfBlockByBlock(block);
      if (index > 0) {
        var newBlock = blockManager.blocks[index - 1];
        var textPosition = newBlock.endPosition;
        var cursorRect = newBlock.getCursorRect(textPosition);
        toPosition(
            CursorPosition(
                block: newBlock, textPosition: textPosition, rect: cursorRect),
            true);
      }
    }
  }

  ///光标右移
  void toRight() {
    if (!selectState.shiftDown && selectState.hasSelect) {
      var pos = selectState.realEnd;
      pos = pos!.block!.getCursorPosition(pos.textPosition!);
      toPosition(pos, true);
      return;
    }
    var position = cursorState.cursorPosition;
    if (position == null || !position.isValid) {
      return;
    }
    var block = position.block!;
    layoutNextBlock(block);
    var textPosition = position.textPosition!;
    var blockEndPosition = block.endPosition;
    if (textPosition.offset < blockEndPosition.offset) {
      var newTextPosition = TextPosition(
          offset: textPosition.offset + 1, affinity: TextAffinity.upstream);
      var newRect = block.getCursorRect(newTextPosition);
      toPosition(
          CursorPosition(
            textPosition: newTextPosition,
            rect: newRect,
            block: block,
          ),
          true);
    } else {
      //如果选择了文字，则到选择开始的地方
      var index = blockManager.indexOfBlockByBlock(block);
      if (index + 1 < blockManager.blocks.length) {
        var newBlock = blockManager.blocks[index + 1];
        var textPosition = newBlock.startPosition;
        var cursorRect = newBlock.getCursorRect(textPosition);
        toPosition(
            CursorPosition(
                block: newBlock, textPosition: textPosition, rect: cursorRect),
            true);
      }
    }
  }

  ///光标上移
  void toUp() {
    if (popupTool.isShow) {
      popupTool.toUp();
      return;
    }
    var position = cursorState.cursorPosition;
    if (position == null || !position.isValid) {
      return;
    }
    var block = position.block!;
    if (block.toUp()) {
      return;
    }
    layoutPreviousBlock(block);
    var textPosition = position.textPosition!;
    var lineBoundary = block.getLineBoundary(textPosition);
    if (lineBoundary == null) {
      return;
    }

    if (lineBoundary.start == 0 || lineBoundary.start == -1) {
      //上一个block
      if (block.top == 0) {
        return;
      }
      var blockIndex = blockManager.indexOfBlock(block.top);
      if (blockIndex == -1 || blockIndex == 0) {
        return;
      }
      var upBlock = blockManager.blocks[blockIndex - 1];
      var upBlockPosition = upBlock.getPositionForOffset(
          Offset(cursorRecord.recordWindowX, upBlock.height));
      if (upBlockPosition == null) {
        return;
      }
      var upBlockCursorRect = upBlock.getCursorRect(upBlockPosition);
      toPosition(
          CursorPosition(
            block: upBlock,
            textPosition: upBlockPosition,
            rect: upBlockCursorRect,
          ),
          false);
    } else {
      //上一行
      int pos = lineBoundary.start - 1;
      var y = block.getCursorRect(TextPosition(offset: pos))?.center.dy;
      if (y == null) {
        return;
      }
      var upTextPosition =
          block.getPositionForOffset(Offset(cursorRecord.recordWindowX, y))!;
      var upRect = block.getCursorRect(upTextPosition);
      toPosition(
          CursorPosition(
            block: block,
            textPosition: upTextPosition,
            rect: upRect,
          ),
          false);
    }
  }

  /// 光标下移
  void toDown() {
    if (popupTool.isShow) {
      popupTool.toDown();
      return;
    }
    var position = cursorState.cursorPosition;
    if (position == null || !position.isValid) {
      return;
    }
    var block = position.block!;
    if (block.toDown()) {
      return;
    }
    layoutNextBlock(block);
    var textPosition = position.textPosition!;
    var lineBoundary = block.getLineBoundary(textPosition);
    if (lineBoundary == null) {
      return;
    }
    if (lineBoundary.end == -1 ||
        lineBoundary.end == block.endPosition.offset) {
      //下一个 block
      int curIndex = blockManager.indexOfBlockByBlock(block);
      if (curIndex + 1 >= blockManager.blocks.length) {
        return;
      }
      var nextBlock = blockManager.blocks[curIndex + 1];
      var nextBlockPosition =
          nextBlock.getPositionForOffset(Offset(cursorRecord.recordWindowX, 0));
      if (nextBlockPosition == null) {
        return;
      }
      var nextBlockRect = nextBlock.getCursorRect(nextBlockPosition);
      toPosition(
          CursorPosition(
            block: nextBlock,
            textPosition: nextBlockPosition,
            rect: nextBlockRect,
          ),
          false);
    } else {
      //下一行
      int pos = lineBoundary.end + 1;
      var y = block.getCursorRect(TextPosition(offset: pos))?.center.dy;
      if (y == null) {
        return;
      }
      var nextTextPosition =
          block.getPositionForOffset(Offset(cursorRecord.recordWindowX, y));
      if (nextTextPosition == null) {
        return;
      }
      var nextRect = block.getCursorRect(nextTextPosition);
      toPosition(
          CursorPosition(
            block: block,
            textPosition: nextTextPosition,
            rect: nextRect,
          ),
          false);
    }
  }

  /// 下一页
  void toPageDown() {
    layoutNext(visionHeight);
    scrollVertical(visionHeight);
    SchedulerBinding.instance.scheduleFrameCallback((timeStamp) {
      toPosition(
        getCursorPosition(
            Offset(cursorRecord.recordWindowX, cursorRecord.recordWindowY)),
        false,
        scrollToShowCursor: true,
      );
    });
  }

  /// 滚动到上一页
  void toPageUp() {
    layoutPrevious(visionHeight);
    scrollVertical(-visionHeight);
    SchedulerBinding.instance.scheduleFrameCallback((timeStamp) {
      toPosition(
        getCursorPosition(
            Offset(cursorRecord.recordWindowX, cursorRecord.recordWindowY)),
        false,
        scrollToShowCursor: true,
      );
    });
  }

  ///全选
  void selectAll() {
    var cursorBlock = cursorState.cursorPosition?.block;
    if (cursorBlock != null) {
      if (cursorBlock.canSelectAll) {
        if (!cursorBlock.selectAll()) {
          recordSelectStart(cursorBlock.startCursorPosition);
          recordSelectEnd(cursorBlock.endCursorPosition);
          updateWidgetState();
        }
        return;
      }
    }
    var blocks = blockManager.blocks;
    if (blocks.isEmpty) return;

    var first = blocks.first;
    var end = blocks.last;
    layoutBlock(blocks.first, blocks.length - 10, blocks.length - 1);
    recordSelectStart(CursorPosition(
        block: first,
        textPosition: const TextPosition(offset: 0),
        rect: first.getCursorRect(const TextPosition(offset: 0))));
    end.layout(viewContext, Size(blockMaxWidth, visionHeight));
    var pos = end
        .getPositionForOffset(const Offset(double.infinity, double.infinity))!;

    recordSelectEnd(CursorPosition(
        block: end, textPosition: pos, rect: end.getCursorRect(pos)));
    updateWidgetState();
  }

  ///滚动到光标位置
  ///什么时候需要滚动到光标位置？
  ///拖动时候，更新光标位置时候
  void scrollToCursorPosition() {
    SchedulerBinding.instance.scheduleFrameCallback((timeStamp) {
      scrollToCursorPositionVertical();
      scrollToCursorPositionHorizontal();
      showPopupTool();
    });
  }

  void scrollToCursorPositionVertical() {
    //垂直滚动到光标位置：如果子组件可以滚动，则需要混合滚动(思维导图之类自定义组件可能需要，目前不需要垂直混合滚动)
    var position = cursorState.cursorPosition;
    if (position == null) {
      return;
    }
    var block = position.block;
    var cursorRect = getCursorRect(position);
    if (block == null || cursorRect == null) {
      return;
    }
    if (cursorRect.height > visionHeight - 40) {
      var heightDis = cursorRect.height - visionHeight + 40;
      cursorRect = Rect.fromLTWH(cursorRect.left, cursorRect.top + heightDis,
          cursorRect.width, visionHeight - heightDis);
    }

    var cursorStartY = cursorRect.top + padding.top;
    var cursorEndY = cursorRect.bottom + padding.top;
    var viewStartY = scrollOffset + 10;
    var viewEndY = scrollOffset + visionHeight - 10;
    if (cursorStartY < viewStartY) {
      scrollVertical(cursorStartY - viewStartY);
    }
    if (cursorEndY > viewEndY) {
      scrollVertical(cursorEndY - viewEndY);
    }
  }

  void scrollToCursorPositionHorizontal() {
    //水平滚动必然只有子组件有，所以如果cursor所在block有水平滚动情况才需要计算
    var position = cursorState.cursorPosition;
    if (position == null) {
      return;
    }
    var block = position.block;
    if (block == null) {
      return;
    }
    //如果光标位置小于paddingLeft，需要调节
    block.scrollToCursorPosition(position);
  }

  void scrollHorizontal(double deltaX) {
    //水平滚动必然只有子组件有，所以如果cursor所在block有水平滚动情况才需要计算
    var position = cursorState.cursorPosition;
    if (position == null) {
      return;
    }
    var block = position.block;
    if (block == null) {
      return;
    }
    //如果光标位置小于paddingLeft，需要调节
    block.scrollHorizontal(deltaX);
  }

  ///对指定的index的block进行布局，并且在布局后改变的大小进行锚block定位
  void layoutBlock(WenBlock anchorBlock, int startBlockIndex, int endBlockIndex,
      {bool jump = false}) {
    try {
      startBlockIndex = blockManager.getValidIndex(startBlockIndex);
      endBlockIndex = blockManager.getValidIndex(endBlockIndex);
      var anchor = scrollOffset - anchorBlock.top;
      blockManager.layoutBlockRange(viewContext, startBlockIndex, endBlockIndex,
          Size(blockMaxWidth, visionHeight));
      var newScrollOffset = anchor + anchorBlock.top;
      if (jump) {
        scrollController?.jumpTo(newScrollOffset);
      }
    } catch (e) {}
  }

  ///布局当前block
  void layoutCurrentBlock(WenBlock anchorBlock, {bool jump = false}) {
    int startBlockIndex = blockManager.indexOfBlockByBlock(anchorBlock);
    var anchor = scrollOffset - anchorBlock.top;
    blockManager.layoutBlockRange(viewContext, startBlockIndex, startBlockIndex,
        Size(blockMaxWidth, visionHeight));
    var newScrollOffset = anchor + anchorBlock.top;
    try {
      if (jump == true) {
        scrollController?.jumpTo(newScrollOffset);
      }
    } catch (e) {}
  }

  ///布局前10个block
  void layoutPreviousBlock(WenBlock anchorBlock) {
    int index = blockManager.indexOfBlockByBlock(anchorBlock);
    if (index == -1) {
      return;
    }
    int pre = index - 10;
    if (pre < 0) {
      pre = 0;
    }
    layoutBlock(anchorBlock, pre, index);
  }

  ///布局后10个block
  void layoutNextBlock(WenBlock anchorBlock) {
    int index = blockManager.indexOfBlockByBlock(anchorBlock);
    if (index == -1) {
      return;
    }
    int next = index + 10;
    if (next >= blockManager.blocks.length) {
      next = blockManager.blocks.length - 1;
    }
    layoutBlock(anchorBlock, index, next);
  }

  ///根据高度布局前面n个block
  void layoutPrevious(double height) {
    var anchorIndex = getWindowFirstBlockIndex();
    if (anchorIndex == -1) {
      return;
    }
    var anchor = blockManager.blocks[anchorIndex];
    int index = anchorIndex - 1;
    while (index >= 0) {
      int end = index - 10;
      if (end < 0) {
        end = 0;
      }
      layoutBlock(anchor, end, index);
      if ((blockManager.blocks[end].top - anchor.top).abs() > height) {
        break;
      }
      index = end - 1;
    }
  }

  ///根据高度布局后n个block
  void layoutNext(double height) {
    var anchorIndex = getWindowFirstBlockIndex();
    if (anchorIndex == -1) {
      return;
    }
    var anchor = blockManager.blocks[anchorIndex];
    int index = anchorIndex + 1;
    while (index <= blockManager.blocks.length - 1) {
      int end = index + 10;
      if (end > blockManager.blocks.length - 1) {
        end = blockManager.blocks.length - 1;
      }
      layoutBlock(anchor, index, end);
      if ((blockManager.blocks[end].top - anchor.top).abs() > height) {
        break;
      }
      index = end + 1;
    }
  }

  void relayoutVision() {
    layoutNext(visionHeight * 2);
  }

  ///获取窗口第一个显示的block索引
  int getWindowFirstBlockIndex() {
    return blockManager.indexOfBlock(scrollOffset);
  }

  ///获取窗口最后一个显示的block索引
  int getWindowEndBlockIndex() {
    return blockManager.indexOfBlock(scrollOffset + visionHeight);
  }

  int get currentStartBlockIndex {
    var selectStartBlock = selectState.realStart?.block;
    if (selectStartBlock != null) {
      return blockManager.indexOfBlockByBlock(selectStartBlock);
    }
    var cursorBlock = cursorState.cursorPosition?.block;
    if (cursorBlock != null) {
      return blockManager.indexOfBlockByBlock(cursorBlock);
    }
    return -1;
  }

  int get currentEndBlockIndex {
    var selectStartBlock = selectState.realEnd?.block;
    if (selectStartBlock != null) {
      return blockManager.indexOfBlockByBlock(selectStartBlock);
    }
    var cursorBlock = cursorState.cursorPosition?.block;
    if (cursorBlock != null) {
      return blockManager.indexOfBlockByBlock(cursorBlock);
    }
    return -1;
  }

  void showCursorOnOpen() {
    if (cursorState.cursorPosition == null) {
      if (blockManager.blocks.isNotEmpty) {
        layoutCurrentBlock(blockManager.blocks.first);
        toPosition(blockManager.blocks.first.startCursorPosition, false);
      }
    } else {
      refreshCursorPosition();
    }
  }

  void scrollToBlock(WenBlock block) {
    scrollVertical(block.top - scrollOffset);
  }

  String getSelectText() {
    var ret = "";
    if (selectState.hasSelect) {
      var start = selectState.realStart;
      var end = selectState.realEnd;
      if (start!.block! == end!.block) {
        WenElement element =
            start.block!.copyElement(start.textPosition!, end.textPosition!);
        return element.getText();
      } else {
        String text = "";
        var startSub = start.block!
            .copyElement(start.textPosition!, start.block!.endPosition);
        text += startSub.getText();
        int startIndex = blockManager.indexOfBlockByBlock(start.block!);
        int endIndex = blockManager.indexOfBlockByBlock(end.block!);
        for (int i = startIndex + 1; i < endIndex; i++) {
          text += "\n" + blockManager.blocks[i].element.getText();
        }
        var endSub =
            end.block!.copyElement(end.block!.startPosition, end.textPosition!);
        text += "\n" + endSub.getText();
        return text;
      }
    }
    return ret;
  }

  void showDropContextMenu(BuildContext content, Offset position) async {
    rightMenuShowing = true;
    updateWidgetState();
    var box = viewContext.findRenderObject() as RenderBox;
    await showMouseDropMenu(
        viewContext, box.localToGlobal(position) & Size(1, 1),
        childrenWidth: 260,
        childrenHeight: 30,
        margin: 4,
        menus: [
          DropMenu(
            enable: selectState.hasSelect,
            text: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
              ),
              child: Text(
                "复制",
                style: selectState.hasSelect
                    ? null
                    : TextStyle(
                        color: editTheme.fontColor.withOpacity(0.2),
                      ),
              ),
            ),
            onPress: (ctx) {
              if (selectState.hasSelect) {
                copy();
                hideDropMenu(ctx);
              }
            },
          ),
          DropMenu(
            text: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
              ),
              child: Text(
                "剪切",
                style: selectState.hasSelect
                    ? null
                    : TextStyle(
                        color: editTheme.fontColor.withOpacity(0.2),
                      ),
              ),
            ),
            onPress: (ctx) {
              if (selectState.hasSelect) {
                cut();
                hideDropMenu(ctx);
              }
            },
          ),
          //粘贴
          DropMenu(
              text: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                child: Text("粘贴"),
              ),
              childrenWidth: 200,
              onPress: (ctx) {
                paste();
                hideDropMenu(ctx);
              },
              children: [
                DropMenu(
                  text: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                    ),
                    child: Text("粘贴纯文本"),
                  ),
                  onPress: (ctx) {
                    paste(pasteText: true);
                    hideDropMenu(ctx);
                  },
                ),
                DropMenu(
                  text: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                    ),
                    child: Text("粘贴富文本"),
                  ),
                  onPress: (ctx) {
                    paste();
                    hideDropMenu(ctx);
                  },
                ),
                DropMenu(
                  text: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                    ),
                    child: Text("粘贴 Markdown"),
                  ),
                  onPress: (ctx) {
                    paste(
                      pasteMarkdown: true,
                    );
                    hideDropMenu(ctx);
                  },
                ),
                DropMenu(
                  text: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                    ),
                    child: Text("粘贴 HTML"),
                  ),
                  onPress: (ctx) {
                    paste(
                      pasteHtml: true,
                    );
                    hideDropMenu(ctx);
                  },
                ),
              ]),
          //表格
          if (isCurrentTable)
            DropMenu(
                text: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                  ),
                  child: Text(
                    "表格",
                    style: null,
                  ),
                ),
                children: [
                  DropMenu(
                    text: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                      ),
                      child: Text(
                        "上方添加行",
                        style: null,
                      ),
                    ),
                    onPress: (ctx) {
                      addTableRowOnPrevious();
                      hideDropMenu(ctx);
                    },
                  ),
                  DropMenu(
                    text: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                      ),
                      child: Text(
                        "下方添加行",
                        style: null,
                      ),
                    ),
                    onPress: (ctx) {
                      addTableRowOnNext();
                      hideDropMenu(ctx);
                    },
                  ),
                  DropSplit(),
                  DropMenu(
                    text: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                      ),
                      child: Text(
                        "左侧添加列",
                        style: null,
                      ),
                    ),
                    onPress: (ctx) {
                      addTableColOnPrevious();
                      hideDropMenu(ctx);
                    },
                  ),
                  DropMenu(
                    text: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                      ),
                      child: Text(
                        "右侧添加列",
                        style: null,
                      ),
                    ),
                    onPress: (ctx) {
                      addTableColOnNext();
                      hideDropMenu(ctx);
                    },
                  ),
                  DropSplit(),
                  DropMenu(
                    text: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                      ),
                      child: Text(
                        "删除行",
                        style: null,
                      ),
                    ),
                    onPress: (ctx) {
                      deleteTableRow();
                      hideDropMenu(ctx);
                    },
                  ),
                  DropMenu(
                    text: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                      ),
                      child: Text(
                        "删除列",
                        style: null,
                      ),
                    ),
                    onPress: (ctx) {
                      deleteTableCol();
                      hideDropMenu(ctx);
                    },
                  ),
                  DropSplit(),
                  DropMenu(
                    text: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                      ),
                      child: Text(
                        "删除表格",
                        style: null,
                      ),
                    ),
                    onPress: (ctx) {
                      deleteTable();
                      hideDropMenu(ctx);
                    },
                  ),
                ]),
          DropSplit(),
          DropMenu(
            enable: canUndo,
            text: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
              ),
              child: Text(
                "撤销",
                style: canUndo
                    ? null
                    : TextStyle(color: editTheme.fontColor.withOpacity(0.2)),
              ),
            ),
            description: Text(
              "Ctrl + Z",
              style: canUndo
                  ? null
                  : TextStyle(color: editTheme.fontColor.withOpacity(0.2)),
            ),
            onPress: (ctx) {
              if (canUndo) {
                undo();
                hideDropMenu(ctx);
              }
            },
          ),
          DropMenu(
            enable: canRedo,
            text: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
              ),
              child: Text(
                "重做",
                style: canRedo
                    ? null
                    : TextStyle(color: editTheme.fontColor.withOpacity(0.2)),
              ),
            ),
            description: Text(
              "Ctrl + Y",
              style: canRedo
                  ? null
                  : TextStyle(color: editTheme.fontColor.withOpacity(0.5)),
            ),
            onPress: (ctx) {
              if (canRedo) {
                redo();
                hideDropMenu(ctx);
              }
            },
          ),
          DropSplit(),
          DropMenu(
            text: const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 8,
              ),
              child: Text("上方添加段"),
            ),
            description: const Text("Ctrl + Shift + Enter"),
            onPress: (ctx) {
              addTextBlockBefore();
              hideDropMenu(ctx);
            },
          ),
          DropMenu(
            text: const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 8,
              ),
              child: Text("下方添加段"),
            ),
            description: const Text("Ctrl + Enter"),
            onPress: (ctx) {
              addTextBlock();
              hideDropMenu(ctx);
            },
          ),
        ]);
    rightMenuShowing = false;
    requestFocus();
    updateWidgetState();
  }

  void showContextMenu(Offset localPosition) async {
    showDropContextMenu(viewContext, localPosition);
  }

  void onDragIn(DropOverEvent event) {
    var offset = event.position.local;
    offset = offset.translate(-padding.left, -padding.top);
    var cursorPosition = getCursorPosition(offset);
    toPosition(cursorPosition, true);
  }

  String? getBlockType(int blockIndex) {
    if (blockIndex < 0 || blockIndex >= blockManager.blocks.length) {
      return null;
    }
    return blockManager.blocks[blockIndex].element.type;
  }

  void showAddTableDialog() async {
    var ok = false;
    var rowController = fluent.TextEditingController(text: "4");
    var colController = fluent.TextEditingController(text: "3");
    await showMobileDialog(
        context: viewContext,
        builder: (context) {
          return fluent.ContentDialog(
            constraints: isMobile
                ? const BoxConstraints(maxWidth: 300)
                : fluent.kDefaultContentDialogConstraints,
            title: const Text("插入表格"),
            content: fluent.Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text(" 列 "),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10, top: 10),
                        child: fluent.TextBox(
                          placeholder: "请输入列",
                          keyboardType: fluent.TextInputType.number,
                          inputFormatters: [
                            // 完善的计数输入替代方案
                            CounterTextInputFormatter(min: 1, max: 200),
                          ],
                          controller: colController,
                          autofocus: true,
                          onSubmitted: (e) {
                            ok = true;
                            Navigator.pop(context, '确定');
                          },
                        ),
                      ),
                    ),
                    const Text(" 行 "),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10, top: 10),
                        child: fluent.TextBox(
                          placeholder: "请输入行",
                          controller: rowController,
                          autofocus: true,
                          keyboardType: fluent.TextInputType.number,
                          inputFormatters: [
                            // 完善的计数输入替代方案
                            CounterTextInputFormatter(min: 1, max: 1000),
                          ],
                          onSubmitted: (e) {
                            ok = true;
                            Navigator.pop(context, '确定');
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              fluent.Button(
                child: const Text('取消'),
                onPressed: () {
                  Navigator.pop(context, '取消');
                  // Delete file here
                },
              ),
              fluent.FilledButton(
                  onPressed: () {
                    ok = true;
                    Navigator.pop(context, '确定');
                  },
                  child: const Text("确定")),
            ],
          );
        });
    if (ok) {
      var colCount = int.parse(colController.text);
      var rowCount = int.parse(rowController.text);
      if (colCount > 0 && rowCount > 0) {
        addTable(rowCount, colCount);
      }
    }
  }

  void undo() {
    blockManager.undo(this);
  }

  void redo() {
    blockManager.redo(this);
  }

  bool get canUndo {
    return blockManager.canUndo;
  }

  bool get canRedo {
    return blockManager.canRedo;
  }

  get isCurrentTable => cursorState.cursorPosition?.block is TableBlock;

  double abs(double value) {
    if (value < 0) {
      return -value;
    }
    return value;
  }

  void record() {
    blockManager.record(this);
    notifyListeners();
  }

  ///对popupWidget的left坐标偏移量处理
  ///可以用于视图居中x计算处理
  static List<PopupPositionWidget> translatePopupPositionWidget(
      List<PopupPositionWidget> floatWidgets, double offsetX, double offsetY) {
    List<PopupPositionWidget> popupWidgets = [];
    for (var floatWidget in floatWidgets) {
      var left = floatWidget.left;
      var right = floatWidget.right;
      var top = floatWidget.top;
      var bottom = floatWidget.bottom;
      var anchorRect = floatWidget.anchorRect;
      if (left != null || right != null || anchorRect != null) {
        if (left != null) {
          left += offsetX;
        }
        if (right != null) {
          right += offsetX;
        }
        if (top != null) {
          top += offsetY;
        }
        if (bottom != null) {
          bottom += offsetY;
        }
        if (anchorRect != null) {
          anchorRect = anchorRect.translate(offsetX, offsetY);
        }
        floatWidget = PopupPositionWidget(
            key: floatWidget.key,
            layerIndex: floatWidget.layerIndex,
            left: left,
            right: right,
            top: top,
            bottom: bottom,
            width: floatWidget.width,
            height: floatWidget.height,
            anchorRect: anchorRect,
            keepVision: floatWidget.keepVision,
            popupAlignment: floatWidget.popupAlignment,
            overflowAlignment: floatWidget.overflowAlignment,
            child: floatWidget.child);
      }
      popupWidgets.add(floatWidget);
    }
    return popupWidgets;
  }

  /// 滚动
  void scrollVertical(double dy) {
    int index = blockManager.indexOfBlock(dy + scrollOffset);
    if (index == -1) {
      if (blockManager.blocks.isEmpty) {
        return;
      }
      blockManager.layoutNextBlockWithHeight(
          viewContext, Size(visionWidth, visionHeight), 0, visionHeight);
      blockManager.layoutPreviousBlockWithHeight(
          viewContext,
          Size(visionWidth, visionHeight),
          blockManager.blocks.length - 1,
          visionHeight);
    } else {
      blockManager.layoutNextBlockWithHeight(
          viewContext, Size(visionWidth, visionHeight), index, visionHeight);
      blockManager.layoutPreviousBlockWithHeight(
          viewContext, Size(visionWidth, visionHeight), index, visionHeight);
    }
    var contentHeight = getContentHeight();
    double maxExtend = max(0, contentHeight - visionHeight);
    try {
      if (maxExtend > 0) {
        // scrollController?.position.applyContentDimensions(0, maxExtend);
      }
    } catch (e) {
      print(e);
    }
    double jumpToY = scrollOffset + dy;
    if (maxExtend > 0) {
      if (jumpToY < 0) {
        scrollController?.jumpTo(0);
      } else if (jumpToY > maxExtend) {
        scrollController?.jumpTo(maxExtend);
      } else {
        scrollController?.jumpTo(jumpToY);
      }
    }
  }

  double getContentHeight() {
    return padding.vertical + blockManager.height;
  }

  void setAlignment(String? alignment) {
    // 左对齐
    visitSelectBlock((block) {
      if (block is TableBlock) {
        block.setAlignment(alignment);
        return;
      }
      block.element.alignment = alignment;
      block.relayoutFlag = true;
    });
    updateWidgetState();
    refreshCursorPosition();
    record();
  }

  void onInputAction(TextInputAction action) {
    if (action == TextInputAction.newline) {
      if (Platform.isAndroid || Platform.isIOS) {
        enter();
        record();
        WidgetsBinding.instance.scheduleFrameCallback((timeStamp) {
          refreshCursorPosition();
        });
      }
    }
  }

  void cut() {
    copy();
    if (selectState.hasSelect) {
      delete(false);
    }
    record();
  }

  /// 粘贴
  /// 难点：html富文本支持 解决方案：支持标题、正文、图片、代码、表格解析，其他特殊格式通过自有id熟悉解析
  /// 难点：html多层属性转换为2层属性
  /// 文档：https://pub.dev/packages/super_clipboard
  /// super_drag_and_drop
  Future<void> paste({
    bool pasteText = false,
    bool pasteHtml = false,
    bool pasteMarkdown = false,
  }) async {
    var data = await RichClipboard.getData();
    var text = data.text;
    var html = data.html;
    Uint8List? image;
    if (!isMobile) {
      image = await Pasteboard.image;
    }
    if (pasteText) {
      insertContent(null, text);
      record();
      return;
    }
    if (pasteMarkdown) {
      var elements = await parseMarkdown(fileManager, text ?? "");
      var blocks =
          elements.map((e) => createWenBlock(viewContext, this, e)).toList();
      insertContent(blocks, null);
      record();
      return;
    }

    html = pasteHtml ? text : html;
    if (html != null) {
      List<WenBlock>? blocks = await showMobileDialog(
          context: viewContext,
          builder: (ctx) => FutureProgressDialog(
                parseHtmlBlock(
                  this,
                  copyService,
                  viewContext,
                  html!,
                ),
              ));
      if (blocks != null) {
        insertContent(blocks, text);
        record();
        requestFocus();
      }
    } else if (text != null) {
      insertContent(null, text);
      record();
    } else if (image != null) {
      var fileId = await showMobileDialog(
          context: viewContext,
          builder: (context) => FutureProgressDialog(
                fileManager.writeImage(image!),
              ));
      if (fileId != null) {
        var filepath = await fileManager.getImageFile(fileId.uuid);
        if (filepath == null) {
          return;
        }
        var size = await readImageFileSize(filepath);
        insertContent([
          ImageBlock(
              editController: this,
              context: viewContext,
              element: WenImageElement(
                id: fileId.uuid,
                file: filepath,
                width: size.width,
                height: size.height,
              ))
        ], text);
        record();
      }
    }
    print('text length:${blockManager.textLength}');
  }

  /// 粘贴图片
  Future<void> pasteImage(
    Uint8List image, {
    bool isFile = false,
    String suffix = ".png",
  }) async {
    var isImage = isValidImage(image_size.MemoryInput(image));
    if (!isImage) {
      return;
    }
    var fileItem = await fileManager.writeImage(
      image,
      isFile: isFile,
      suffix: suffix,
    );
    if (fileItem == null) {
      return;
    }
    var imageFile = await fileManager.getImageFile(fileItem.uuid);
    if (imageFile == null) {
      return;
    }
    var size = await readImageFileSize(imageFile);
    insertContent([
      ImageBlock(
          editController: this,
          context: viewContext,
          element: WenImageElement(
            id: fileItem.uuid!,
            file: imageFile,
            width: size.width,
            height: size.height,
          ))
    ], null);
    record();
  }

  Future<void> pasteImageFile(String path) async {
    var isImage = isValidImage(FileInput(File(path)));
    if (!isImage) {
      // return;
    }
    var fileItem = await fileManager.writeImageFile(path);
    if (fileItem == null) {
      return;
    }
    var imageFile = await fileManager.getImageFile(fileItem.uuid);
    if (imageFile == null) {
      return;
    }
    var size = await readImageFileSize(imageFile);
    insertContent([
      ImageBlock(
          editController: this,
          context: viewContext,
          element: WenImageElement(
            id: fileItem.uuid!,
            file: imageFile,
            width: size.width,
            height: size.height,
          ))
    ], null);
    record();
  }

  /// 缩进
  void addIndent() {
    if (currentStartBlockIndex != -1 &&
        currentStartBlockIndex == currentEndBlockIndex) {
      var block = blockManager.blocks[currentStartBlockIndex];
      if (block is CodeBlock) {
        block.addIndent();
        return;
      }
      if (block is TableBlock) {
        block.nextTable();
        return;
      }
    }
    var startIndex = cursorState.cursorPosition?.blockIndex;
    var endIndex = startIndex;
    if (selectState.hasSelect) {
      startIndex = selectState.realStart?.blockIndex;
      endIndex = selectState.realEnd?.blockIndex;
    }
    if (startIndex != null && endIndex != null) {
      for (var i = startIndex; i <= endIndex; i++) {
        var indent = blockManager.blocks[i].element.indent;
        indent ??= 0;
        indent++;
        if (indent > 6) {
          indent = 6;
        }
        blockManager.blocks[i].element.indent = indent;
        blockManager.blocks[i].relayoutFlag = true;
      }
      blockManager.layoutBlockRange(
          viewContext, startIndex, endIndex, Size(visionWidth, visionHeight));
      refreshCursorPosition();
    }
  }

  /// 缩退
  void removeIndent() {
    if (currentStartBlockIndex != -1 &&
        currentStartBlockIndex == currentEndBlockIndex) {
      var block = blockManager.blocks[currentStartBlockIndex];
      if (block is CodeBlock) {
        block.removeIndent();
        return;
      }
    }
    var startIndex = cursorState.cursorPosition?.blockIndex;
    var endIndex = startIndex;
    if (selectState.hasSelect) {
      startIndex = selectState.realStart?.blockIndex;
      endIndex = selectState.realEnd?.blockIndex;
    }
    if (startIndex != null && endIndex != null) {
      for (var i = startIndex; i <= endIndex; i++) {
        var indent = blockManager.blocks[i].element.indent;
        indent ??= 0;
        indent--;
        if (indent < 0) {
          indent = 0;
        }
        blockManager.blocks[i].relayoutFlag = true;
        blockManager.blocks[i].element.indent = indent;
      }
      blockManager.layoutBlockRange(
          viewContext, startIndex, endIndex, Size(visionWidth, visionHeight));
      refreshCursorPosition();
    }
  }

  ///回车
  void enter() {
    if (replaceWithCodeCheck()) {
      return;
    }
    if (popupTool.isShow) {
      popupTool.enter();
      return;
    }
    bool hasSelect = selectState.hasSelect;
    if (hasSelect) {
      deleteSelectRange();
    }
    var cursor = cursorState.cursorPosition;
    if (cursor == null) {
      return;
    }
    var cursorBlock = cursor.block;
    if (cursorBlock == null) {
      return;
    }
    var cursorTextPosition = cursor.textPosition;
    if (cursorTextPosition == null) {
      return;
    }
    if (cursorBlock.catchEnter) {
      onInputText(const TextEditingValue(text: "\n"));
      return;
    }
    var blockIndex = blockManager.indexOfBlockByBlock(cursorBlock);
    //0.如果没有选择，当前block内容为空，则清除block样式
    if (!hasSelect && blockManager.blocks[blockIndex].isEmpty) {
      var oldBlock = blockManager.blocks[blockIndex];
      var clearStyle = true;
      var oldElement = oldBlock.element;
      if (oldElement is WenTextElement) {
        if (oldElement.itemType == "text" || oldElement.itemType == null) {
          clearStyle = false;
        }
        if (oldElement.type == "quote" &&
            getBlockType(blockIndex + 1) != "quote") {
          clearStyle = true;
        }
      }
      if (clearStyle) {
        String newType = "text";
        if (getBlockType(blockIndex) == "quote" &&
            getBlockType(blockIndex + 1) == "quote") {
          newType = "quote";
        }
        blockManager.blocks[blockIndex] = TextBlock(
            editController: this,
            context: viewContext,
            textElement: WenTextElement(type: newType))
          ..top = oldBlock.top;
        layoutBlock(blockManager.blocks[blockIndex], blockIndex, blockIndex);
        var position = blockManager.blocks[blockIndex].startCursorPosition;
        toPosition(position, true);
        return;
      }
    }
    //1.如果光标在行首，则在前面插入一行text
    //2.如果光标在行尾，则在后面插入一行text
    //3.如果光标在中间，则分割block
    if (cursorTextPosition.offset == cursorBlock.endPosition.offset) {
      String? itemType;
      int? indent = cursorBlock.element.indent;
      String type = "text";
      if (getBlockType(blockIndex) == "quote" &&
          getBlockType(blockIndex + 1) == "quote") {
        type = "quote";
      } else if (cursorBlock is TextBlock) {
        if (!cursorBlock.isEmpty) {
          itemType = cursorBlock.textElement.itemType;
          type = cursorBlock.element.type;
        }
      }
      var textBlock = TextBlock(
          editController: this,
          context: viewContext,
          textElement: WenTextElement(
            type: type,
            itemType: itemType,
            indent: indent,
          ));
      blockManager.blocks.insert(
        blockIndex + 1,
        textBlock,
      );
      layoutBlock(cursorBlock, blockIndex, blockIndex + 1);
    } else if (cursorTextPosition == cursorBlock.startPosition) {
      String type = "text";
      if (cursorBlock is TextBlock) {
        type = cursorBlock.textElement.type;
      }
      var textBlock = TextBlock(
          editController: this,
          context: viewContext,
          textElement: WenTextElement(
            text: "",
            type: type,
          ));
      textBlock.top = cursorBlock.top;
      blockManager.blocks.insert(
        blockIndex,
        textBlock,
      );
      layoutBlock(textBlock, blockIndex, blockIndex + 1);
    } else {
      var textBlock = cursorBlock.splitBlock(cursorTextPosition);
      blockManager.blocks.insert(
        blockIndex + 1,
        textBlock,
      );
      layoutBlock(cursorBlock, blockIndex, blockIndex + 1);
    }
    var position = blockManager.blocks[blockIndex + 1].startCursorPosition;
    toPosition(position, true);
    refreshCursorPosition();
  }

  ///删除
  void delete(bool backspace) {
    if (selectState.hasSelectRange) {
      deleteSelectRange();
    } else {
      deleteCursor(backspace);
    }
    refreshCursorPosition();
    scrollToCursorPosition();
    updateWidgetState();
    showPopupTool();
  }

  ///输入拼音
  void onInputComposing(TextEditingValue composing) {
    deleteSelectRange();
    deleteComposing();
    var block = cursorState.cursorPosition?.block;
    block?.inputText(this, composing, isComposing: true);
    inputManager.composing = composing;
    selectState.clearSelect();
    updateInputMethodWindowPosition();
  }

  ///删除拼音
  void deleteComposing() {
    var composingLength = inputManager.composing?.text.length ?? 0;
    if (composingLength > 0) {
      var offset = cursorState.cursorPosition?.textPosition?.offset ?? 0;
      if (offset >= composingLength) {
        var block = cursorState.cursorPosition?.block;
        if (block != null) {
          block.deleteRange(TextPosition(offset: offset - composingLength),
              TextPosition(offset: offset));
          layoutCurrentBlock(block);
          updateCursor(
            block.getCursorPosition(
                TextPosition(offset: offset - composingLength)),
            applyUpdate: false,
          );
        }
      }
      inputManager.composing = null;
    }
  }

  ///输入法输入文字
  void onInputText(TextEditingValue text) {
    deleteComposing();
    deleteSelectRange();
    var block = cursorState.cursorPosition?.block;
    block?.inputText(this, text);
    record();
    showPopupTool(true);
    replaceWithTitleCheck();
    replaceWithLiCheck();
    replaceWithQuoteCheck();
  }

  void replaceWithTitleCheck() {
    var cursor = cursorState.cursorPosition;
    if (cursor == null) {
      return;
    }
    var block = cursor.block;
    if (block is! TextBlock) {
      return;
    }
    var cursorPos = cursor.textPosition?.offset;
    if (cursorPos == null) {
      return;
    }
    var text = block.textElement.getText();
    int level = 0;
    int levelIndex = -1;
    for (var i = 0; i < text.length; i++) {
      if (text[i] == "#") {
        level++;
      } else if (text[i] == " ") {
        levelIndex = i;
        break;
      } else {
        return;
      }
    }
    if (level == 0 || levelIndex == -1) {
      return;
    }
    if (levelIndex + 1 != cursorPos) {
      return;
    }
    setSelection(
        block.getCursorPosition(TextPosition(offset: 0))
          ..blockIndex = cursor.blockIndex,
        block.getCursorPosition(TextPosition(offset: levelIndex + 1))
          ..blockIndex = cursor.blockIndex);
    deleteSelectRange();
    changeTextLevel(level);
  }

  void replaceWithLiCheck() {
    var cursor = cursorState.cursorPosition;
    if (cursor == null) {
      return;
    }
    var block = cursor.block;
    if (block is! TextBlock) {
      return;
    }
    var cursorPos = cursor.textPosition?.offset;
    if (cursorPos == null) {
      return;
    }
    var text = block.textElement.getText();
    if (text.length < 2) {
      return;
    }
    if (cursorPos != 2) {
      return;
    }
    if (text[0] != "-") {
      return;
    }
    if (text[1] != " ") {
      return;
    }
    setSelection(
        block.getCursorPosition(TextPosition(offset: 0))
          ..blockIndex = cursor.blockIndex,
        block.getCursorPosition(TextPosition(offset: 2))
          ..blockIndex = cursor.blockIndex);
    deleteSelectRange();
    setItemType(itemType: "li");
  }

  void replaceWithQuoteCheck() {
    var cursor = cursorState.cursorPosition;
    if (cursor == null) {
      return;
    }
    var block = cursor.block;
    if (block is! TextBlock) {
      return;
    }
    var cursorPos = cursor.textPosition?.offset;
    if (cursorPos == null) {
      return;
    }
    var text = block.textElement.getText();
    if (text.length < 2) {
      return;
    }
    if (cursorPos != 2) {
      return;
    }
    if (text[0] != ">") {
      return;
    }
    if (text[1] != " ") {
      return;
    }
    setSelection(
        block.getCursorPosition(TextPosition(offset: 0))
          ..blockIndex = cursor.blockIndex,
        block.getCursorPosition(TextPosition(offset: 2))
          ..blockIndex = cursor.blockIndex);
    deleteSelectRange();
    changeTextToQuote();
  }

  bool replaceWithCodeCheck() {
    var cursor = cursorState.cursorPosition;
    if (cursor == null) {
      return false;
    }
    var block = cursor.block;
    if (block is! TextBlock) {
      return false;
    }
    var cursorPos = cursor.textPosition?.offset;
    if (cursorPos == null) {
      return false;
    }
    var text = block.textElement.getText();
    if (text.length < 3) {
      return false;
    }
    if (cursorPos != text.length) {
      return false;
    }
    if (!text.startsWith("```")) {
      return false;
    }
    for (var i = 3; i < text.length; i++) {
      if (!text[i].contains(RegExp("[a-zA-Z0-9]"))) {
        return false;
      }
    }
    var lan = text.substring(3);
    setSelection(
        block.getCursorPosition(TextPosition(offset: 0))
          ..blockIndex = cursor.blockIndex,
        block.getCursorPosition(TextPosition(offset: text.length))
          ..blockIndex = cursor.blockIndex);
    deleteSelectRange();
    toggleCode(language: lan);
    return true;
  }

  void showPopupTool([bool input = false]) {
    popupTool.show(input);
  }

  ///光标删除
  void deleteCursor(bool backspace) {
    if (!backspace) {
      var cursor = cursorState.cursorPosition;
      toRight();
      if (cursor == cursorState.cursorPosition) {
        return;
      }
    }
    var cursorPosition = cursorState.cursorPosition;
    if (cursorPosition == null) {
      return;
    }
    var textPosition = cursorPosition.textPosition;
    var block = cursorPosition.block;
    if (textPosition == null || block == null) {
      return;
    }
    int blockIndex = blockManager.indexOfBlockByBlock(block);
    if (blockIndex == -1) {
      return;
    }
    //text position==0
    if (textPosition.offset == 0) {
      if (block.isEmpty) {
        if (block.needClearStyle) {
          String type = "text";
          if (block.element.type == "quote") {
            type = "quote";
          }
          blockManager.blocks[blockIndex] = TextBlock(
              editController: this,
              context: viewContext,
              textElement: WenTextElement(
                indent: block.element.indent,
                type: type,
              ))
            ..top = block.top;
          layoutCurrentBlock(blockManager.blocks[blockIndex]);
          refreshCursorPosition();
          return;
        }
      }
      if (blockIndex == 0) {
        //text position 和 index 都为 0，无法删除,闪烁一下光标即可
        if (block.isEmpty) {
          block = TextBlock(
              editController: this,
              context: viewContext,
              textElement: WenTextElement())
            ..top = block.top;
          blockManager.blocks[blockIndex] = block;
          blockManager.layoutBlockRange(viewContext, blockIndex, blockIndex,
              Size(blockMaxWidth, visionHeight));
          toPosition(blockManager.blocks[blockIndex].startCursorPosition, true);
          updateWidgetState();
        } else {
          updateCursor(cursorPosition, applyUpdate: true);
        }
      } else {
        if (block.isEmpty) {
          //空白block，直接删除即可
          blockManager.blocks.removeRange(blockIndex, blockIndex + 1);
          blockManager.layoutBlockRange(viewContext, blockIndex - 1,
              blockIndex - 1, Size(blockMaxWidth, visionHeight));
          toPosition(
              blockManager.blocks[blockIndex - 1].endCursorPosition, true);
        } else if (blockManager.blocks[blockIndex - 1].isEmpty) {
          //前面是空白block，直接删除前面即可
          var y = blockManager.blocks[blockIndex - 1].top;
          blockManager.blocks[blockIndex].top = y;
          blockManager.blocks.removeRange(blockIndex - 1, blockIndex);
          blockManager.layoutBlockRange(viewContext, blockIndex - 1,
              blockIndex - 1, Size(blockMaxWidth, visionHeight));
          toPosition(cursorPosition, true);
        } else {
          //合并后删除对应的block
          var preBlock = blockManager.blocks[blockIndex - 1];
          var newPosition = preBlock.endPosition;
          var merge = preBlock.mergeBlock(block);
          if (merge != null) {
            preBlock = merge;
            blockManager.blocks[blockIndex - 1] = preBlock;
            blockManager.blocks.removeRange(blockIndex, blockIndex + 1);
            blockManager.layoutBlockRange(viewContext, blockIndex - 1,
                blockIndex - 1, Size(blockMaxWidth, visionHeight));
          }
          toPosition(preBlock.getCursorPosition(newPosition), true);
        }
      }
    } else {
      //text position!=0
      int deleteLength = block.deletePosition(textPosition);
      if (block.isEmpty && !block.canEmpty) {
        block = TextBlock(
            editController: this,
            context: viewContext,
            textElement: WenTextElement())
          ..top = block.top;
        blockManager.blocks[blockIndex] = block;
      }
      blockManager.layoutBlockRange(viewContext, blockIndex, blockIndex,
          Size(blockMaxWidth, visionHeight));
      var cursor = block.getCursorPosition(
          TextPosition(offset: textPosition.offset - deleteLength));
      toPosition(cursor, true);
    }
  }

  void setSelection(CursorPosition? start, CursorPosition? end) {
    selectState.start = start;
    selectState.end = end;
    onSelectChanged();
    updateWidgetState();
  }

  ///删除选择的内容
  void deleteSelectRange() {
    if (!selectState.hasSelectRange) {
      return;
    }
    var start = selectState.realStart!;
    var end = selectState.realEnd!;
    var startBlock = start.block;
    var endBlock = end.block;
    var startPosition = start.textPosition;
    var endPosition = end.textPosition;
    if (startBlock == null ||
        endBlock == null ||
        startPosition == null ||
        endPosition == null) {
      return;
    }
    var startBlockIndex = blockManager.indexOfBlockByBlock(startBlock);
    var endBlockIndex = blockManager.indexOfBlockByBlock(endBlock);
    if (startBlockIndex == -1 || endBlockIndex == -1) {
      return;
    }
    var startBlockTextType = "text";
    if (startBlock is TextBlock) {
      startBlockTextType = startBlock.element.type;
    }
    if (startBlockIndex == endBlockIndex) {
      //删除选择内容即可
      startBlock.deleteRange(startPosition, endPosition);
      if (startBlock.isEmpty && !endBlock.canEmpty) {
        startBlock = TextBlock(
            editController: this,
            textElement: WenTextElement(),
            context: viewContext)
          ..top = startBlock.top;
        blockManager.blocks[startBlockIndex] = startBlock;
      }
    } else {
      //删除左block内容
      startBlock.deleteRange(startPosition, startBlock.endPosition);
      if (startBlock.isEmpty) {
        startBlock = TextBlock(
            editController: this,
            textElement: WenTextElement(type: startBlockTextType),
            context: viewContext)
          ..top = startBlock.top;
        blockManager.blocks[startBlockIndex] = startBlock;
      }
      //删除右block选择内容
      endBlock.deleteRange(endBlock.startPosition, endPosition);
      if (endBlock.isEmpty) {
        endBlock = TextBlock(
            editController: this,
            textElement: WenTextElement(type: startBlockTextType),
            context: viewContext)
          ..top = endBlock.top;
        blockManager.blocks[endBlockIndex] = endBlock;
      }
      //合并2个block
      int removeStart = startBlockIndex + 1;
      int removeEnd = endBlockIndex - 1;
      var merge = startBlock.mergeBlock(endBlock);
      if (merge != null) {
        //删除end block
        removeEnd = endBlockIndex;
        blockManager.blocks[startBlockIndex] = merge;
      }
      //删除需要删除的整个block
      if (removeStart <= removeEnd) {
        blockManager.blocks.removeRange(removeStart, removeEnd + 1);
      }
    }
    //重新布局
    blockManager.layoutBlockRange(viewContext, startBlockIndex,
        startBlockIndex + 1, Size(blockMaxWidth, visionHeight));
    //刷新光标位置
    var cursor = blockManager.blocks[startBlockIndex]
        .getCursorPosition(start.textPosition!);
    toPosition(cursor, true);
  }

  ///在光标位置插入blocks或者文字
  void insertContent(List<WenBlock>? insertBlocks, String? insertText) {
    if (insertBlocks == null || insertBlocks.isEmpty) {
      if (insertText == null || insertText == "") {
        return;
      }
      insertBlocks = parseTextToBlock(insertText);
    }
    if (insertBlocks == null) {
      return;
    }
    deleteSelectRange();
    var cursor = cursorState.cursorPosition;
    if (cursor == null) {
      return;
    }
    var cursorBlock = cursor.block;
    if (cursorBlock == null) {
      return;
    }
    var textPosition = cursor.textPosition;
    if (textPosition == null) {
      return;
    }
    var blockIndex = blockManager.indexOfBlockByBlock(cursorBlock);
    if (cursorBlock is TextBlock) {
      WenBlock newCursorBlock = insertBlocks.last;
      TextPosition newCursorPosition = insertBlocks.last.endPosition;
      var splitBlock = cursorBlock.splitBlock(textPosition);
      if (!splitBlock.isEmpty) {
        var last = insertBlocks.removeLast();
        var merge = last.mergeBlock(splitBlock);
        if (merge != null) {
          insertBlocks.add(merge);
          newCursorBlock = merge;
        } else {
          insertBlocks.add(last);
          insertBlocks.add(splitBlock);
        }
      }
      var first = insertBlocks.removeAt(0);
      int len = cursorBlock.length;
      var merge = cursorBlock.mergeBlock(first);
      if (merge != null) {
        blockManager.blocks[blockIndex] = merge;
        cursorBlock = merge;
        if (insertBlocks.isNotEmpty) {
          blockManager.blocks.insertAll(blockIndex + 1, insertBlocks);
        } else {
          newCursorPosition =
              TextPosition(offset: newCursorPosition.offset + len);
          newCursorBlock = merge;
        }
        layoutBlock(
            cursorBlock, blockIndex, blockIndex + insertBlocks.length + 1);
        toPosition(newCursorBlock.getCursorPosition(newCursorPosition), true);
      } else {
        if (cursorBlock.isEmpty) {
          first.top = blockManager.blocks.removeAt(blockIndex).top;
          blockManager.blocks.insert(blockIndex, first);
          if (insertBlocks.isNotEmpty) {
            blockManager.blocks.insertAll(blockIndex + 1, insertBlocks);
          }
        } else {
          blockManager.blocks.insert(blockIndex + 1, first);
          if (insertBlocks.isNotEmpty) {
            blockManager.blocks.insertAll(blockIndex + 2, insertBlocks);
          }
        }
        layoutBlock(
            cursorBlock, blockIndex, blockIndex + insertBlocks.length + 1);
        if (insertBlocks.isEmpty) {
          toPosition(first.endCursorPosition, true);
        } else {
          toPosition(newCursorBlock.getCursorPosition(newCursorPosition), true);
        }
      }
    } else if (cursorBlock is ImageBlock) {
      if (cursorBlock.isEmpty) {
        blockManager.blocks.removeAt(blockIndex);
      }
      if (textPosition.offset == 0) {
        //在前面插入
        blockManager.blocks.insertAll(blockIndex, insertBlocks);
        if (blockIndex == 0) {
          layoutBlock(
              cursorBlock, blockIndex, blockIndex + insertBlocks.length + 1);
        } else {
          layoutBlock(cursorBlock, blockIndex - 1,
              blockIndex + insertBlocks.length + 1);
        }
        toPosition(insertBlocks.last.endCursorPosition, true);
      } else {
        //在后面插入
        blockManager.blocks.insertAll(blockIndex + 1, insertBlocks);
        layoutBlock(
            cursorBlock, blockIndex, blockIndex + insertBlocks.length + 1);
        toPosition(insertBlocks.last.endCursorPosition, true);
      }
    } else if (cursorBlock is TableBlock) {
      cursorBlock.insertContent(insertBlocks);
    } else {
      cursorBlock.inputText(this, TextEditingValue(text: insertText ?? ""));
    }
  }

  List<WenBlock> parseTextToBlock(String insertText) {
    var lines = insertText.replaceAll("\r", "").split("\n");
    return [
      for (var line in lines)
        TextBlock(
            editController: this,
            context: viewContext,
            textElement: WenTextElement(
              text: line,
            )),
    ];
  }

  ///改变textBlock的大纲级别
  void changeTextLevel(int level) {
    var cursor = cursorState.cursorPosition;
    if (cursor == null || cursor.block == null) {
      return;
    }
    var cursorBlockIndex = blockManager.indexOfBlockByBlock(cursor.block!);
    var blocks = [];
    if (selectState.hasSelect) {
      var start = selectState.realStart?.block;
      var end = selectState.realEnd?.block;
      if (start != null && end != null) {
        var startIndex = blockManager.indexOfBlockByBlock(start);
        var endIndex = blockManager.indexOfBlockByBlock(end);
        for (var i = startIndex; i <= endIndex; i++) {
          blocks.add(blockManager.blocks[i]);
        }
      } else {
        blocks.add(cursor.block);
      }
    } else {
      blocks.add(cursor.block);
    }
    var changeToLevel0 = true;
    for (var block in blocks) {
      if (block is TextBlock) {
        if (block.textElement.level != level) {
          changeToLevel0 = false;
          break;
        }
      }
    }
    if (changeToLevel0) {
      level = 0;
    }
    for (var block in blocks) {
      if (block is TextBlock) {
        var blockIndex = blockManager.indexOfBlockByBlock(block);
        var element = block.textElement;
        if (level == 0) {
          if (element.type != "quote") {
            element.type = "text";
          }
          element.level = 0;
          element.fontSize = null;
          blockManager.blocks[blockIndex] = TextBlock(
              editController: this, textElement: element, context: viewContext)
            ..top = block.top
            ..height = block.height;
        } else {
          if (element.type != "quote") {
            element.type = "title";
          }
          element.fontSize = null;
          element.level = level;
          blockManager.blocks[blockIndex] = TitleBlock(
            editController: this,
            textElement: element,
            context: viewContext,
          )
            ..top = block.top
            ..height = block.height;
        }
        var newBlock = blockManager.blocks[blockIndex];
        layoutCurrentBlock(newBlock);
      }
    }
    updateSelectCursor();
    var textPosition = cursor.textPosition;
    if (textPosition != null) {
      updateCursor(
          blockManager.blocks[cursorBlockIndex].getCursorPosition(textPosition),
          scrollToShowCursor: false,
          applyUpdate: false);
    }
    updateWidgetState();
  }

  ///改变文字为引用型
  void changeTextToQuote() {
    var startBlockIndex = currentStartBlockIndex;
    var endBlockIndex = currentEndBlockIndex;
    if (startBlockIndex != -1 && endBlockIndex != -1) {
      bool allIsQuote = true;
      for (var i = startBlockIndex; i <= endBlockIndex; i++) {
        var block = blockManager.blocks[i];
        if (block is TextBlock) {
          if (block.element.type != "quote") {
            allIsQuote = false;
          }
        }
      }
      for (var i = startBlockIndex; i <= endBlockIndex; i++) {
        var block = blockManager.blocks[i];
        if (block is TextBlock) {
          if (allIsQuote) {
            block.element.type = "text";
            if (block.element.level > 0) {
              block.element.type = "title";
            }
          } else {
            block.element.type = "quote";
          }
          block.relayoutFlag = true;
        }
      }
      layoutBlock(
          blockManager.blocks[startBlockIndex], startBlockIndex, endBlockIndex);
      updateWidgetState();
      refreshCursorPosition();
    }
  }

  ///添加代码block
  ///如果当前block为空，则将当前block转为code bock
  ///如果当前block部位空，则在下方插入code block
  void addCodeBlock({String code = "", String language = ""}) {
    var cPos = cursorState.cursorPosition;
    var cBlock = cPos?.block;
    var ctPos = cPos?.textPosition;
    if (cBlock != null && ctPos != null) {
      var blockIndex = blockManager.indexOfBlock(cBlock.top);
      var codeBlock = CodeBlock(
          editController: this,
          element: WenCodeElement(
            code: code,
            language: language,
          ),
          context: viewContext);
      if (cBlock.isEmpty) {
        blockManager.blocks[blockIndex] = codeBlock;
        codeBlock.top = cBlock.top;
        layoutCurrentBlock(codeBlock);
        refreshCursorPosition();
      } else {
        blockManager.blocks.insert(blockIndex + 1, codeBlock);
        layoutCurrentBlock(cBlock);
        updateCursor(
          codeBlock.startCursorPosition,
          scrollToShowCursor: true,
          applyUpdate: true,
        );
      }
    }
  }

  void addBlock(WenBlock block) {
    var cPos = cursorState.cursorPosition;
    var cBlock = cPos?.block;
    var ctPos = cPos?.textPosition;
    if (cBlock != null && ctPos != null) {
      var blockIndex = blockManager.indexOfBlock(cBlock.top);
      if (cBlock.isEmpty) {
        blockManager.blocks[blockIndex] = block;
        block.top = cBlock.top;
        layoutCurrentBlock(block);
        refreshCursorPosition();
      } else {
        blockManager.blocks.insert(blockIndex + 1, block);
        layoutCurrentBlock(cBlock);
        updateCursor(
          block.startCursorPosition,
          scrollToShowCursor: true,
          applyUpdate: true,
        );
      }
    }
  }

  ///添加文字block
  void addTextBlock() {
    var cPos = cursorState.cursorPosition;
    var cBlock = cPos?.block;
    var ctPos = cPos?.textPosition;
    selectState.clearSelect();
    if (cBlock != null && ctPos != null) {
      var blockIndex = blockManager.indexOfBlock(cBlock.top);
      var textBlock = TextBlock(
          editController: this,
          textElement: WenTextElement(),
          context: viewContext);
      textBlock.top = cBlock.top + cBlock.height;
      blockManager.blocks.insert(blockIndex + 1, textBlock);
      layoutCurrentBlock(textBlock);
      updateCursor(textBlock.startCursorPosition,
          scrollToShowCursor: true, applyUpdate: true);
      record();
    }
  }

  ///添加文字block
  void addTextBlockBefore() {
    var cPos = cursorState.cursorPosition;
    var cBlock = cPos?.block;
    var ctPos = cPos?.textPosition;
    selectState.clearSelect();
    if (cBlock != null && ctPos != null) {
      var blockIndex = blockManager.indexOfBlock(cBlock.top);
      var textBlock = TextBlock(
          editController: this,
          textElement: WenTextElement(),
          context: viewContext);
      textBlock.top = cBlock.top;
      blockManager.blocks.insert(blockIndex, textBlock);
      layoutCurrentBlock(textBlock);
      updateCursor(textBlock.startCursorPosition,
          scrollToShowCursor: true, applyUpdate: true);
      record();
    }
  }

  ///1.将选择文字创建链接
  ///2.弹出窗口添加链接
  void addLink() {
    var linkController = fluent.TextEditingController(text: "");
    var textController = fluent.TextEditingController(text: "");
    var ok = false;
    showMobileDialog(
        context: viewContext,
        builder: (context) {
          return fluent.ContentDialog(
            title: const fluent.Text("添加链接"),
            constraints: isMobile
                ? const BoxConstraints(maxWidth: 300)
                : fluent.kDefaultContentDialogConstraints,
            content: fluent.Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                fluent.Container(
                  margin: const EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: fluent.TextBox(
                    placeholder: "请输入链接文字",
                    autofocus: true,
                    onSubmitted: (s) {
                      ok = true;
                      Navigator.pop(context, '取消');
                    },
                    controller: textController,
                  ),
                ),
                fluent.Container(
                  child: fluent.TextBox(
                    placeholder: "http://",
                    controller: linkController,
                    onSubmitted: (s) {
                      ok = true;
                      Navigator.pop(context, '取消');
                    },
                  ),
                ),
              ],
            ),
            actions: [
              fluent.Button(
                child: const Text('取消'),
                onPressed: () {
                  Navigator.pop(context, '取消');
                  // Delete file here
                },
              ),
              fluent.FilledButton(
                  onPressed: () {
                    ok = true;
                    Navigator.pop(context, '确定');
                  },
                  child: const Text("确定")),
            ],
          );
        }).then((value) {
      if (ok && linkController.text.isNotEmpty) {
        var link = linkController.text;
        var text = textController.text;
        if (text.isEmpty) {
          text = link;
        }
        insertContent([
          TextBlock(
              editController: this,
              context: viewContext,
              textElement: WenTextElement(
                children: [
                  WenTextElement(
                    text: text,
                    url: link,
                  ),
                ],
              ))
        ], null);
        record();
      }
    });
  }

  /// 对文字设置链接
  void setLink() {
    var linkController = fluent.TextEditingController(text: "");
    var textController = fluent.TextEditingController(text: getSelectText());
    var ok = false;
    showMobileDialog(
        context: viewContext,
        builder: (context) {
          return fluent.ContentDialog(
            constraints: isMobile
                ? const BoxConstraints(maxWidth: 300, maxHeight: 300)
                : fluent.kDefaultContentDialogConstraints,
            title: const fluent.Text("添加链接"),
            content: fluent.Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                fluent.Container(
                  margin: const EdgeInsets.only(bottom: 10, top: 10),
                  child: fluent.TextBox(
                    placeholder: "请输入链接文字",
                    onSubmitted: (inputText) {
                      ok = true;
                      Navigator.pop(context, '取消');
                    },
                    controller: textController,
                  ),
                ),
                fluent.Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: fluent.TextBox(
                    autofocus: true,
                    placeholder: "http://",
                    controller: linkController,
                    onSubmitted: (s) {
                      ok = true;
                      Navigator.pop(context, '取消');
                    },
                  ),
                ),
              ],
            ),
            actions: [
              fluent.Button(
                child: const Text('取消'),
                onPressed: () {
                  Navigator.pop(context, '取消');
                  // Delete file here
                },
              ),
              fluent.FilledButton(
                  onPressed: () {
                    ok = true;
                    Navigator.pop(context, '确定');
                  },
                  child: const Text("确定")),
            ],
          );
        }).then((value) {
      if (ok && linkController.text.isNotEmpty) {
        var selectElement = selectState.start?.block?.element;
        WenTextElement? textElement;
        if (selectElement is WenTextElement) {
          textElement = selectElement;
        } else if (selectElement is WenTableElement) {
          var tableBlock = selectState.start?.block as TableBlock;
          textElement =
              tableBlock.getTextElement(selectState.start!.textPosition!);
        } else {
          return;
        }
        if (textElement == null) {
          return;
        }
        var link = linkController.text;
        var text = textController.text;
        var linkElement = textElement.copyStyle(null, [
          WenTextElement(
            text: text,
            url: link,
          ),
        ]);
        delete(false);
        if (text.isEmpty) {
          text = link;
        }
        insertContent([
          textElement.level == 0
              ? TextBlock(
                  editController: this,
                  context: viewContext,
                  textElement: linkElement)
              : TitleBlock(
                  editController: this,
                  context: viewContext,
                  textElement: linkElement),
        ], null);
        record();
      }
    });
  }

  void setTableBlockItemType(TableBlock block, String itemType) {
    block.setItemType(itemType: itemType);
  }

  ///1.将选择行转为listitem
  ///2.将当前行转未listitem
  void setItemType({String itemType = "li"}) {
    int? startIndex = selectState.realStart?.blockIndex;
    int? endIndex = selectState.realEnd?.blockIndex;
    if (!selectState.hasSelect) {
      var block = cursorState.cursorPosition?.block;
      if (block == null) {
        return;
      }
      startIndex = endIndex = blockManager.indexOfBlockByBlock(block);
    }
    if (itemType == "check" && startIndex != null && startIndex == endIndex) {
      var block = blockManager.blocks[startIndex];
      if (block is TableBlock) {
        setTableBlockItemType(block, "check");
        return;
      }
    }
    if (startIndex != null && endIndex != null) {
      if (blockManager.blocks.getRange(startIndex, endIndex + 1).any((item) {
        if (item is TextBlock) {
          return false;
        }
        return true;
      })) {
        return;
      }
      var setFunction = () {
        blockManager.blocks
            .getRange(startIndex!, endIndex! + 1)
            .forEach((block) {
          if (block is TextBlock && block is! TitleBlock) {
            var text = block.textElement;
            text.itemType = itemType;
            block.relayoutFlag = true;
          }
        });
      };
      var unSetFunction = () {
        blockManager.blocks
            .getRange(startIndex!, endIndex! + 1)
            .forEach((block) {
          if (block is TextBlock && block is! TitleBlock) {
            var text = block.textElement;
            text.itemType = "text";
            block.relayoutFlag = true;
          }
        });
      };
      if (blockManager.blocks.getRange(startIndex, endIndex + 1).any((block) {
        if (block is TextBlock) {
          return block.textElement.itemType != itemType;
        }
        return false;
      })) {
        setFunction.call();
      } else {
        unSetFunction.call();
      }
      layoutBlock(blockManager.blocks[startIndex], startIndex, endIndex);
      refreshCursorPosition();
      record();
    }
  }

  Future<void> addFormula() async {
    var formula = await showMobileDialog(
        context: viewContext,
        builder: (context) {
          return FormulaWidget();
        });

    if (formula is Map && formula["formula"] != null) {
      insertContent([
        TextBlock(
          editController: this,
          context: viewContext,
          textElement: WenTextElement(children: [
            WenTextElement(
              itemType: "formula",
              text: formula["formula"],
            ),
          ]),
        ),
      ], null);
      record();
    }
  }

  void addTable(int rowCount, int colCount) async {
    List<List<WenTextElement>> rows = [];
    for (int i = 0; i < rowCount; i++) {
      List<WenTextElement> row = [];
      rows.add(row);
      for (int j = 0; j < colCount; j++) {
        row.add(WenTextElement());
      }
    }
    addBlock(TableBlock(
      editController: this,
      context: viewContext,
      tableElement: WenTableElement(rows: rows),
    ));
    record();
  }

  void addLine() {
    addBlock(LineBlock(
        context: viewContext, element: LineElement(), editController: this));
    record();
  }

  void addTableRowOnPrevious() {
    var curBlock = cursorState.cursorPosition?.block;
    if (curBlock is TableBlock) {
      curBlock.addRowOnPrevious();
    }
  }

  void addTableRowOnNext() {
    var curBlock = cursorState.cursorPosition?.block;
    if (curBlock is TableBlock) {
      curBlock.addRowOnNext();
    }
  }

  void addTableColOnPrevious() {
    var curBlock = cursorState.cursorPosition?.block;
    if (curBlock is TableBlock) {
      curBlock.addColOnPrevious();
    }
  }

  void addTableColOnNext() {
    var curBlock = cursorState.cursorPosition?.block;
    if (curBlock is TableBlock) {
      curBlock.addColOnNext();
    }
  }

  void deleteTableRow() {
    var curBlock = cursorState.cursorPosition?.block;
    if (curBlock is TableBlock) {
      curBlock.deleteRow();
    }
  }

  void deleteTableCol() {
    var curBlock = cursorState.cursorPosition?.block;
    if (curBlock is TableBlock) {
      curBlock.deleteCol();
    }
  }

  void deleteTable() {
    var curBlock = cursorState.cursorPosition?.block;
    if (curBlock is TableBlock) {
      curBlock.deleteTable();
    }
  }

  void deleteCode() {
    var curBlock = cursorState.cursorPosition?.block;
    if (curBlock is CodeBlock) {
      curBlock.deleteCode();
    }
  }

  /// 如果选择了内容，则将选择内容删除，把选择内容text转为代码块
  /// 如果没选择内容，如果当前位置为代码块，则将代码块转为文字
  void toggleCode({String language = ""}) {
    if (cursorState.cursorPosition?.isValid != true) {
      return;
    }
    //如果是code，则转为text
    var isCodeBlock = cursorState.cursorPosition?.block is CodeBlock;
    var codeBlockIndex = 0;
    if (isCodeBlock) {
      codeBlockIndex = cursorState.cursorPosition!.block!.blockIndex;
    }
    if (selectState.hasSelect) {
      isCodeBlock = (selectState.start?.block is CodeBlock) &&
          (selectState.start?.blockIndex == selectState.end?.blockIndex);
      if (isCodeBlock) {
        codeBlockIndex = selectState.start!.blockIndex!;
      }
    }
    if (isCodeBlock) {
      replaceBlock(
          codeBlockIndex,
          1,
          parseTextToBlock(
              (cursorState.cursorPosition?.block as CodeBlock).element.code));
      toPosition(blockManager.blocks[codeBlockIndex].startCursorPosition, true);
      record();
      return;
    }
    //不是code，转为code
    var code = getSelectText();
    if (!cursorState.cursorPosition!.block!.isEmpty) {
      enter();
      toLeft();
    }
    var block = cursorState.cursorPosition!.block!;
    var pos = cursorState.cursorPosition!.textPosition!.offset;
    var len = block.length;
    var blockIndex = block.blockIndex;
    if (block.isEmpty || pos >= len - 1) {
      addCodeBlock(code: code, language: language);
      toPosition(
          blockManager.blocks[block.isEmpty ? blockIndex : blockIndex + 1]
              .startCursorPosition,
          true);
    } else {
      replaceBlock(blockIndex, 0, [
        CodeBlock(
          element: WenCodeElement(code: code, language: language),
          context: viewContext,
          editController: this,
        )
      ]);
      toPosition(blockManager.blocks[blockIndex].startCursorPosition, true);
    }
    record();
  }

  void replaceBlock(int startIndex, int replaceCount, List<WenBlock> blocks) {
    blockManager.blocks
        .replaceRange(startIndex, startIndex + replaceCount, blocks);
    if (blockManager.blocks.isEmpty) {
      blockManager.blocks.add(TextBlock(
          context: viewContext,
          editController: this,
          textElement: WenTextElement()));
    }
    var layoutStartIndex = max(startIndex - 1, 0);
    layoutBlock(blockManager.blocks[max(startIndex - 1, 0)], layoutStartIndex,
        startIndex + replaceCount);
  }

  void clearStyle() {
    formatText((block, element) => element.clearStyle());
  }

  ///1.对齐方式修改
  ///2.字体颜色修改
  ///3.字体背景颜色修改
  ///4.链接修改
  ///5.粗体、斜体、下划线、删除线
  ///
  void formatText(WenElementVisitor visitor, {bool splitUrl = false}) {
    var start = selectState.realStart;
    var end = selectState.realEnd;
    if (!selectState.hasSelect) {
      start = end = cursorState.cursorPosition;
    }
    if (start == null || end == null) {
      return;
    }
    var startBlock = start.block!;
    var endBlock = end.block!;
    var startTextPos = start.textPosition!;
    var startTextPosDownStream = TextPosition(
        offset: startTextPos.offset, affinity: TextAffinity.downstream);
    var endTextPos = end.textPosition!;
    var endTextPosUpStream = TextPosition(
        offset: endTextPos.offset, affinity: TextAffinity.upstream);
    WenTextElement? startElement;
    WenTextElement? endElement;
    //对text element进行拆分处理
    if (startBlock is TextBlock) {
      startBlock.textElement.splitElementInterior(startTextPosDownStream,
          splitUrlElement: splitUrl);
    } else if (startBlock is TableBlock) {
      startBlock.splitElementInterior(startTextPosDownStream,
          splitUrlElement: splitUrl);
    }
    if (endBlock is TextBlock) {
      endBlock.textElement
          .splitElementInterior(endTextPosUpStream, splitUrlElement: splitUrl);
    } else if (endBlock is TableBlock) {
      endBlock.splitElementInterior(endTextPosUpStream,
          splitUrlElement: splitUrl);
    }
    //获取拆分后的首个text element和最后一个text element
    if (startBlock is TextBlock) {
      startElement = startBlock.textElement.getElement(startTextPosDownStream);
    }
    if (endBlock is TextBlock) {
      endElement = endBlock.textElement.getElement(endTextPosUpStream);
    }
    //处理首个 text element
    if (startElement != null) {
      visitor.call(startBlock, startElement);
    }
    //处理中间的 text element
    visitSelectElement((block, element) {
      if (element is! WenTextElement) {
        return;
      }
      if (block is TableBaseCell) {
        var table = TableBaseCell.of(block).tableBlock;
        table.tableElement.remarkUpdated();
        visitor.call(table, element);
        block.relayoutFlag = true;
      } else {
        if (block == startBlock &&
            startElement != null &&
            element.offset < startElement.offset) {
          return;
        } else if (block == endBlock &&
            endElement != null &&
            element.offset > endElement.offset) {
          return;
        }
        visitor.call(block, element);
      }
    });
    //处理最后一个 text element
    if (endElement != null) {
      visitor.call(endBlock, endElement);
    }
    var startBlockIndex =
        start.blockIndex ?? blockManager.indexOfBlockByBlock(startBlock);
    var endBlockIndex =
        end.blockIndex ?? blockManager.indexOfBlockByBlock(endBlock);
    for (var i = startBlockIndex; i <= endBlockIndex; i++) {
      var curBlock = blockManager.blocks[i];
      curBlock.relayoutFlag = true;
    }
    updateWidgetState();
    record();
  }

  void setTableAlignment(TableBlock block, String alignment) {
    block.setAlignment(alignment);
    record();
  }

  void updateFormula(TextBlock block, WenTextElement element, String formula) {
    element.text = formula;
    record();
    refreshCursorPosition();
  }

  void adjustTable(TableBlock tableBlock, int newRowCount, int newColCount) {
    tableBlock.rows =
        tableBlock.addJustRows(newRowCount, newColCount, viewContext);
    tableBlock.calcLength();
    tableBlock.tableElement.rows = tableBlock.rows
        .map((e) => e.map((cell) => cell.element).toList())
        .toList();
    tableBlock.tableElement.remarkUpdated();
    layoutCurrentBlock(tableBlock);
    updateWidgetState();
    record();
  }

  void changeBlockChecked(TextBlock textBlock, bool? checked) {
    record();
  }

  void onSelectChanged() {}

  void setBold(bool? bold) {
    formatText((block, element) {
      if (element is WenTextElement) {
        element.bold = bold;
      }
    });
  }

  void setLineThrough(bool? lineThrough) {
    formatText((block, element) {
      if (element is WenTextElement) {
        element.lineThrough = lineThrough;
      }
    });
  }

  void setUnderline(bool? underline) {
    formatText((block, element) {
      if (element is WenTextElement) {
        element.underline = underline;
      }
    });
  }

  void setItalic(bool? italic) {
    formatText((block, element) {
      if (element is WenTextElement) {
        element.italic = italic;
      }
    });
  }

  void setBackgroundColor(int index) {
    formatText((block, element) {
      if (element is WenTextElement) {
        element.background = defaultColors[index]?.value;
      }
    });
  }

  void setTextColor(int index) {
    formatText((block, element) {
      if (element is WenTextElement) {
        element.color = defaultColors[index]?.value;
      }
    });
  }
}
