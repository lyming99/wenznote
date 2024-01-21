import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:wenznote/editor/block/text/text.dart';
import 'package:wenznote/editor/cursor/cursor.dart';
import 'package:wenznote/editor/edit_controller.dart';
import 'package:wenznote/editor/edit_float_widget.dart';
import 'package:wenznote/editor/widget/drop_menu.dart';

class IndexSelection {
  int start = 0;
  int end = 0;
  Rect rect;
  String text;
  CursorPosition? startCursor;
  CursorPosition? endCursor;

  IndexSelection({
    required this.start,
    required this.end,
    required this.rect,
    required this.text,
    this.startCursor,
    this.endCursor,
  });
}

class WenPopupTool {
  EditController controller;
  OverlayEntry? entry;
  List<ToolAction> currentActions = [];
  int actionIndex = 0;

  WenPopupTool({
    required this.controller,
  });

  List<ToolAction> get allActions => [
        // 标题1-6
        ToolAction(
          text: ("标题一"),
          keys: ["biaoti1", "bt1", "h1", "head1", "标题1", "title1", "t1"],
          description: ("Ctrl + 1"),
          callback: () {
            addTitle(1);
          },
        ),
        ToolAction(
          text: ("标题二"),
          keys: ["biaoti2", "bt2", "h2", "head2", "标题2", "title2", "t2"],
          description: ("Ctrl + 2"),
          callback: () {
            addTitle(2);
          },
        ),
        ToolAction(
          text: ("标题三"),
          keys: ["biaoti3", "bt3", "h3", "head3", "标题3", "title3", "t3"],
          description: ("Ctrl + 3"),
          callback: () {
            addTitle(3);
          },
        ),
        ToolAction(
          text: ("标题四"),
          keys: ["biaoti4", "bt4", "h4", "head4", "标题4", "title4", "t4"],
          description: ("Ctrl + 4"),
          callback: () {
            addTitle(4);
          },
        ),
        ToolAction(
          text: ("标题五"),
          keys: ["biaoti5", "bt5", "h5", "head5", "标题5", "title5", "t5"],
          description: ("Ctrl + 5"),
          callback: () {
            addTitle(5);
          },
        ),
        ToolAction(
          text: ("标题六"),
          keys: ["biaoti6", "bt6", "h6", "head6", "标题6", "title6", "t6"],
          description: ("Ctrl + 6"),
          callback: () {
            addTitle(6);
          },
        ),
        ToolAction(
          text: ("无序列表"),
          keys: ["wuxuliebiao", "wxlb", "li", "item"],
          description: ("Ctrl + I"),
          callback: () {
            addItemType("li");
          },
        ),
        ToolAction(
          text: ("任务列表"),
          keys: ["renwuliebiao", "rwlb", "todo", "task", "check"],
          description: ("Ctrl + T"),
          callback: () {
            addItemType("check");
          },
        ),
        ToolAction(
          text: ("链接"),
          keys: ["url", "lianjie", "lj", "href", "src", "link"],
          description: ("Ctrl + Shift + L"),
          callback: () {
            addLink();
          },
        ),
        ToolAction(
          text: ("引用"),
          keys: ["yinyong", "yy", "quote", "mark"],
          description: ("Ctrl + 8"),
          callback: () {
            addQuote();
          },
        ),
        ToolAction(
          text: ("公式"),
          keys: ["formula", "gs", "gongshi"],
          description: ("Ctrl + 9"),
          callback: () {
            addFormula();
          },
        ),
        ToolAction(
          text: ("代码块"),
          keys: ["code", "daimakuai", "dm"],
          description: ("Ctrl + Alt + K"),
          callback: () {
            addCode();
          },
        ),
        ToolAction(
          text: ("表格"),
          keys: ["table", "bg", "biaoge"],
          description: ("Ctrl + Shift + T"),
          callback: () {
            addTable();
          },
        ),
        ToolAction(
          text: ("分割线"),
          keys: ["fengexian", "fgx", "line", "split"],
          callback: () {
            addLine();
          },
        ),
      ];

  Rect? getRangeSelectRect(CursorPosition? start, CursorPosition? end) {
    double left = double.infinity;
    double right = 0;
    double top = double.infinity;
    double bottom = 0;
    var startRect = controller.getCursorRect(start);
    if (startRect != null) {
      left = min(left, startRect.left);
      right = max(right, startRect.right);
      top = min(top, startRect.top);

      bottom = max(bottom, startRect.bottom);
    }
    var endRect = controller.getCursorRect(end);
    if (endRect != null) {
      left = min(left, endRect.left);
      right = max(right, endRect.right);
      top = min(top, endRect.top);
      bottom = max(bottom, endRect.bottom);
    }
    var rendBox = controller.viewContext.findRenderObject();
    if (rendBox is! RenderBox) {
      return null;
    }
    var offset = rendBox.localToGlobal(Offset.zero);
    return Rect.fromLTRB(left, top, right, bottom)
        .translate(controller.padding.left,
            controller.padding.top - controller.scrollOffset)
        .translate(offset.dx, offset.dy);
  }

  IndexSelection? getSlashRange() {
    var cursor = controller.cursorState.cursorPosition;
    if (cursor == null) {
      return null;
    }
    var block = cursor.block;
    if (block is! TextBlock) {
      return null;
    }
    var pos = cursor.textPosition;
    if (pos == null) {
      return null;
    }
    var text = block.element.getText();
    if (text.isEmpty) {
      return null;
    }
    var endOffset = pos.offset - 1;
    if (endOffset < 0) {
      return null;
    }
    var startOffset = -1;
    for (var i = endOffset; i >= 0; i--) {
      if (text[i] == "/") {
        startOffset = i;
        break;
      }
    }
    if (startOffset == -1) {
      return null;
    }
    var startPosition = block
        .getCursorPosition(TextPosition(offset: startOffset))
      ..blockIndex = cursor.blockIndex;
    var endPosition = block.getCursorPosition(TextPosition(offset: endOffset));
    var rect = getRangeSelectRect(startPosition, endPosition);
    if (rect == null) {
      return null;
    }
    return IndexSelection(
      start: startOffset,
      end: endOffset,
      rect: rect,
      text: text.substring(startOffset, endOffset + 1),
      startCursor: startPosition,
      endCursor: cursor,
    );
  }

  void show([bool input = false]) {
    if (input == false && entry == null) {
      return;
    }
    hide();
    var range = getSlashRange();
    if (range == null) {
      return;
    }
    currentActions = allActions
        .where((element) => element.containsKey(range.text.substring(1)))
        .toList();
    if (currentActions.isEmpty) {
      return;
    }
    if (actionIndex >= currentActions.length) {
      actionIndex = 0;
    }
    if (actionIndex < 0) {
      actionIndex = currentActions.length - 1;
    }
    var menus = <DropMenu>[];
    for (var i = 0; i < currentActions.length; i++) {
      var value = currentActions[i];
      menus.add(DropMenu(
        checked: actionIndex == i,
        text: Text(value.text ?? ""),
        description: Text(value.description ?? ""),
        onPress: (ctx) {
          value.callback?.call();
        },
      ));
    }
    var maxHeight = 240.0;
    var currentOffset = actionIndex * 36 + 8;
    var initOffset = 0.0;
    if (currentOffset > maxHeight - 36) {
      initOffset = currentOffset - maxHeight + 36;
    }

    var widget = DropMenuWidget(
      buttonContext: controller.viewContext,
      menus: menus,
      anchorRect: range.rect,
      childrenWidth: 300,
      childrenHeight: 36,
      margin: 0,
      popupAlignment: Alignment.bottomLeft,
      overflowAlignment: Alignment.topLeft,
      maxHeight: maxHeight,
      rootScrollController: ScrollController(initialScrollOffset: initOffset),
    );
    entry = OverlayEntry(builder: (context) {
      return Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: PopupWindowWidget(
          entry: entry!,
          focus: false,
          child: widget,
        ),
      );
    });
    Overlay.of(controller.viewContext, rootOverlay: true).insert(entry!);
    entry!.addListener(() {
      if (entry?.mounted == false) {
        entry = null;
      }
    });
  }

  bool get isShow {
    return entry != null;
  }

  void hide() {
    try {
      entry?.remove();
    } catch (e) {
      print(e);
    }
    entry = null;
  }

  void enter() {
    try {
      currentActions[actionIndex].callback?.call();
    } catch (e) {
      print(e);
    }
    hide();
  }

  void toDown() {
    actionIndex++;
    show();
  }

  void toUp() {
    actionIndex--;
    show();
  }

  void _deleteSlash() {
    var range = getSlashRange();
    if (range == null) {
      return;
    }
    controller.setSelection(range.startCursor, range.endCursor);
    controller.deleteSelectRange();
  }

  void addTitle(int level) {
    _deleteSlash();
    controller.changeTextLevel(level);
  }

  void addItemType(String itemType) {
    _deleteSlash();
    controller.setItemType(itemType: itemType);
  }

  void addLine() {
    _deleteSlash();
    controller.addLine();
  }

  void addQuote() {
    _deleteSlash();
    controller.changeTextToQuote();
  }

  void addLink() {
    _deleteSlash();
    controller.addLink();
  }

  void addCode() {
    _deleteSlash();
    controller.toggleCode();
  }

  void addFormula() {
    _deleteSlash();
    controller.addFormula();
  }

  void addTable() {
    _deleteSlash();
    controller.showAddTableDialog();
  }
}

class ToolAction {
  List<String>? keys;
  Function? callback;
  Widget? icon;
  String? text;
  String? description;

  ToolAction({
    this.keys,
    this.callback,
    this.icon,
    this.text,
    this.description,
  });

  bool containsKey(String? key) {
    var keys = this.keys;
    if (keys == null || keys.isEmpty) {
      return false;
    }
    if (key == null || key.isEmpty) {
      return true;
    }
    if (true == text?.toLowerCase().contains(key.toLowerCase())) {
      return true;
    }
    for (var value in keys) {
      if (value.toLowerCase().contains(key.toLowerCase())) {
        return true;
      }
    }
    return false;
  }
}
