import 'dart:convert';

import 'package:flutter_crdt/flutter_crdt.dart';
import 'package:note/editor/block/block.dart';
import 'package:note/editor/block/element/element.dart';
import 'package:note/editor/crdt/YsBlock.dart';
import 'package:note/editor/crdt/YsCursor.dart';

import 'YsTree.dart';

int getYsTextLength(YMap map) {
  var text = map.get("text");
  if (text == null) {
    return 0;
  }
  if (text is YText) {
    return text.length;
  }
  return 0;
}

int getYsCodeTextLength(YMap map) {
  var text = map.get("code");
  if (text == null) {
    return 0;
  }
  if (text is YText) {
    return text.length;
  }
  return 0;
}

YMap createEmptyTextYMap([YMap? style]) {
  var indent = style?.get("indent");
  var itemType = style?.get("itemType");
  var type = style?.get("type");
  if (type != "quote") {
    type = "text";
  }
  var map = YMap();
  map.set("level", 0);
  map.set("type", type);
  map.set("text", createYText());
  if (indent != null) {
    map.set("indent", indent);
  }
  if (itemType != null) {
    map.set("itemType", itemType);
  }
  return map;
}

YMap createYMap() {
  var map = YMap();
  return map;
}

YArray createYArray(Object doc) {
  var map = YArray.create();
  return map;
}

YText createYText() {
  var map = YText.create();
  return map;
}

bool isYsText(YMap? map) {
  var type = map?.get("type");
  return type == 'text' || type == 'quote' || type == 'title';
}

int insertYsText(YMap origin, int offset, YMap content) {
  var contentText = content.get('text');
  if (contentText is! YText) {
    return 0;
  }
  var originText = origin.get('text');
  if (originText is! YText) {
    return 0;
  }
  return insertYText(originText, offset, contentText);
}

int insertYText(YText origin, int offset, YText content) {
  if (content.doc == null) {
    content.innerIntegrate(Doc(), null);
  }
  var deltas = content.toDelta();
  int pos = offset;
  for (var op in deltas) {
    // value: {insert,attributes}
    var insert = op['insert'];
    var attributes = op['attributes'];
    if (insert is String) {
      if (attributes is Map) {
        var attr = <String, dynamic>{};
        for (var entry in attributes.entries) {
          attr[entry.key] = entry.value;
        }
        origin.insert(pos, insert, attr);
      } else {
        origin.insert(pos, insert);
      }
      pos += insert.length;
    } else {
      origin.insertEmbed(pos, insert as Map<String, dynamic>);
      pos += 1;
    }
  }
  return pos - offset;
}

class YsText {
  YsBlock block;

  YsText.of(this.block);

  YMap split(int offset) {
    var text = block.yMap.get("text");
    if (text is! YText) {
      return createEmptyTextYMap();
    }
    int pos = 0;
    var deltas = text.toDelta();
    var newDeltas = <Map<String, Object?>>[];
    for (var op in deltas) {
      // value: {insert,attributes}
      var insert = op['insert'];
      var attributes = op['attributes'];
      if (insert is String) {
        if (offset - pos >= 0 && offset - pos < insert.length) {
          newDeltas.add({
            'insert': insert.substring(offset - pos),
            'attributes': attributes
          });
        }
        pos += insert.length;
      } else {
        if (pos >= offset) {
          newDeltas.add({'insert': insert, 'attributes': attributes});
        }
        pos += 1;
      }
    }
    var result = createYMap();
    var newText = createYText()..applyDelta(newDeltas);
    for (var attr in block.yMap.entries()) {
      var key = attr.key;
      if (key == 'text') {
        continue;
      }
      result.set(key, attr.value);
    }
    result.set('text', newText);
    return result;
  }

  void mergeText(YMap yMap) {
    var text = yMap.get("text");
    if (text is! YText) {
      return;
    }
    var curText = block.yMap.get('text');
    if (curText is! YText) {
      return;
    }
    var deltas = text.toDelta();
    for (var op in deltas) {
      // value: {insert,attributes}
      var insert = op['insert'];
      var attributes = op['attributes'];
      if (insert is String) {
        if (attributes != null) {
          try {
            curText.insert(
                curText.length, insert, attributes as Map<String, Object?>);
          } catch (e) {
            curText.insert(curText.length, insert,
                jsonDecode(jsonEncode(attributes)) as Map<String, Object?>);
          }
        } else {
          curText.insert(curText.length, insert);
        }
      } else {
        curText.insertEmbed(curText.length, insert as Map<String, dynamic>);
      }
    }
  }

  void delete(int offset, [int length = 1]) {
    var text = block.yMap.get("text");
    if (text is! YText) {
      return;
    }
    text.delete(offset, length);
  }

  void deleteToEnd(int offset) {
    var text = block.yMap.get("text");
    if (text is! YText) {
      return;
    }
    text.delete(offset, text.length - offset);
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
    if (textOffset == 0) {
      //为首
      var textLength = getYsTextLength(block.yMap);
      if (textLength == 0) {
        //为首并且为空，如果样式部位默认，则清除样式；否则删除block
        if (clearEmptyStyle(blockIndex: blockIndex, reason: "deleteToLeft")) {
          return;
        }
        if (blockIndex > 0) {
          block.tree.deleteYsBlocks(blockIndex, 1);
          block.tree.setCursor(YsCursor.end(block.tree, blockIndex - 1));
        }
      } else {
        //为首并且不为空
        if (blockIndex > 0) {
          var preBlock = block.tree.blocks[blockIndex - 1];
          if (preBlock.isText) {
            var position = getYsTextLength(preBlock.yMap);
            //合并到前一block
            YsText.of(preBlock).mergeText(block.yMap);
            //删除此block
            block.tree.deleteYsBlocks(blockIndex, 1);
            block.tree.setCursor(
                createTextCursor(block.tree, blockIndex - 1, position));
          } else {
            //跳到前一block尾部
            var newCursor = YsCursor.end(block.tree, blockIndex - 1);
            block.tree.setCursor(newCursor);
          }
        }
      }
    } else {
      //不为首,删除字符，光标迁移
      delete(textOffset - 1);
      var newCursor = createTextCursor(block.tree, blockIndex, textOffset - 1);
      block.tree.setCursor(newCursor);
    }
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
    var textLength = getYsTextLength(block.yMap);
    if (textOffset == textLength) {
      //光标为尾
      if (blockIndex >= block.tree.blocks.length - 1) {
        //文章尾部删除右边无效
        return;
      }
      //1.如果下一个block也为text，则合并
      var nextBlock = block.tree.blocks[blockIndex + 1];
      if (nextBlock.isText) {
        //合并text
        mergeText(nextBlock.yMap);
        //删除此block
        block.tree.deleteYsBlocks(blockIndex + 1, 1);
        block.tree.setCursor(YsCursor.text(block.tree, blockIndex, textLength));
        return;
      }
      //2.如果文字为空，则清除样式，如果样式为空，则删除
      if (textLength == 0) {
        //为空，如果样式部位默认，则清除样式；否则删除block
        if (clearEmptyStyle(
          blockIndex: blockIndex,
          reason: "deleteToRight",
        )) {
          return;
        }
        if (blockIndex > 0) {
          block.tree.deleteYsBlocks(blockIndex, 1);
          block.tree.setCursor(createBlockCursor(block.tree, blockIndex, 0));
        }
      }
      //3.文字为空，无需多余操作，因为无法将text和其它block合并
    } else {
      //光标非尾
      delete(textOffset);
    }
  }

  /// 当删除一段空文字时，需要判断文字是否具有缩进、对齐方式、项目符号属性
  bool clearEmptyStyle({
    required int blockIndex,
    required String reason,
  }) {
    if (getYsTextLength(block.yMap) > 0) {
      return false;
    }
    if (reason == "deleteToLeft") {
      // 前删，需要判断前面的样式，如果相同，则不需要clearStyle
      if (blockIndex == 0) {
        // 删除itemType
        if (itemType != null) {
          block.yMap.delete("itemType");
          return true;
        }
        if (block.yMap.get("type") == "quote") {
          block.yMap.set("type", "text");
          return true;
        }
        return false;
      }
      var preBlock = block.tree.blocks[blockIndex - 1];
      // 删除itemType
      if (itemType != null) {
        block.yMap.delete("itemType");
        return true;
      }
      // 删除type
      if (block.yMap.get("type") == "quote") {
        //前一个为quote，则直接删除跳到前面
        if (preBlock.yMap.get("type") == "quote") {
          return false;
        }
        block.yMap.set("type", "text");
        return true;
      }
    }
    if (reason == "deleteToRight") {
      // 直接删除，将内容合并到前面
      return false;
    }
    if (reason == "enter") {
      //删除itemType
      if (itemType != null) {
        block.yMap.delete("itemType");
        return true;
      }
      if (block.blockType != "quote") {
        return false;
      }
      bool nextIsQuote = false;
      if (blockIndex + 1 < block.tree.blocks.length) {
        var nextBlock = block.tree.blocks[blockIndex + 1];
        nextIsQuote = (nextBlock.blockType == "quote");
      }
      if (nextIsQuote) {
        return false;
      }
      //删除type
      block.yMap.set("type", "text");
      return true;
    }
    return false;
  }

  int get level {
    var map = block.yMap;
    var level = map.get("level");
    if (level is int) {
      return level;
    }
    return 0;
  }

  String? get itemType {
    return block.yMap.get("itemType");
  }

  void insertContent(List<WenBlock> content) {
    var cursor = block.tree.cursor;
    if (cursor == null) {
      return;
    }
    var blockIndex = cursor.getBlockIndex();
    if (blockIndex == null) {
      return;
    }
    var textPos = cursor.getTextOffset();
    if (textPos == null) {
      return;
    }
    var maps = content.map((e) => e.element.getYMap()).toList();
    if (maps.isEmpty) {
      return;
    }
    var textLength = getYsTextLength(block.yMap);
    // 1.[i]
    if (textLength == 0) {
      block.tree.replaceYsBlock(blockIndex, 1, maps);
      var cursorBlockIndex = blockIndex + maps.length - 1;
      block.tree.setCursor(YsCursor.end(block.tree, cursorBlockIndex));
      return;
    }
    // 2.[i]abc
    if (textPos == 0) {
      var last = maps.last;
      if (isYsText(last)) {
        var cursorTextPos = getYsTextLength(last);
        var cursorBlockIndex = blockIndex + maps.length - 1;
        maps.removeLast();
        block.tree.replaceYsBlock(blockIndex, 0, maps);
        insertYsText(block.yMap, 0, last);
        block.tree.setCursor(
            createTextCursor(block.tree, cursorBlockIndex, cursorTextPos));
      } else {
        block.tree.replaceYsBlock(blockIndex, 1, maps);
        var cursorBlockIndex = blockIndex + maps.length - 1;
        block.tree.setCursor(YsCursor.end(block.tree, cursorBlockIndex));
      }
      return;
    }
    // 3.abc[i]
    if (textPos == textLength) {
      var first = maps.first;
      if (isYsText(first)) {
        maps.removeAt(0);
        insertYsText(block.yMap, getYsTextLength(block.yMap), first);
        block.tree.replaceYsBlock(blockIndex + 1, 0, maps);
        var cursorBlockIndex = blockIndex + maps.length;
        block.tree.setCursor(YsCursor.end(block.tree, cursorBlockIndex));
      } else {
        block.tree.replaceYsBlock(blockIndex + 1, 0, maps);
        var cursorBlockIndex = blockIndex + maps.length;
        block.tree.setCursor(YsCursor.end(block.tree, cursorBlockIndex));
      }
      return;
    }
    // 4.a[i]bc
    if (textPos > 0 && textPos < textLength) {
      if (maps.length == 1) {
        YMap one = maps.first;
        if (isYsText(one)) {
          insertYsText(block.yMap, textPos, one);
          var cursorTextOffset = getYsTextLength(one) + textPos;
          block.tree.setCursor(
              createTextCursor(block.tree, blockIndex, cursorTextOffset));
        } else {
          var textSplit = split(textPos);
          deleteToEnd(textPos);
          maps.add(textSplit);
          block.tree.replaceYsBlock(blockIndex + 1, 0, maps);
          var cursorBlockIndex = blockIndex + 1;
          block.tree.setCursor(YsCursor.end(block.tree, cursorBlockIndex));
        }
      } else {
        var isMergeFirst = isYsText(maps.first);
        var isMergeLast = isYsText(maps.last);
        if (isMergeFirst && isMergeLast) {
          var cursorTextPos = getYsTextLength(maps.last);
          var textSplit = split(textPos);
          deleteToEnd(textPos);
          insertYsText(textSplit, 0, maps.last);
          insertYsText(block.yMap, getYsTextLength(block.yMap), maps.first);
          maps.removeLast();
          maps.add(textSplit);
          maps.removeAt(0);
          block.tree.replaceYsBlock(blockIndex + 1, 0, maps);
          block.tree.setCursor(createTextCursor(
              block.tree, blockIndex + maps.length, cursorTextPos));
        } else if (isMergeFirst) {
          var textSplit = split(textPos);
          deleteToEnd(textPos);
          // insert to first
          insertYsText(block.yMap, getYsTextLength(block.yMap), maps.first);
          maps.add(textSplit);
          block.tree.replaceYsBlock(blockIndex + 1, 0, maps);
          block.tree.setCursor(
              YsCursor.end(block.tree, blockIndex + maps.length - 1));
        } else if (isMergeLast) {
          var cursorTextPos = getYsTextLength(maps.last);
          var textSplit = split(textPos);
          deleteToEnd(textPos);
          // insert to last
          insertYsText(maps.last, 0, textSplit);
          block.tree.replaceYsBlock(blockIndex + 1, 0, maps);
          block.tree.setCursor(createTextCursor(
              block.tree, blockIndex + maps.length, cursorTextPos));
        } else {
          var textSplit = split(textPos);
          deleteToEnd(textPos);
          maps.add(textSplit);
          block.tree.replaceYsBlock(blockIndex + 1, 0, maps);
          block.tree.setCursor(
              YsCursor.end(block.tree, blockIndex + maps.length - 1));
        }
      }
    }
  }

  void setItemType(String itemType) {
    block.yMap.set("itemType", itemType);
  }

  void setAlignment(String? alignment) {
    block.yMap.set("alignment", alignment);
  }

  void setAttribute(SelectIndex selectBlockIndex, int curBlockIndex, String key,
      Object? value) {
    var startTextIndex = 0;
    var endTextIndex = getYsTextLength(block.yMap);
    if (curBlockIndex == selectBlockIndex.start) {
      startTextIndex =
          block.tree.selection?.start?.getTextOffset() ?? startTextIndex;
    }
    if (curBlockIndex == selectBlockIndex.end) {
      endTextIndex = block.tree.selection?.end?.getTextOffset() ?? endTextIndex;
    }
    var text = block.yMap.get("text");
    if (text is! YText) {
      return;
    }
    text.format(startTextIndex, endTextIndex - startTextIndex, {key: value});
  }

  void deleteAttribute(SelectIndex selectBlockIndex, int curBlockIndex) {
    var startTextIndex = 0;
    var endTextIndex = getYsTextLength(block.yMap);
    if (curBlockIndex == selectBlockIndex.start) {
      startTextIndex =
          block.tree.selection?.start?.getTextOffset() ?? startTextIndex;
    }
    if (curBlockIndex == selectBlockIndex.end) {
      endTextIndex = block.tree.selection?.end?.getTextOffset() ?? endTextIndex;
    }
    var text = block.yMap.get("text");
    if (text is! YText) {
      return;
    }
    text.format(startTextIndex, endTextIndex - startTextIndex, clearStyleMap);
  }

  void updateFormula(int offset, String formula) {
    block.tree.transact((transaction) {
      var text = block.yMap.get("text");
      if (text is YText) {
        text.delete(offset, 1);
        text.insertEmbed(offset, {
          "type": "text",
          "itemType": "formula",
          "text": formula,
        });
      }
      block.updateBlock();
    });
  }

  void updateChecked(bool? checked) {
    block.tree.transact((transaction) {
      block.yMap.set("checked", checked);
      block.updateBlock();
    });
  }
}
