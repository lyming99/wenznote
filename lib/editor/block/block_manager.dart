import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wenznote/editor/block/code/code.dart';
import 'package:wenznote/editor/block/element/element.dart';
import 'package:wenznote/editor/block/image/image_block.dart';
import 'package:wenznote/editor/block/image/image_element.dart';
import 'package:wenznote/editor/block/line/line_block.dart';
import 'package:wenznote/editor/block/line/line_element.dart';
import 'package:wenznote/editor/block/table/table_block.dart';
import 'package:wenznote/editor/cursor/cursor.dart';
import 'package:wenznote/editor/edit_controller.dart';
import 'package:wenznote/editor/proto/note.pb.dart';

import 'block.dart';
import 'table/table_element.dart';
import 'text/text.dart';
import 'text/title.dart';
import 'undo_stack.dart';

class BlockManager {
  List<WenBlock> blocks = [];
  List<WenBlock> layoutBlocks = [];
  Size? layoutSize;
  double? layoutOffset;
  bool relayoutFlag = false;
  double divideWidth = 10;
  ChangeStack changeStack = ChangeStack(limit: 1000, content: []);
  Map<String, dynamic>? _undoRecordState;

  double get height {
    double sum = 0;
    for (var value in blocks) {
      sum += value.height + divideWidth;
    }
    return sum - (sum > 0 ? divideWidth : 0);
  }

  int get textLength {
    int len = 0;
    for (var e in blocks) {
      len += e.length;
    }
    return len;
  }

  bool get canUndo => changeStack.canUndo;

  bool get canRedo => changeStack.canRedo;

  bool get isEmpty =>
      blocks.isEmpty || blocks.length == 1 && blocks.first.isEmpty;

  ///采用json格式解析
  void parseContent(BuildContext context, EditController editController) {
    var blocks = <WenBlock>[];
    var jsonArr = changeStack.content;
    for (var json in List.of(jsonArr)) {
      var element = WenElement.parseJson(json as Map<String, dynamic>);
      if (element is WenTextElement) {
        if (element.level == 0) {
          blocks.add(TextBlock(
            textElement: element,
            context: editController.viewContext,
            editController: editController,
          ));
        } else {
          blocks.add(TitleBlock(
            context: context,
            textElement: element,
            editController: editController,
          ));
        }
      } else if (element is WenImageElement) {
        blocks.add(ImageBlock(
          element: element,
          context: context,
          editController: editController,
        ));
      } else if (element is WenCodeElement) {
        blocks.add(CodeBlock(
            editController: editController,
            context: context,
            element: element));
      } else if (element is WenTableElement) {
        blocks.add(
          TableBlock(
            editController: editController,
            context: context,
            tableElement: element,
          ),
        );
      } else if (element is LineElement) {
        blocks.add(
          LineBlock(
            context: context,
            element: element,
            editController: editController,
          ),
        );
      }
    }
    if (blocks.isEmpty) {
      blocks.add(TitleBlock(
        editController: editController,
        context: context,
        textElement: WenTextElement(
          level: 1,
          text: "",
        ),
      ));
    }
    setBlocks(blocks);
  }

  void setBlocks(List<WenBlock> blocks) {
    double offset = 0;
    for (var block in blocks) {
      block.top = offset;
      offset += block.height + divideWidth;
    }
    this.blocks = blocks;
  }

  int indexOfBlock(double offset) {
    if (blocks.isEmpty) {
      return 0;
    }
    if (offset <= blocks.first.top) {
      return 0;
    }
    if (offset >= blocks.last.top) {
      return blocks.length - 1;
    }
    if (offset >= height) {
      return blocks.length - 1;
    }
    int left = 0;
    int right = blocks.length - 1;
    while (left <= right) {
      int mid = (left + right) ~/ 2;
      var block = blocks[mid];
      if (offset < block.top - divideWidth / 2) {
        right = mid - 1;
      } else if (offset > block.top + block.height + divideWidth / 2) {
        left = mid + 1;
      } else {
        return mid;
      }
    }
    return 0;
  }

  List<WenBlock> layout(
      BuildContext context, double offset, Size size, EdgeInsets padding) {
    try {
      if (relayoutFlag == false &&
          offset == layoutOffset &&
          size == layoutSize) {
        return layoutBlocks;
      }
      relayoutFlag = true;
      var index = indexOfBlock(offset - padding.top);
      if (index == -1) {
        layoutBlocks = [];
        return layoutBlocks;
      }
      // 注意：layout和parse content的冲突要解决，不能在parse content的同时进行layout
      //查找第一个出现在界面中的block：后期可以改造为二分法查找
      int first = index;
      //对显示出来的block进行重新布局
      double off = blocks[first].top;
      int end = first + 1;
      for (var i = first; i < blocks.length; i++) {
        var block = blocks[i];
        block.top = off;
        block.layout(context, size);
        off += block.height + divideWidth;
        end = i + 1;
        if (off > offset + size.height + padding.bottom) {
          break;
        }
      }
      //重新计算高度和偏差
      if (end < blocks.length && blocks[end].top != off) {
        for (var i = end; i < blocks.length; i++) {
          blocks[i].top = off;
          off += blocks[i].height + divideWidth;
        }
      }

      layoutBlocks = blocks.sublist(first, end);
      return layoutBlocks;
    } catch (e) {
      return layoutBlocks;
    }
  }

  //对一个block进行重新布局计算size，重置之后的block的y
  void layoutOneBlock(BuildContext context, WenBlock block, Size viewSize) {
    int index = indexOfBlockByBlock(block);
    if (index == -1) return;
    layoutBlockRange(context, index, index, viewSize);
  }

  void layoutBlockRange(
      BuildContext context, int startIndex, int endIndex, Size viewSize) {
    if (startIndex < 0 || startIndex >= blocks.length) return;
    var block = blocks[startIndex];
    double y = block.top;
    for (int i = startIndex; i < blocks.length; i++) {
      blocks[i].top = y;
      if (i >= startIndex && i <= endIndex) {
        blocks[i].layout(context, viewSize);
      }
      y += blocks[i].height + divideWidth;
    }
  }

  void layoutPreviousBlockWithHeight(
      BuildContext context, Size visionSize, int index, double height) {
    WenBlock anchorBlock = blocks[index];
    anchorBlock.layout(context, visionSize);
    double heightCount = 0;
    int currentIndex = index;
    for (var i = index - 1; i >= 0; i--) {
      var item = blocks[i];
      item.layout(context, visionSize);
      currentIndex = i;
      heightCount += item.top;
      currentIndex = i;
      if (heightCount > height) {
        break;
      }
    }
    double offset = blocks[currentIndex].top;
    for (var i = currentIndex; i < blocks.length; i++) {
      blocks[i].top = offset;
      offset += blocks[i].height + divideWidth;
    }
  }

  void layoutNextBlockWithHeight(
      BuildContext context, Size visionSize, int index, double height) {
    WenBlock anchorBlock = blocks[index];
    anchorBlock.layout(context, visionSize);
    double heightCount = 0;
    int currentIndex = index;
    for (var i = index + 1; i < blocks.length; i++) {
      var item = blocks[i];
      item.layout(context, visionSize);
      currentIndex = i;
      heightCount += item.top;
      currentIndex = i;
      if (heightCount > height) {
        break;
      }
    }
    double offset = blocks[currentIndex].top;
    for (var i = currentIndex; i < blocks.length; i++) {
      blocks[i].top = offset;
      offset += blocks[i].height + divideWidth;
    }
  }

  int indexOfBlockByBlock(WenBlock block) {
    return indexOfBlock(block.top + block.height / 2);
  }

  WenBlock? getBlockByOffset(double offset) {
    if (layoutBlocks.isEmpty) {
      return null;
    }
    // if (offset <= layoutBlocks[0].top) {
    //   return layoutBlocks[0];
    // }
    // if (offset >= layoutBlocks.last.top) {
    //   return layoutBlocks.last;
    // }
    var index = indexOfBlock(offset);
    if (index == -1) {
      return null;
    }
    return blocks[index];
  }

  int getValidIndex(index) {
    int n = blocks.length;
    if (index >= n) {
      index = n - 1;
    }
    if (index < 0) {
      index = 0;
    }
    return index;
  }

  List<dynamic> getSaveContentJson() {
    return blocks.map((e) {
      return e.element.calcJson();
    }).toList();
  }
  List<WenElement> getWenElements() {
    return blocks.map((e) {
      return e.element;
    }).toList();
  }

  Map<String, dynamic> _getEditState(EditController controller, bool old) {
    var positions = controller.cursorRecord.cursorPositionStack;
    CursorPosition? newPosition;
    CursorPosition? oldPosition;
    if (positions.isNotEmpty) {
      newPosition = positions.removeLast();
    }
    if (positions.isNotEmpty) {
      oldPosition = positions.last;
    }
    if (newPosition != null) {
      positions.addLast(newPosition);
    }
    oldPosition ??= newPosition;
    return {
      if (!old) "newBlockVisionTop": newPosition?.blockVisionTop,
      if (!old) "newCursorBlockIndex": newPosition?.blockIndex,
      if (!old) "newCursorPosition": newPosition?.textPosition,
      if (old) "oldBlockVisionTop": oldPosition?.blockVisionTop,
      if (old) "oldCursorBlockIndex": oldPosition?.blockIndex,
      if (old) "oldCursorPosition": oldPosition?.textPosition,
    };
  }

  void record(EditController controller) {
    _undoRecordState ??= _getEditState(controller, true);
    _record(controller);
  }

  void onContentChanged(EditController controller) {
    controller.onContentChanged?.call();
  }

  NoteDom getSaveDom() {
    var elements = blocks.map((e) => e.element).map((e) {
      return e.toNoteElement();
    }).toList();
    return NoteDom(
      elements: elements,
    );
  }

  Future<void> _record(EditController controller) async {
    var startState = _undoRecordState;
    _undoRecordState = null;
    var endState = _getEditState(controller, false);
    endState.addAll(startState ?? {});
    var jsonContent = getSaveContentJson();
    controller.writer?.call(jsonContent);
    changeStack.record(
      jsonContent,
      attributes: endState,
    );
    onContentChanged(controller);
    print('text length:${textLength} block size:${blocks.length}');
  }

  void undo(EditController controller) {
    var change = changeStack.undo();
    if (change != null) {
      parseContent(controller.viewContext, controller);
      var attr = change.attributes;
      if (attr != null) {
        restoreCursorState(
          controller,
          blockVisionTop: attr["oldBlockVisionTop"],
          cursorBlockIndex: attr["oldCursorBlockIndex"],
          cursorPosition: attr["oldCursorPosition"],
        );
      }
    }
    onContentChanged(controller);
    controller.updateWidgetState();
    var jsonContent = getSaveContentJson();
    controller.writer?.call(jsonContent);
  }

  void redo(EditController controller) {
    var change = changeStack.redo();
    if (change != null) {
      parseContent(controller.viewContext, controller);
      var attr = change.attributes;
      if (attr != null) {
        restoreCursorState(
          controller,
          blockVisionTop: attr["newBlockVisionTop"],
          cursorBlockIndex: attr["newCursorBlockIndex"],
          cursorPosition: attr["newCursorPosition"],
        );
      }
    }
    onContentChanged(controller);
    controller.updateWidgetState();
    var jsonContent = getSaveContentJson();
    controller.writer?.call(jsonContent);
  }

  void restoreCursorState(
    EditController controller, {
    double? blockVisionTop,
    int? cursorBlockIndex,
    TextPosition? cursorPosition,
  }) {
    if (cursorBlockIndex != null && blockVisionTop != null) {
      layoutPreviousBlockWithHeight(
          controller.viewContext,
          Size(controller.visionWidth, controller.visionHeight),
          cursorBlockIndex,
          controller.visionHeight);
      var pos = blocks[cursorBlockIndex].top - blockVisionTop;
      controller.scrollVertical(pos - controller.scrollOffset);
      if (cursorPosition != null) {
        var position =
            blocks[cursorBlockIndex].getCursorPosition(cursorPosition);
        controller.toPosition(position, true);
      }
    }
  }
}

WenBlock createWenBlock(
    BuildContext context, EditController editController, WenElement element) {
  if (element is WenTextElement) {
    if (element.level == 0) {
      return TextBlock(
        textElement: element,
        context: context,
        editController: editController,
      );
    } else {
      return TitleBlock(
        context: context,
        textElement: element,
        editController: editController,
      );
    }
  }
  if (element is WenImageElement) {
    return ImageBlock(
      element: element,
      context: context,
      editController: editController,
    );
  }
  if (element is WenCodeElement) {
    return CodeBlock(
        editController: editController, context: context, element: element);
  }
  if (element is WenTableElement) {
    return TableBlock(
      editController: editController,
      context: context,
      tableElement: element,
    );
  }
  if (element is LineElement) {
    return LineBlock(
      context: context,
      element: element,
      editController: editController,
    );
  }
  return TextBlock(
      context: context,
      editController: editController,
      textElement: WenTextElement());
}
