import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:note/editor/block/table/table_cell.dart';
import 'package:note/editor/block/text/text.dart';
import 'package:note/editor/edit_controller.dart';
import 'package:note/editor/widget/toggle_item.dart';

import '../text/rich_text_painter.dart';
import 'table_block.dart';

class TextTableCell extends TextBlock with TableBaseCell {
  TextTableCell({
    required super.context,
    required super.textElement,
    required super.editController,
    required TableBlock tableBlock,
  }) {
    this.tableBlock = tableBlock;
  }

  String? cacheJson;

  @override
  bool getPreviousIsQuote() {
    return false;
  }

  @override
  bool getNextIsQuote() {
    return false;
  }

  @override
  double get indentWidth {
    return 0;
  }

  @override
  void calcOriginSize(BuildContext context) {
    if (relayoutFlag == false) {
      return;
    }
    var textSpan = super.createTextSpan();
    var dimensions = <PlaceholderDimensions>[];
    var widgetSpans = <PlaceholderSpan>[];
    calcPlaceHolderDimensions(textSpan, widgetSpans, context, dimensions);
    var richTextPainter = RichTextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      strutStyle: StrutStyle.fromTextStyle(
        textSpan.style ?? const TextStyle(),
        forceStrutHeight: false,
      ),
      textHeightBehavior: const TextHeightBehavior(
        applyHeightToLastDescent: true,
        applyHeightToFirstAscent: true,
      ),
      textAlign: calcTextAlign(),
      textScaleFactor: 1.02,
    );
    if (dimensions.isNotEmpty) {
      richTextPainter.setPlaceholderDimensions(dimensions);
    }
    richTextPainter.layout();
    originWidth = richTextPainter.width + checkItemWidth;
    originHeight = richTextPainter.height;
  }

  @override
  Widget buildCheckItem(BuildContext context) {
    return ToggleItem(
      itemBuilder:
          (BuildContext context, bool checked, bool hover, bool pressed) {
        return fluent.Checkbox(
          checked: checked,
          onChanged: (val) {
            textElement.checked = val;
            tableBlock.tableElement.remarkUpdated();
            editController.record();
            if (editController.editable) {
              editController.requestFocus();
            }
          },
        );
      },
      checked: textElement.checked == true,
    );
  }

  @override
  Widget buildWidget(BuildContext context) {
    if (alignment != textElement.alignment) {
      textElement.alignment = alignment;
      relayoutFlag = true;
      WidgetsBinding.instance.scheduleFrameCallback((timeStamp) {
        editController.refreshCursorPosition();
      });
    }
    return super.buildWidget(context);
  }

  @override
  void inputCellText(
    EditController controller,
    TableBlock table,
    TextPosition cellTextOffset,
    TextEditingValue text, {
    bool isComposing = false,
  }) {
    if (isComposing) {
      textElement.insertElement(
          cellTextOffset, WenTextElement(text: text.text, underline: true));
    } else {
      textElement.inputText(cellTextOffset, text);
    }
    relayoutFlag = true;
    table.calcLength();
    controller.layoutCurrentBlock(table);
    int offset = cellTextOffset.offset + text.text.length;
    var newPosition = TextPosition(
      offset: this.offset + offset,
    );
    var cursor = table.getCursorPosition(newPosition);
    controller.toPosition(cursor, true);
  }
}
