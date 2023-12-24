import 'dart:math';

import 'package:flutter_crdt/flutter_crdt.dart';
import 'package:note/editor/block/block.dart';
import 'package:note/editor/crdt/YsBlock.dart';
import 'package:note/editor/crdt/YsCursor.dart';
import 'package:note/editor/crdt/YsSelection.dart';

import 'YsText.dart';

class YsCode {
  YsBlock block;

  YsCode.of(this.block);

  void enter() {
    var cursor = block.tree.cursor;
    if (cursor == null) {
      return;
    }
    var blockIndex = cursor.getBlockIndex();
    if (blockIndex == null) {
      return;
    }
    var textOffset = cursor.getTextOffset();
    if (textOffset == null) {
      return;
    }
    var map = block.yMap;
    var code = map.get("code");
    if (code is! YText) {
      return;
    }
    code.insert(textOffset, '\n');
    var newCursor = createCodeCursor(block.tree, blockIndex, textOffset + 1);
    block.tree.setCursor(newCursor);
  }

  void deleteCursor(bool backspace) {
    block.tree.transact((transaction) {
      if (backspace == false) {
        //删右
        deleteCursorToRight();
      } else {
        //删左
        deleteCursorToLeft();
      }
    });
  }

  void deleteCursorToLeft() {
    var cursor = block.tree.cursor;
    if (cursor == null) {
      return;
    }
    var textOffset = cursor.getTextOffset();
    if (textOffset == null) {
      return;
    }
    var blockIndex = cursor.getBlockIndex();
    if (blockIndex == null) {
      return;
    }
    var code = block.yMap.get("code");
    if (code is! YText) {
      return;
    }
    //1.为空，则转换为 text
    if (code.length == 0) {
      block.tree.deleteYsBlocks(blockIndex, 1);
      block.tree.insertYsBlocks(blockIndex, [createEmptyTextYMap()]);
      block.tree.setCursor(createBlockCursor(block.tree, blockIndex, 0));
      return;
    }
    //2.在开头，全部选择代码
    if (textOffset == 0) {
      var selection = YsSelection();
      selection.start = createBlockCursor(block.tree, blockIndex, 0);
      selection.end = YsCursor.end(block.tree, blockIndex);
      block.tree.setSelection(selection);
      return;
    }
    //3.不在开头，删除文字即可
    code.delete(textOffset - 1, 1);
    block.tree
        .setCursor(createBlockCursor(block.tree, blockIndex, textOffset - 1));
  }

  void deleteCursorToRight() {
    var cursor = block.tree.cursor;
    if (cursor == null) {
      return;
    }
    var textOffset = cursor.getTextOffset();
    if (textOffset == null) {
      return;
    }
    var blockIndex = cursor.getBlockIndex();
    if (blockIndex == null) {
      return;
    }
    var code = block.yMap.get("code");
    if (code is! YText) {
      return;
    }
    //1.为空，则转换为 text
    if (code.length == 0) {
      block.tree.deleteYsBlocks(blockIndex, 1);
      block.tree.insertYsBlocks(blockIndex, [createEmptyTextYMap()]);
      block.tree.setCursor(createBlockCursor(block.tree, blockIndex, 0));
      return;
    }
    //2.在结尾，全部选择代码
    if (textOffset == code.length) {
      var selection = YsSelection();
      selection.start = createBlockCursor(block.tree, blockIndex, 0);
      selection.end = YsCursor.end(block.tree, blockIndex);
      block.tree.setSelection(selection);
      return;
    }
    //3.不在结尾，删除文字即可
    code.delete(textOffset, 1);
  }

  void insertContent(List<WenBlock> content) {
    var cursor = block.tree.cursor;
    if (cursor == null) {
      return;
    }
    var textOffset = cursor.getTextOffset();
    if (textOffset == null) {
      return;
    }
    var blockIndex = cursor.getBlockIndex();
    if (blockIndex == null) {
      return;
    }
    var code = block.yMap.get('code');
    if (code is! YText) {
      code = createYText();
      block.yMap.set('code', code);
    }
    StringBuffer sb = StringBuffer();
    for (var value in content) {
      var text = value.element.getText();
      sb.writeln(text);
    }
    code.insert(textOffset, sb.toString());
    block.tree.setCursor(
        createTextCursor(block.tree, blockIndex, textOffset + sb.length));
  }

  void addIndent({required int blockIndex}) {
    var code = block.yMap.get("code");
    if (code is! YText) {
      return;
    }
    int indentStartOffset = 0;
    int indentEndOffset = block.getLength();

    var cursor = block.tree.cursor;
    var cursorIndex = cursor?.getBlockIndex();
    bool cursorInBlock = cursorIndex == blockIndex;
    bool selectStartInBlock =
        block.tree.selection?.start?.getBlockIndex() == blockIndex;
    bool selectEndInBlock =
        block.tree.selection?.end?.getBlockIndex() == blockIndex;
    var selectStartOffset = block.tree.selection?.start?.getTextOffset() ?? 0;
    var selectEndOffset = block.tree.selection?.end?.getTextOffset() ?? 0;
    var blockLength = block.getLength();
    var hasSelect = block.tree.hasSelect;
    if (hasSelect) {
      var start = block.tree.selection!.start!;
      var end = block.tree.selection!.end!;
      var startBlockIndex = start.getBlockIndex() ?? 0;
      var endBlockIndex = end.getBlockIndex() ?? 0;
      if (blockIndex == startBlockIndex) {
        indentStartOffset = start.getTextOffset() ?? 0;
      }
      if (blockIndex == endBlockIndex) {
        indentEndOffset = end.getTextOffset() ?? indentEndOffset;
      }
    } else {
      indentStartOffset =
          indentEndOffset = block.tree.cursor?.getTextOffset() ?? 0;
      code.insert(indentStartOffset, "    ");
      block.tree.setCursor(
          YsCursor.code(block.tree, blockIndex, indentStartOffset + 4));
      return;
    }
    bool cursorIsStart = cursor?.getTextOffset() == indentStartOffset &&
        cursor?.getBlockIndex() == blockIndex;
    // add indent
    var text = code.toString();
    int lineIndex = text.lastIndexOf("\n", max(0, indentStartOffset - 1));
    if (lineIndex == -1) {
      lineIndex = 0;
    } else {
      lineIndex++;
    }
    var insertIndexes = [lineIndex];
    while (lineIndex != -1) {
      lineIndex = text.indexOf("\n", lineIndex);
      if (lineIndex == -1 || lineIndex >= indentEndOffset) {
        break;
      }
      lineIndex++;
      insertIndexes.add(lineIndex);
    }
    for (var index in insertIndexes.reversed) {
      code.insert(index, "    ");
    }
    selectStartOffset += 4;
    selectEndOffset += block.getLength() - blockLength;
    if (cursorInBlock) {
      if (cursorIsStart) {
        block.tree.setCursor(
            YsCursor.code(block.tree, blockIndex, selectStartOffset));
      } else {
        block.tree
            .setCursor(YsCursor.code(block.tree, blockIndex, selectEndOffset));
      }
    }
    if (selectStartInBlock) {
      block.tree.selection?.start =
          (YsCursor.code(block.tree, blockIndex, selectStartOffset));
    }
    if (selectEndInBlock) {
      block.tree.selection?.end =
          (YsCursor.code(block.tree, blockIndex, selectEndOffset));
    }
  }

  void removeIndent({required int blockIndex}) {
    var code = block.yMap.get("code");
    if (code is! YText) {
      return;
    }
    int indentStartOffset = 0;
    int indentEndOffset = block.getLength();
    var cursor = block.tree.cursor;
    var cursorIndex = cursor?.getBlockIndex();
    bool cursorInBlock = cursorIndex == blockIndex;
    var blockLength = block.getLength();
    bool selectStartInBlock =
        block.tree.selection?.start?.getBlockIndex() == blockIndex;
    bool selectEndInBlock =
        block.tree.selection?.end?.getBlockIndex() == blockIndex;
    var hasSelect = block.tree.hasSelect;
    var selectStartOffset = block.tree.selection?.start?.getTextOffset() ??
        cursor?.getTextOffset() ??
        0;
    var selectEndOffset = block.tree.selection?.end?.getTextOffset() ??
        cursor?.getTextOffset() ??
        0;
    //计算select开始位置和结束位置
    if (hasSelect) {
      var start = block.tree.selection!.start!;
      var end = block.tree.selection!.end!;
      var startBlockIndex = start.getBlockIndex() ?? 0;
      var endBlockIndex = end.getBlockIndex() ?? 0;
      if (blockIndex == startBlockIndex) {
        indentStartOffset = start.getTextOffset() ?? 0;
      }
      if (blockIndex == endBlockIndex) {
        indentEndOffset = end.getTextOffset() ?? indentEndOffset;
      }
    } else {
      indentStartOffset =
          indentEndOffset = block.tree.cursor?.getTextOffset() ?? 0;
    }
    bool cursorIsStart =
        selectStartInBlock && cursor?.getTextOffset() == selectStartOffset;
    var text = code.toString();
    int lineIndex = text.lastIndexOf("\n", max(0, indentStartOffset - 1));
    if (lineIndex == -1) {
      lineIndex = 0;
    } else {
      lineIndex++;
    }
    // remove indent
    var insertIndexes = [lineIndex];
    while (lineIndex != -1) {
      lineIndex = text.indexOf("\n", lineIndex);
      if (lineIndex == -1 || lineIndex >= indentEndOffset) {
        break;
      }
      lineIndex++;
      insertIndexes.add(lineIndex);
    }
    int deleteCount = 0;
    for (var index in insertIndexes.reversed) {
      deleteCount = 0;
      for (var i = index; i < index + 4 && i < text.length; i++) {
        if (text[i] == " ") {
          deleteCount++;
        } else {
          break;
        }
      }
      code.delete(index, deleteCount);
    }
    selectStartOffset -= deleteCount;
    selectEndOffset += block.getLength() - blockLength;
    if (cursorInBlock) {
      if (hasSelect) {
        if (cursorIsStart) {
          block.tree.setCursor(
              YsCursor.code(block.tree, blockIndex, selectStartOffset));
        } else {
          block.tree.setCursor(
              YsCursor.code(block.tree, blockIndex, selectEndOffset));
        }
      } else {
        block.tree.setCursor(
            YsCursor.code(block.tree, blockIndex, selectStartOffset));
      }
    }
    if (selectStartInBlock) {
      block.tree.selection?.start =
          (YsCursor.code(block.tree, blockIndex, selectStartOffset));
    }
    if (selectEndInBlock) {
      block.tree.selection?.end =
          (YsCursor.code(block.tree, blockIndex, selectEndOffset));
    }
  }
}
