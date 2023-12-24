import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:note/service/user/user_service.dart';
import '../../../commons/service/file_manager.dart';
import '../../edit_controller.dart';
import '../block.dart';
import '../element/element.dart';
import '../text/text.dart';
import 'video_element.dart';

class VideoBlock extends WenBlock {
  bool delete = false;
  double imageWidth = 0;
  double imageHeight = 0;
  double padding = 1;
  @override
  VideoElement element;

  VideoBlock({
    required context,
    required this.element,
    required super.editController,
  }) : super(context: context) {
    readImageId();
  }

  void readImageId() async {
    element.file = await editController.fileManager.getImageFile(element.id);
    relayoutFlag = true;
    editController.updateWidgetState();
  }

  double calcIndentWidth() {
    if (calcAlignment() == Alignment.topLeft) {
      var width = indentWidth * (element.indent ?? 0);
      if (width > max(0, this.width - imageWidth - padding * 2)) {
        return max(0, this.width - imageWidth - padding * 2);
      }
      return width;
    }
    return 0;
  }

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
        children: [],
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
      return element.copy();
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
    return length - len;
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
    var alignment = calcAlignment();
    var offset = calcAlignmentOffset(
        Size(imageWidth + padding * 2, imageHeight + padding * 2), alignment);
    offset = offset.translate(calcIndentWidth(), 0);
    if (start == 0 && end == 1) {
      return [
        TextBox.fromLTRBD(offset.dx + padding, offset.dy + padding, imageWidth,
            imageHeight, TextDirection.ltr)
      ];
    }
    return [];
  }

  @override
  Rect? getCursorRect(TextPosition textPosition) {
    var alignment = calcAlignment();
    var offset = calcAlignmentOffset(
        Size(imageWidth + padding * 2, imageHeight + padding * 2), alignment);
    offset = offset.translate(calcIndentWidth(), 0);
    if (delete || textPosition.offset == 0) {
      return Rect.fromLTWH(
          offset.dx + padding - 1, offset.dy + padding, 1, imageHeight);
    } else {
      return Rect.fromLTWH(imageWidth + offset.dx + padding - 1,
          offset.dy + padding, 1, imageHeight);
    }
  }

  @override
  TextRange? getWordBoundary(TextPosition textPosition) {
    return const TextRange(start: 0, end: 1);
  }

  @override
  TextPosition? getPositionForOffset(Offset offset) {
    var alignment = calcAlignment();
    var calcOffset = calcAlignmentOffset(
        Size(imageWidth + padding * 2, imageHeight + padding * 2), alignment);
    calcOffset = calcOffset.translate(calcIndentWidth(), 0);

    if (delete || offset.dx <= calcOffset.dx + imageWidth / 2) {
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
    var mq = MediaQuery.of(context);
    var ratio = mq.devicePixelRatio;
    if (ratio <= 0) {
      ratio = 1;
    }
    var w = element.width;
    var h = element.height;
    var viewMaxImageHeight = (viewSize.width - padding * 2) * h / w;
    // var windowMaxImageHeight = ui.window.physicalSize.height / ratio * 0.6;
    var maxImageHeight = viewMaxImageHeight;
    var imageHeight = h / ratio;
    if (imageHeight < maxImageHeight) {
      height = imageHeight + padding * 2;
    } else {
      imageHeight = maxImageHeight;
      height = maxImageHeight + padding * 2;
    }

    this.imageHeight = imageHeight;
    imageWidth = imageHeight * w / h;
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
