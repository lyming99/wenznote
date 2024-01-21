import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:wenznote/editor/block/block.dart';
import 'package:wenznote/editor/block/element/element.dart';
import 'package:wenznote/editor/edit_controller.dart';
import 'package:wenznote/editor/theme/theme.dart';

import '../text/text.dart';
import 'line_element.dart';

class LineBlock extends WenBlock {
  bool delete = false;
  double lineHeight = 1.2;
  double padding = 1;
  @override
  LineElement element;

  LineBlock({
    required context,
    required this.element,
    required super.editController,
  }) : super(context: context);

  double calcIndentWidth() {
    return indentWidth * (element.indent ?? 0);
  }

  bool get isSelected =>
      selected && selectedStart?.offset == 0 && selectedEnd?.offset == 1;

  @override
  Widget buildWidget(BuildContext context) {
    this.context = context;
    if (delete) {
      return Container(
        padding: EdgeInsets.all(padding),
      );
    }
    var alignment = calcAlignment();
    var offsetX = calcIndentWidth();
    return Container(
      padding: offsetX > 0 ? EdgeInsets.only(left: offsetX) : null,
      height: height,
      child: Stack(
        children: [
          Align(
            alignment: alignment,
            child: Center(
              child: Container(
                width: width - calcIndentWidth() - padding * 2,
                height: lineHeight,
                color: EditTheme.of(context).lineColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  int get length => delete ? 0 : 1;

  @override
  WenElement copyElement(TextPosition start, TextPosition end) {
    if (delete) {
      return WenTextElement();
    }
    if (end.offset == 1 && start.offset == 0) {
      return LineElement();
    }
    return WenTextElement();
  }

  @override
  int deletePosition(TextPosition textPosition) {
    int len = length;
    if (textPosition.offset == 1) {
      delete = true;
      relayoutFlag = true;
    }
    return len - length;
  }

  @override
  void deleteRange(TextPosition start, TextPosition end) {
    if (end.offset == 1 && start.offset == 0) {
      delete = true;
      relayoutFlag = true;
    }
  }

  @override
  List<TextBox> getBoxesForSelection(TextSelection selection) {
    int start = selection.baseOffset;
    int end = selection.extentOffset;
    if (start == 0 && end == 1) {
      return [
        TextBox.fromLTRBD(
            calcIndentWidth() + padding,
            padding,
            width - calcIndentWidth() - padding * 2,
            height - padding * 2,
            TextDirection.ltr)
      ];
    }
    return [];
  }

  @override
  Rect? getCursorRect(TextPosition textPosition) {
    if (delete || textPosition.offset == 0) {
      return Rect.fromLTWH(calcIndentWidth() + padding - 1, padding - 5, 2,
          height - padding * 2 + 10);
    } else {
      return Rect.fromLTWH(
          width - padding - 1, padding - 5, 2, height - padding * 2 + 10);
    }
  }

  @override
  TextRange? getWordBoundary(TextPosition textPosition) {
    return const TextRange(start: 0, end: 1);
  }

  @override
  TextPosition? getPositionForOffset(Offset offset) {
    if (delete ||
        offset.dx <=
            calcIndentWidth() + (width - padding * 2 - calcIndentWidth()) / 2) {
      return const TextPosition(offset: 0);
    } else {
      return const TextPosition(offset: 1);
    }
  }

  @override
  void inputText(EditController controller, TextEditingValue text,
      {bool isComposing = false}) {}

  @override
  void layout(BuildContext context, Size viewSize) {
    this.context = context;
    width = viewSize.width;
  }

  @override
  WenBlock? mergeBlock(WenBlock endBlock) {
    return null;
  }

  @override
  WenBlock splitBlock(TextPosition textPosition) {
    return TextBlock(
      context: context,
      textElement: WenTextElement(),
      editController: editController,
    );
  }

  @override
  ui.TextRange? getLineBoundary(ui.TextPosition textPosition) {
    return getWordBoundary(textPosition);
  }

  @override
  void visitElement(
      TextPosition start, TextPosition end, WenElementVisitor visit) {
    if (start.offset == 0 && end.offset == 1) {
      visit.call(this, element);
    }
  }
}
