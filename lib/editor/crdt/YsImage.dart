import 'package:note/editor/block/block.dart';
import 'package:note/editor/crdt/YsBlock.dart';
import 'package:note/editor/crdt/YsCursor.dart';
import 'package:note/editor/crdt/YsText.dart';

class YsImage {
  YsBlock block;

  YsImage.of(this.block);

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
    var maps = content.map((e) => e.element.getYMap()).toList();
    if (maps.isEmpty) {
      return;
    }
    if (textOffset == 0) {
      // 前面插入
      block.tree.insertYsBlocks(blockIndex, maps);
      YsCursor.end(block.tree, blockIndex + maps.length - 1);
    } else {
      // 后面插入
      block.tree.insertYsBlocks(blockIndex + 1, maps);
      YsCursor.end(block.tree, blockIndex + maps.length);
    }
  }

  void setAlignment(String? alignment) {
    block.yMap.set("alignment", alignment);
  }
}
