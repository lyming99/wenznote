import 'package:flutter/material.dart';
import 'package:note/commons/service/file_manager.dart';
import 'package:note/commons/widget/popup_stack.dart';
import 'package:note/editor/theme/theme.dart';

import '../edit_controller.dart';
import '../cursor/cursor.dart';
import 'element/element.dart';
import 'text/link.dart';

typedef WenElementVisitor = Function(WenBlock block, WenElement element);
typedef WenBlockVisitor = Function(WenBlock block);

abstract class WenBlock {
  BuildContext context;
  EditController editController;
  double left = 0;
  double top = 0;
  double width = 0;
  double height = 10;
  bool relayoutFlag = true;
  bool selected = false;
  TextPosition? selectedStart;
  TextPosition? selectedEnd;
  TextPosition? hoverPosition;
  TextPosition? cursorPosition;

  bool isSingleBlock = false;

  bool catchEnter = false;

  bool catchScroll = false;

  List<TextSelection>? get searchRanges {
    return null;
  }

  Color get cursorColor {
    return theme.cursorColor;
  }

  bool canEmpty = false;

  bool canSelectAll = false;

  ///缩进
  bool canIndent = false;

  double get indentWidth {
    return 32;
  }

  WenElement get element;

  WenBlock({
    required this.editController,
    required this.context,
  });

  int get length;

  bool get isEmpty => length <= 0;

  bool get needClearStyle => false;

  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is WenBlock && other.top == top;
  }

  TextPosition get endPosition {
    return TextPosition(offset: length);
  }

  TextPosition get startPosition {
    return const TextPosition(offset: 0);
  }

  TextRange? getWordBoundary(TextPosition textPosition);

  /// 获取光标当前行文字范围
  TextRange? getLineBoundary(TextPosition textPosition);

  /// 获取TextBox用于绘制选择范围
  List<TextBox> getBoxesForSelection(TextSelection selection) => [];

  BlockLink? getLink(TextPosition textPosition) {
    return null;
  }

  WenElement? getElement(TextPosition textPosition) {
    return null;
  }

  /// 根据坐标偏移，获取文字位置
  TextPosition? getPositionForOffset(Offset offset);

  /// 根据文字位置获取光标绘制范围
  Rect? getCursorRect(TextPosition textPosition);

  /// 获取光标位置
  CursorPosition getCursorPosition(TextPosition textPosition) {
    return CursorPosition(
        block: this,
        textPosition: textPosition,
        rect: getCursorRect(textPosition));
  }

  /// 获取开头光标位置
  CursorPosition get startCursorPosition {
    var position = startPosition;
    return CursorPosition(
        block: this, textPosition: position, rect: getCursorRect(position));
  }

  /// 获取结尾光标位置
  CursorPosition get endCursorPosition {
    var position = endPosition;
    return CursorPosition(
        block: this, textPosition: position, rect: getCursorRect(position));
  }

  /// 对内容布局
  void layout(BuildContext context, Size viewSize);

  /// 构建视图widget组件
  Widget buildWidget(BuildContext context);

  /// 输入文字
  void inputText(EditController controller, TextEditingValue text,
      {bool isComposing = false});

  /// 合并block
  WenBlock? mergeBlock(WenBlock endBlock);

  /// 往前删除
  int deletePosition(TextPosition textPosition);

  /// 范围删除 start == end 时，不删除任何内容【
  void deleteRange(TextPosition start, TextPosition end);

  /// 分割block
  WenBlock splitBlock(TextPosition textPosition);

  /// 复制内容
  WenElement copyElement(TextPosition start, TextPosition end);

  void visitElement(
      TextPosition start, TextPosition end, WenElementVisitor visit) {}

  EditTheme get theme => EditTheme.of(editController.context);

  List<PopupPositionWidget> buildFloatWidgets() {
    return [];
  }

  List<PopupPositionWidget> buildBackgroundWidgets() {
    return [];
  }

  /// 对齐方式计算
  Alignment calcAlignment({String? alignment}) {
    alignment ??= element.alignment;
    if (alignment == "center") {
      return Alignment.topCenter;
    } else if (alignment == "right") {
      return Alignment.topRight;
    }
    return Alignment.topLeft;
  }

  Offset calcAlignmentOffset(
    Size widgetSize,
    Alignment alignment,
  ) {
    num visibleWidth = width;
    num visibleHeight = height;
    num visibleStartX = 0;
    num visibleStartY = 0;

    Offset position = const Offset(0, 0);

    if (alignment == Alignment.topLeft) {
      position = const Offset(0, 0);
    } else if (alignment == Alignment.topCenter) {
      position = Offset(
        visibleStartX + (visibleWidth / 2) - (widgetSize.width / 2),
        visibleStartY + 0,
      );
    } else if (alignment == Alignment.topRight) {
      position = Offset(
        visibleStartX + visibleWidth - widgetSize.width,
        visibleStartY + 0,
      );
    } else if (alignment == Alignment.centerLeft) {
      position = Offset(
        visibleStartX + 0,
        visibleStartY + ((visibleHeight / 2) - (widgetSize.height / 2)),
      );
    } else if (alignment == Alignment.center) {
      position = Offset(
        visibleStartX + (visibleWidth / 2) - (widgetSize.width / 2),
        visibleStartY + ((visibleHeight / 2) - (widgetSize.height / 2)),
      );
    } else if (alignment == Alignment.centerRight) {
      position = Offset(
        visibleStartX + visibleWidth - widgetSize.width,
        visibleStartY + ((visibleHeight / 2) - (widgetSize.height / 2)),
      );
    } else if (alignment == Alignment.bottomLeft) {
      position = Offset(
        visibleStartX + 0,
        visibleStartY + (visibleHeight - widgetSize.height),
      );
    } else if (alignment == Alignment.bottomCenter) {
      position = Offset(
        visibleStartX + (visibleWidth / 2) - (widgetSize.width / 2),
        visibleStartY + (visibleHeight - widgetSize.height),
      );
    } else if (alignment == Alignment.bottomRight) {
      position = Offset(
        visibleStartX + visibleWidth - widgetSize.width,
        visibleStartY + (visibleHeight - widgetSize.height),
      );
    }

    return position;
  }

  TextAlign calcTextAlign() {
    if (element.alignment == "center") {
      return TextAlign.center;
    } else if (element.alignment == "right") {
      return TextAlign.end;
    }
    return TextAlign.start;
  }

  String? composing;

  void onInputComposing(EditController editController, String composing) {}

  int get blockIndex {
    return editController.blockManager.indexOfBlock(top);
  }

  int get blockCount {
    return editController.blockManager.blocks.length;
  }

  double get divideWidth {
    return editController.blockManager.divideWidth;
  }

  List<WenBlock> get blocks {
    return editController.blockManager.blocks;
  }

  WenBlock? get previousBlock {
    var index = blockIndex;
    var blocks = editController.blockManager.blocks;
    if (index - 1 >= 0) {
      return blocks[index - 1];
    }
    return null;
  }

  WenBlock? get nextBlock {
    var index = blockIndex;
    var blocks = editController.blockManager.blocks;
    if (index + 1 < blocks.length) {
      return blocks[index + 1];
    }
    return null;
  }

  bool toUp() {
    return false;
  }

  bool toDown() {
    return false;
  }

  void scrollHorizontal(double deltaX) {}

  void scrollToCursorPosition(CursorPosition cursorPosition) {}

  bool selectAll() {
    return false;
  }
}
