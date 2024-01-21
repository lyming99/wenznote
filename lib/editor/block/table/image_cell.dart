import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/services/text_input.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:wenznote/editor/block/image/image_block.dart';
import 'package:wenznote/editor/edit_controller.dart';
import 'table_block.dart';
import 'table_cell.dart';

class ImageTableCell extends ImageBlock with TableBaseCell {
  double maxCellImageWidth = 400;

  ImageTableCell({
    required super.context,
    required super.element,
    required super.editController,
    required TableBlock tableBlock,
  }) {
    this.tableBlock = tableBlock;
  }

  @override
  Alignment calcAlignment({String? alignment}) {
    var rowIndex = tableBlock.getRowIndex(offset);
    var colIndex = tableBlock.getColIndex(rowIndex, offset);
    var alignType = tableBlock.getColAlignment(colIndex);
    return super.calcAlignment(alignment: alignType);
  }

  @override
  bool get isSelected =>
      tableBlock.selected &&
      (tableBlock.selectedStart?.offset??0) <= offset &&
      (tableBlock.selectedEnd?.offset??0) >= offset + 1;

  @override
  void calcOriginSize(BuildContext context) {
    var mq = MediaQuery.of(context);
    var ratio = mq.devicePixelRatio;
    if (ratio <= 0) {
      ratio = 1;
    }
    var w = element.width;
    var h = element.height;
    var viewMaxImageHeight = (maxCellImageWidth - padding * 2) * h / w;
    var maxImageHeight = viewMaxImageHeight;
    var imageHeight = h / ratio;
    if (imageHeight < maxImageHeight) {
      height = imageHeight + padding * 2;
    } else {
      imageHeight = maxImageHeight;
      height = maxImageHeight + padding * 2;
    }
    originWidth = imageHeight * w / h;
    originHeight = imageHeight;
  }

  @override
  Rect? getCursorRect(TextPosition textPosition) {
    var rowIndex = tableBlock.getRowIndex(textPosition.offset);
    var colIndex = tableBlock.getColIndex(rowIndex, textPosition.offset);
    var alignType = tableBlock.getColAlignment(colIndex);
    var alignment = calcAlignment(alignment: alignType);
    var offset = calcAlignmentOffset(Size(imageWidth, imageHeight), alignment);
    if (delete || textPosition.offset == 0) {
      return Rect.fromLTWH(
          offset.dx + padding - 1, offset.dy + padding, 1, imageHeight);
    } else {
      return Rect.fromLTWH(imageWidth + offset.dx + padding - 1,
          offset.dy + padding, 1, imageHeight);
    }
  }
}
