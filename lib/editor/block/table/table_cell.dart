import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/services/text_input.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:wenznote/editor/block/block.dart';
import 'package:wenznote/editor/edit_controller.dart';
import 'table_block.dart';

/// table cell
/// 支持：1.文本(链接、颜色、换行、高亮、下划线、公式) 2.图片
abstract class TableBaseCell {
  double width = 20;
  double height = 20;
  double? originWidth;
  double? originHeight;
  int offset = 0;
  String? alignment;
  double cellTop = 0;
  double cellLeft = 0;
  late TableBlock tableBlock;

  static TableBaseCell of(WenBlock block) {
    return block as TableBaseCell;
  }

  ///计算原始高度
  void calcOriginSize(BuildContext context);

  ///计算渲染高度
  void layout(BuildContext context, Size viewSize);

  ///真正的渲染
  Widget buildWidget(BuildContext context);

  Positioned buildCellWidget(BuildContext context, double rowRenderOffset,
      double columnRenderOffset, double minWidth, double minHeight,
      {String? alignment}) {
    this.alignment = alignment;
    cellLeft = columnRenderOffset;
    cellTop = rowRenderOffset;
    return Positioned(
      left: columnRenderOffset,
      top: rowRenderOffset,
      width: max(width, minWidth),
      height: max(height, minHeight),
      child: Container(
        child: buildWidget(
          context,
        ),
      ),
    );
  }

  void inputCellText(EditController controller, TableBlock table,
      TextPosition cellTextOffset, TextEditingValue text,
      {bool isComposing = false}){}
}
