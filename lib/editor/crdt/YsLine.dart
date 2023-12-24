import 'package:note/editor/block/block.dart';
import 'package:note/editor/crdt/YsBlock.dart';
import 'package:note/editor/crdt/YsImage.dart';

import 'YsCursor.dart';
import 'YsText.dart';

class YsLine {
  YsBlock block;

  YsLine.of(this.block);

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
    //光标在0和在1都可以删除
    //转换成text
    // 1.删除block
    block.tree.deleteYsBlocks(blockIndex, 1);
    // 2.插入text empty
    block.tree.insertYsBlocks(blockIndex, [createEmptyTextYMap()]);
    // 3.设置光标为index0
    block.tree.setCursor(createBlockCursor(block.tree, blockIndex, 0));
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
    //光标在0和在1都可以删除
    //转换成text
    // 1.删除block
    block.tree.deleteYsBlocks(blockIndex, 1);
    // 2.插入text empty
    block.tree.insertYsBlocks(blockIndex, [createEmptyTextYMap()]);
    // 3.设置光标为index0
    block.tree.setCursor(createBlockCursor(block.tree, blockIndex, 0));
  }

  void insertContent(List<WenBlock> content) {
    YsImage.of(block).insertContent(content);
  }
}
