import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_crdt/flutter_crdt.dart';
import 'package:wenznote/editor/block/block.dart';
import 'package:wenznote/editor/block/code/code.dart';
import 'package:wenznote/editor/block/line/line_element.dart';
import 'package:wenznote/editor/block/table/image_cell.dart';
import 'package:wenznote/editor/block/table/table_block.dart';
import 'package:wenznote/editor/block/table/text_cell.dart';
import 'package:wenznote/editor/block/text/text.dart';
import 'package:wenznote/editor/crdt/YsCode.dart';
import 'package:wenznote/editor/crdt/YsImage.dart';
import 'package:wenznote/editor/crdt/YsLine.dart';
import 'package:wenznote/editor/cursor/cursor.dart';

import 'YsBlock.dart';
import 'YsCursor.dart';
import 'YsEditController.dart';
import 'YsItem.dart';
import 'YsSelection.dart';
import 'YsTable.dart';
import 'YsText.dart';

class YsTree {
  YsTree({
    required this.context,
    required this.editController,
    required this.yDoc,
  });

  var itemMap = <YMap, YsItem>{};
  var blocks = <YsBlock>[];
  Doc yDoc;
  YArray? yArray;
  YsEditController editController;
  BuildContext context;
  YsCursor? cursor;
  YsCursor? chagnedPosition;
  YsSelection? selection;
  UndoManager? undoManager;
  bool initOk = false;
  int changeClock = 0;

  void init() {
    yArray = yDoc.getArray("blocks");
    if (yArray!.isEmpty) {
      yArray!.insert(0, [createEmptyTextYMap()]);
    }
    undoManager = UndoManager([yArray!]);
    editController.initTree(this);
    initOk = true;
    buildBlocks();
    // blocks增删改差
    yArray!.observe((event, transaction) {
      // 在这里更新blocks
      buildBlocks();
    });
    if (editController.isEmpty) {
      editController.waitLayout(() {
        editController.requestFocus();
      });
    }
    yArray!.observeDeep((eventList, transaction) {
      int blockIndex = 0;
      var current = blocks.first;
      for (var i = 1; i < blocks.length; i++) {
        if (blocks[i].updateTime > current.updateTime) {
          current = blocks[i];
          blockIndex = i;
        }
      }
      var textOffset = 0;
      void getTextOffset() {
        for (var event in eventList) {
          for (var delta in event.delta) {
            var retain = delta["retain"];
            var insert = delta["insert"];
            if (retain is int) {
              textOffset = retain;
            }
            if (insert is String) {
              textOffset += insert.length;
            } else if (insert != null) {
              textOffset += 1;
            }
          }
        }
      }

      if (current.isText || current.blockType == 'code') {
        getTextOffset();
        chagnedPosition = YsCursor.create(this, blockIndex, textOffset);
      } else if (current.blockType == 'table') {
        int rowIndex = 0;
        int colIndex = 0;
        for (var event in eventList) {
          var target = event.target;
          // ymap变化
          if (current.yMap == target) {
            print('table property changed.');
          }
          //alignments属性变化
          if (current.yMap.get("alignments") == target) {
            print('table alignments changed.');
          }
          var rows = current.yMap.get("rows");
          int rowPos = 0;
          if (rows is YArray) {
            //行发生变化
            if (rows == target) {
              print('table rows changed.');
              rowIndex = rowPos;
            }
            //单元格变化
            for (var row in rows) {
              if (row == target) {
                print('table row changed.');
                rowIndex = rowPos;
              }
              int cellPos = 0;
              if (row is YArray) {
                for (var cell in row) {
                  if (cell == target) {
                    print('table cell property changed.');
                    colIndex = cellPos;
                    rowIndex = rowPos;
                  }
                  if (cell is YMap) {
                    var text = cell.get("text");
                    if (text == target) {
                      print('table cell text changed..');
                      colIndex = cellPos;
                      rowIndex = rowPos;
                      getTextOffset();
                    }
                  }
                  cellPos++;
                }
              }
            }
            rowPos++;
          }
        }
        chagnedPosition =
            YsCursor.table(this, blockIndex, rowIndex, colIndex, textOffset);
      } else {
        chagnedPosition = YsCursor.create(this, blockIndex, textOffset);
      }
    });
  }

  void transact(Function(dynamic transaction) t) {
    yDoc.transact(t);
  }

  void buildBlocks() {
    var buildBlocks = <YsBlock>[];
    var buildItemMap = <YMap, YsItem>{};
    for (YMap item in yArray!) {
      YsBlock ysBlock;
      if (itemMap.containsKey(item)) {
        ysBlock = itemMap.get(item) as YsBlock;
      } else {
        ysBlock = YsBlock(
          tree: this,
          yMap: item,
        );
        ysBlock.init();
        itemMap[item] = ysBlock;
      }
      // ysBlock.buildBlock();
      buildItemMap[item] = ysBlock;
      buildBlocks.add(ysBlock);
    }
    blocks = buildBlocks;
    itemMap = buildItemMap;
    editController.setBlocks(buildBlocks.map((e) => e.block!).toList());
    SchedulerBinding.instance.scheduleFrameCallback((timeStamp) {
      editController.relayoutVision();
    });
  }

  void applyCursorToEditor() {
    if (!initOk) {
      return;
    }
    var cursor = this.cursor;
    if (cursor == null) {
      editController.cursorState.cursorPosition = null;
      return;
    }
    var real = getEditCursorPosition(cursor);
    if (real != null) {
      editController.updateCursorToEdit(
        real,
      );
    }
  }

  void applySelectionToEditor() {
    if (!initOk) {
      return;
    }
    if (selection == null) {
      editController.selectState.clearSelect();
    } else {
      var start = getEditCursorPosition(selection!.start);
      var end = getEditCursorPosition(selection!.end);
      editController.selectState.start = start;
      editController.selectState.end = end;
    }
  }

  CursorPosition? getEditCursorPosition(YsCursor? cursor) {
    if (cursor == null) {
      return null;
    }
    var blockIndex = cursor.getBlockIndex();
    if (blockIndex == null) {
      return null;
    }
    var block = editController.blockManager.blocks[blockIndex];
    if (block.isEmpty) {
      return block.startCursorPosition..blockIndex = blockIndex;
    }
    if (cursor.blockType != BlockType.table) {
      var textPs = cursor.getTextOffset();
      if (textPs != null) {
        return block.getCursorPosition(TextPosition(offset: textPs))
          ..blockIndex = blockIndex;
      } else {
        return block.startCursorPosition..blockIndex = blockIndex;
      }
    }
    if (cursor.blockType == BlockType.table) {
      if (block is! TableBlock) {
        return block.startCursorPosition..blockIndex = blockIndex;
      }
      var rowPs = cursor.getTableRowIndex();
      if (rowPs == null) {
        return block.startCursorPosition..blockIndex = blockIndex;
      }
      var colPs = cursor.getTableColIndex();
      if (colPs == null) {
        return block.startCursorPosition..blockIndex = blockIndex;
      }
      var textOffset = cursor.getTextOffset();
      if (textOffset == null) {
        return block.startCursorPosition..blockIndex = blockIndex;
      }
      var cell = block.rows[rowPs][colPs];
      if (cell is ImageTableCell) {
        var offset = cell.offset + textOffset;
        return block.getCursorPosition(TextPosition(offset: offset))
          ..blockIndex = blockIndex;
      } else if (cell is TextTableCell) {
        var offset = cell.offset + textOffset;
        return block.getCursorPosition(TextPosition(offset: offset))
          ..blockIndex = blockIndex;
      }
    }
    return block.startCursorPosition..blockIndex = blockIndex;
  }

  void onInputText(TextEditingValue text) {
    var cursor = this.cursor;
    if (cursor == null) {
      return;
    }
    var blockIndex = cursor.getBlockIndex();
    if (blockIndex == null) {
      return;
    }
    var block = blocks[blockIndex];
    var textOffset = cursor.getTextOffset();
    if (textOffset == null) {
      return;
    }
    YMap yMap = block.yMap;
    yDoc.transact((transaction) {
      if (block.blockType == 'code') {
        var code = (yMap.get("code") as YText);
        code.insert(textOffset, text.text);
        block.updateBlock();
        setCursor(
            createCodeCursor(this, blockIndex, textOffset + text.text.length));
        applyCursorToEditor();
      } else if (block.isText) {
        var yText = (yMap.get("text"));
        if (yText is! YText) {
          yText = YText();
          yMap.set("text", yText);
        }
        yText.insert(textOffset, text.text);
        block.updateBlock();
        setCursor(
            createTextCursor(this, blockIndex, textOffset + text.text.length));
        applyCursorToEditor();
      } else if (block.blockType == 'table') {
        var table = YsTable.of(block);
        var colIndex = cursor.getTableColIndex();
        var rowIndex = cursor.getTableRowIndex();
        if (rowIndex == null || colIndex == null) {
          return;
        }
        var cell = table.getCellMap(rowIndex, colIndex);
        if (cell == null) {
          return;
        }
        if (cell.get("type") == "text") {
          (cell.get("text") as YText).insert(textOffset, text.text);
          block.updateBlock();
          setCursor(createTableCursor(this, blockIndex, rowIndex, colIndex,
              textOffset + text.text.length));
          applyCursorToEditor();
        }
      }
    });
  }

  void deleteSelectRange({bool mergeText = true}) {
    var selection = this.selection;
    if (selection == null) {
      return;
    }
    var startCursor = selection.start;
    var endCursor = selection.end;
    if (startCursor == null) {
      return;
    }
    if (endCursor == null) {
      return;
    }
    var startBlockIndex = startCursor.getBlockIndex();
    if (startBlockIndex == null) {
      return;
    }
    var endBlockIndex = endCursor.getBlockIndex();
    if (endBlockIndex == null) {
      return;
    }
    var startTextIndex = startCursor.getTextOffset();
    if (startTextIndex == null) {
      return;
    }
    var endTextIndex = endCursor.getTextOffset();
    if (endTextIndex == null) {
      return;
    }
    if (startBlockIndex == endBlockIndex) {
      deleteSingleSelectRange(
        startCursor: startCursor,
        endCursor: endCursor,
        startBlockIndex: startBlockIndex,
        endBlockIndex: endBlockIndex,
        startTextIndex: startTextIndex,
        endTextIndex: endTextIndex,
      );
    } else {
      deleteMultiSelectRange(
        startCursor: startCursor,
        endCursor: endCursor,
        startBlockIndex: startBlockIndex,
        endBlockIndex: endBlockIndex,
        startTextIndex: startTextIndex,
        endTextIndex: endTextIndex,
        mergeText: mergeText,
      );
    }
  }

  void deleteSingleSelectRange({
    required YsCursor startCursor,
    required YsCursor endCursor,
    required int startBlockIndex,
    required int endBlockIndex,
    required int startTextIndex,
    required int endTextIndex,
  }) {
    // 对范围内文字进行删除
    // 如果是图片或者线条，则删除之
    yDoc.transact((transaction) {
      if (startCursor.blockType == BlockType.image ||
          startCursor.blockType == BlockType.line) {
        if (startTextIndex != endTextIndex) {
          var text = createEmptyTextYMap();
          yArray!.delete(startBlockIndex);
          yArray!.insert(startBlockIndex, [text]);
          setCursor(createTextCursor(this, startBlockIndex, 0));
        }
        return;
      }
      if (startCursor.blockType == BlockType.text) {
        var text = (yArray!.get(startBlockIndex) as YMap).get('text') as YText;
        var length = endTextIndex - startTextIndex;
        text.delete(startTextIndex, length);
        setCursor(YsCursor.create(this, startBlockIndex, startTextIndex));
        return;
      }
      if (startCursor.blockType == BlockType.code) {
        var text = (yArray!.get(startBlockIndex) as YMap).get('code') as YText;
        var length = endTextIndex - startTextIndex;
        text.delete(startTextIndex, length);
        setCursor(startCursor);
        return;
      }
      if (startCursor.blockType == BlockType.table) {
        YsTable.of(blocks[startBlockIndex]).deleteSingleSelectRange(
          startCursor: startCursor,
          endCursor: endCursor,
          blockIndex: startBlockIndex,
          startTextIndex: startTextIndex,
          endTextIndex: endTextIndex,
        );
      }
    });

    setSelection(null);
    applySelectionToEditor();
    applyCursorToEditor();
  }

  void deleteMultiSelectRange({
    required YsCursor startCursor,
    required YsCursor endCursor,
    required int startBlockIndex,
    required int endBlockIndex,
    required int startTextIndex,
    required int endTextIndex,
    bool mergeText = true,
  }) {
    yDoc.transact((transaction) {
      int deleteFirstIndex = startBlockIndex + 1;
      int deleteLastIndex = endBlockIndex - 1;
      // 删除start~blockEnd
      DeleteFlag firstResult = deleteBetweenCursorAndEnd(startCursor);
      // 删除blockStart~end
      DeleteFlag lastResult = deleteBetweenStartAndCursor(endCursor);
      YsCursor newCursor = startCursor;
      if (firstResult == DeleteFlag.clearBlock) {
        //将 start 清空，光标移到 start0
        if (lastResult == DeleteFlag.clearBlock) {
          var text = createEmptyTextYMap();
          yArray!.delete(startBlockIndex);
          yArray!.insert(startBlockIndex, [text]);
          newCursor = YsCursor.start(this, startBlockIndex);
          //将 end 删除
          deleteFirstIndex = startBlockIndex + 1;
          deleteLastIndex = endBlockIndex;
          if (deleteFirstIndex <= deleteLastIndex) {
            yArray!.delete(
                deleteFirstIndex, deleteLastIndex - deleteFirstIndex + 1);
          }
        } else {
          newCursor = YsCursor.start(this, endBlockIndex);
          deleteFirstIndex = startBlockIndex;
          deleteLastIndex = endBlockIndex - 1;
          if (deleteFirstIndex <= deleteLastIndex) {
            yArray!.delete(
                deleteFirstIndex, deleteLastIndex - deleteFirstIndex + 1);
          }
        }
      } else {
        if (lastResult == DeleteFlag.clearBlock) {
          // 将 end 清空，将 start 保留，光标移到 start
          newCursor = startCursor;
          deleteLastIndex = endBlockIndex;
          if (deleteFirstIndex <= deleteLastIndex) {
            yArray!.delete(
                deleteFirstIndex, deleteLastIndex - deleteFirstIndex + 1);
          }
        } else {
          // 判断是否可以合并
          if (mergeText &&
              startCursor.blockType == BlockType.text &&
              endCursor.blockType == BlockType.text) {
            // 合并 start 和 end, 光标移动到 start
            deleteLastIndex = endBlockIndex;
            var startBlock = yArray!.get(startBlockIndex) as YMap;
            var endBlock = yArray!.get(endBlockIndex) as YMap;
            var startText = startBlock.get("text") as YText;
            var endText = endBlock.get("text") as YText;
            var newTextPos = startText.length;
            var startDelta = startText.toDelta();
            var endDelta = endText.toDelta();
            var newText = createYText();
            newText.applyDelta(endDelta);
            newText.applyDelta(startDelta);
            var newMap = createYMap();
            newMap.set("type", "text");
            newMap.set("text", newText);
            yArray!.delete(startBlockIndex);
            yArray!.insert(startBlockIndex, [newMap]);
            newCursor = createTextCursor(this, startBlockIndex, newTextPos);
          } else {
            newCursor = startCursor;
          }
          if (deleteFirstIndex <= deleteLastIndex) {
            yArray!.delete(
                deleteFirstIndex, deleteLastIndex - deleteFirstIndex + 1);
          }
        }
      }
      setCursor(newCursor);
      setSelection(null);
    });
    applySelectionToEditor();
    applyCursorToEditor();
  }

  DeleteFlag deleteBetweenCursorAndEnd(YsCursor cursor) {
    AbsolutePosition? position =
        createAbsolutePositionFromRelativePosition(cursor.positions[0], yDoc);
    if (position == null) {
      return DeleteFlag.skip;
    }
    if (cursor.blockType == BlockType.code) {
      var codePs =
          createAbsolutePositionFromRelativePosition(cursor.positions[1], yDoc);
      if (codePs == null) {
        return DeleteFlag.skip;
      }
      if (codePs.index == 0) {
        return DeleteFlag.clearBlock;
      }
      var block = yArray!.get(position.index) as YMap;
      var code = block.get("code") as YText;
      code.delete(codePs.index, code.length - codePs.index);
      return DeleteFlag.ok;
    } else if (cursor.blockType == BlockType.text) {
      var textPos =
          createAbsolutePositionFromRelativePosition(cursor.positions[1], yDoc);
      if (textPos == null) {
        return DeleteFlag.skip;
      }
      if (textPos.index == 0) {
        return DeleteFlag.clearBlock;
      }
      var block = yArray!.get(position.index) as YMap;
      var text = block.get("text") as YText;
      text.delete(textPos.index, text.length - textPos.index);
      return DeleteFlag.ok;
    } else if (cursor.blockType == BlockType.line ||
        cursor.blockType == BlockType.image) {
      if (position.assoc == 0) {
        return DeleteFlag.clearBlock;
      }
    } else if (cursor.blockType == BlockType.table) {
      var block = yArray!.get(position.index) as YMap;
      //删除
      var rowPs =
          createAbsolutePositionFromRelativePosition(cursor.positions[1], yDoc);
      var colPs =
          createAbsolutePositionFromRelativePosition(cursor.positions[2], yDoc);
      var cellPs =
          createAbsolutePositionFromRelativePosition(cursor.positions[3], yDoc);
      if (rowPs == null || colPs == null || cellPs == null) {
        return DeleteFlag.skip;
      }
      var rowIndex = rowPs.index;
      var colIndex = colPs.index;
      var rows = block.get("rows") as YArray;
      var row = rows.get(rowIndex) as YArray;
      var rowCount = row.length;
      var colCount = row.length;
      var cell = row.get(colIndex) as YMap;
      if (cell.get("type") == "text") {
        var text = cell.get("text") as YText;
        text.delete(cellPs.index, text.length - cellPs.index);
      } else {
        if (cellPs.assoc == 0) {
          row.delete(cellPs.index);
          row.insert(cellPs.index, [createEmptyTextYMap()]);
        }
      }
      if (colIndex < colCount - 1) {
        row.delete(colIndex + 1, colCount - colIndex - 1);
        row.insert(colIndex + 1, [
          for (var i = colIndex + 1; i < colCount; i++) createEmptyTextYMap()
        ]);
      }
      for (var i = rowIndex + 1; i < rowCount; i++) {
        var row = rows.get(i) as YArray;
        row.delete(0, row.length);
        row.insert(0, [
          for (var j = 0; j < colCount; j++) createEmptyTextYMap(),
        ]);
      }
      return DeleteFlag.ok;
    }
    return DeleteFlag.skip;
  }

  DeleteFlag deleteBetweenStartAndCursor(YsCursor cursor) {
    AbsolutePosition? position =
        createAbsolutePositionFromRelativePosition(cursor.positions[0], yDoc);
    if (position == null) {
      return DeleteFlag.skip;
    }
    if (cursor.blockType == BlockType.code) {
      var codePs =
          createAbsolutePositionFromRelativePosition(cursor.positions[1], yDoc);
      if (codePs == null) {
        return DeleteFlag.skip;
      }
      var block = yArray!.get(position.index) as YMap;
      var code = block.get("code") as YText;
      if (codePs.index == code.length) {
        return DeleteFlag.clearBlock;
      }
      code.delete(0, codePs.index);
      return DeleteFlag.ok;
    } else if (cursor.blockType == BlockType.text) {
      var textPos =
          createAbsolutePositionFromRelativePosition(cursor.positions[1], yDoc);
      if (textPos == null) {
        return DeleteFlag.skip;
      }
      var block = yArray!.get(position.index) as YMap;
      var text = block.get("text") as YText;
      if (textPos.index == text.length) {
        return DeleteFlag.clearBlock;
      }
      text.delete(0, textPos.index);
      return DeleteFlag.ok;
    } else if (cursor.blockType == BlockType.line ||
        cursor.blockType == BlockType.image) {
      if (position.assoc == 1) {
        return DeleteFlag.clearBlock;
      }
    } else if (cursor.blockType == BlockType.table) {
      var block = yArray!.get(position.index) as YMap;
      //删除
      var rowPs =
          createAbsolutePositionFromRelativePosition(cursor.positions[1], yDoc);
      var colPs =
          createAbsolutePositionFromRelativePosition(cursor.positions[2], yDoc);
      var cellPs =
          createAbsolutePositionFromRelativePosition(cursor.positions[3], yDoc);
      if (rowPs == null || colPs == null || cellPs == null) {
        return DeleteFlag.skip;
      }
      var rowIndex = rowPs.index;
      var colIndex = colPs.index;
      var rows = block.get("rows") as YArray;
      var row = rows.get(rowIndex) as YArray;
      var rowCount = row.length;
      var colCount = row.length;
      var cell = row.get(colIndex) as YMap;
      if (cell.get("type") == "text") {
        var text = cell.get("text") as YText;
        text.delete(0, cellPs.index);
      } else {
        if (cellPs.assoc == 1) {
          row.delete(cellPs.index);
          row.insert(cellPs.index, [createEmptyTextYMap()]);
        }
      }
      if (colIndex > 0) {
        row.delete(0, colIndex);
        row.insert(
            0, [for (var i = 0; i < colIndex; i++) createEmptyTextYMap()]);
      }
      for (var i = 0; i < rowIndex; i++) {
        var row = rows.get(i) as YArray;
        row.delete(0, row.length);
        row.insert(0, [
          for (var j = 0; j < colCount; j++) createEmptyTextYMap(),
        ]);
      }
      return DeleteFlag.ok;
    }
    return DeleteFlag.skip;
  }

  void setCursor(YsCursor? cursor) {
    this.cursor = cursor;
  }

  void removeCursor() {
    cursor = null;
  }

  void setSelection(YsSelection? selection) {
    this.selection = selection;
  }

  SelectIndex getSelectBlockIndex() {
    var startBlockIndex = -1;
    var endBlockIndex = -1;
    if (selection != null) {
      int? start = selection!.start?.getBlockIndex();
      int? end = selection!.end?.getBlockIndex();
      if (start != null) {
        endBlockIndex = startBlockIndex = start;
      }
      if (end != null) {
        endBlockIndex = end;
      }
    } else {
      var index = cursor?.getBlockIndex();
      if (index != null) {
        endBlockIndex = startBlockIndex = index;
      }
    }
    return SelectIndex(start: startBlockIndex, end: endBlockIndex);
  }

  SelectTableIndex? getSelectTableIndex() {
    var start = selection?.start ?? cursor;
    var end = selection?.end ?? cursor;
    if (start == null || end == null) {
      return null;
    }
    if (start.getBlockIndex() == null ||
        start.getBlockIndex() != end.getBlockIndex()) {
      return null;
    }
    var startRow = start.getTableRowIndex();
    var startCol = start.getTableColIndex();
    var endRow = end.getTableRowIndex();
    var endCol = end.getTableColIndex();
    if (startCol == null ||
        startRow == null ||
        endRow == null ||
        endCol == null) {
      return null;
    }

    return SelectTableIndex(
        startCol: startCol, startRow: startRow, endCol: endCol, endRow: endRow);
  }

  void replaceYsBlock(int startIndex, int replaceCount, List<YMap> content) {
    yDoc.transact((transaction) {
      if (replaceCount > 0) {
        yArray!.delete(startIndex, replaceCount);
      }
      yArray!.insert(startIndex, content);
    });
  }

  void addIndent() {
    var selectBlockIndex = getSelectBlockIndex();
    if (selectBlockIndex.start == -1) {
      return;
    }
    yDoc.transact((transaction) {
      for (var i = selectBlockIndex.start; i <= selectBlockIndex.end; i++) {
        var block = blocks[i];
        block.addIndent(blockIndex: i);
      }
    });
    applyCursorToEditor();
    applySelectionToEditor();
  }

  void removeIndent() {
    var selectBlockIndex = getSelectBlockIndex();
    if (selectBlockIndex.start == -1) {
      return;
    }
    yDoc.transact((transaction) {
      for (var i = selectBlockIndex.start; i <= selectBlockIndex.end; i++) {
        var block = blocks[i];
        block.removeIndent(blockIndex: i);
      }
    });
    applyCursorToEditor();
    applySelectionToEditor();
  }

  bool get hasSelect {
    return selection != null &&
        selection!.start != null &&
        selection!.end != null;
  }

  void enter() {
    yDoc.transact((transaction) {
      if (hasSelect) {
        deleteSelectRange(mergeText: true);
      }
      var index = getSelectBlockIndex();
      if (index.start == -1) {
        return;
      }
      var block = blocks[index.start];
      if (block.blockType == "table") {
        YsTable.of(block).enter();
      } else if (block.blockType == 'code') {
        YsCode.of(block).enter();
      } else {
        var offset = cursor?.getTextOffset();
        if (offset == null) {
          return;
        }
        if (offset == 0) {
          if (YsText.of(block).clearEmptyStyle(
            blockIndex: index.start,
            reason: "enter",
          )) {
            return;
          }
          // 光标在前，前面添加block
          addTextBlockBefore();
          setCursor(createBlockCursor(this, index.start + 1, 0));
        } else if (offset >= block.getLength()) {
          // 光标在后，后面添加text block，光标移动到新block
          addTextBlockAfter();
          setCursor(createBlockCursor(this, index.start + 1, 0));
        } else {
          // 光标在中，分割text，添加text block，光标移动到新block
          if (block.isText) {
            YMap split = YsText.of(block).split(offset);
            YsText.of(block).deleteToEnd(offset);
            insertYsBlocks(index.start + 1, [split]);
            setCursor(createBlockCursor(this, index.start + 1, 0));
          }
        }
      }
    });
    setSelection(null);
    applyCursorToEditor();
    applySelectionToEditor();
  }

  void insertYsBlocks(int index, List<YMap> blockMaps) {
    yArray!.insert(index, blockMaps);
  }

  void deleteYsBlocks(int index, int length) {
    yArray!.delete(index, length);
  }

  void deleteCursor(bool backspace) {
    var blockIndex = cursor?.getBlockIndex();
    if (blockIndex == null) {
      return;
    }
    var block = blocks[blockIndex];
    var blockType = block.blockType;
    if (block.isText) {
      YsText.of(block).deleteCursor(backspace);
    } else if (blockType == 'image') {
      YsImage.of(block).deleteCursor(backspace);
    } else if (blockType == 'line') {
      YsLine.of(block).deleteCursor(backspace);
    } else if (blockType == 'table') {
      YsTable.of(block).deleteCursor(backspace);
    } else if (blockType == 'code') {
      YsCode.of(block).deleteCursor(backspace);
    }
    applyCursorToEditor();
    applySelectionToEditor();
  }

  void addTextBlockAfter() {
    var blockIndex = cursor?.getBlockIndex();
    if (blockIndex == null) {
      return;
    }
    yDoc.transact((transaction) {
      insertYsBlocks(
          blockIndex + 1, [createEmptyTextYMap(getBlockMap(blockIndex))]);
      buildBlocks();
      setCursor(createBlockCursor(this, blockIndex + 1, 0));
    });
    setSelection(null);
  }

  void addTextBlockBefore() {
    var blockIndex = cursor?.getBlockIndex();
    if (blockIndex == null) {
      return;
    }
    insertYsBlocks(blockIndex, [createEmptyTextYMap(getBlockMap(blockIndex))]);
    setCursor(createBlockCursor(this, blockIndex, 0));
    setSelection(null);
  }

  YMap getBlockMap(int blockIndex) {
    return blocks[blockIndex].yMap;
  }

  void insertContent(List<WenBlock> content) {
    yDoc.transact((transaction) {
      //1.删除选择状态文字
      deleteSelectRange();
      //2.判断光标位置block类型
      if (cursor == null) {
        return;
      }
      var blockIndex = cursor!.getBlockIndex();
      if (blockIndex == null) {
        return;
      }
      var block = blocks[blockIndex];
      var blockType = block.blockType;
      if (block.isText) {
        YsText.of(block).insertContent(content);
      } else if (blockType == 'image') {
        YsImage.of(block).insertContent(content);
      } else if (blockType == 'line') {
        YsLine.of(block).insertContent(content);
      } else if (blockType == 'table') {
        YsTable.of(block).insertContent(content);
      } else if (blockType == 'code') {
        YsCode.of(block).insertContent(content);
      }
    });
    buildBlocks();
    applyCursorToEditor();
    applySelectionToEditor();
  }

  void changeTextLevel(int level) {
    var selectBlockIndex = getSelectBlockIndex();
    if (selectBlockIndex.start == -1) {
      return;
    }
    level = allPropertyIsValue(
      selectBlockIndex,
      "level",
      (val) => (val ?? 0) == level,
      needTable: false,
    )
        ? 0
        : level;
    yDoc.transact((transaction) {
      for (var i = selectBlockIndex.start; i <= selectBlockIndex.end; i++) {
        var block = blocks[i];
        block.changeTextLevel(level);
      }
    });
  }

  void changeTextToQuote() {
    var selectBlockIndex = getSelectBlockIndex();
    if (selectBlockIndex.start == -1) {
      return;
    }
    var allQuote = allPropertyIsValue(
      selectBlockIndex,
      "type",
      (val) {
        if (val == 'text') {
          return false;
        }
        if (val == 'title') {
          return false;
        }
        return true;
      },
      needTable: false,
    );
    yDoc.transact((transaction) {
      for (var i = selectBlockIndex.start; i <= selectBlockIndex.end; i++) {
        var block = blocks[i];
        block.changeTextToQuote(!allQuote);
      }
    });
  }

  void addCodeBlock({required String code, required String language}) {
    var cursor = this.cursor;
    if (cursor == null) {
      return;
    }
    var blockIndex = cursor.getBlockIndex();
    if (blockIndex == null) {
      return;
    }
    var yMap = WenCodeElement(code: code, language: language).getYMap();
    yDoc.transact((transaction) {
      insertYsBlocks(blockIndex + 1, [yMap]);
      setCursor(YsCursor.end(this, blockIndex + 1));
    });
  }

  void toggleCode({String language=""}) {
    var selectBlockIndex = getSelectBlockIndex();
    if (selectBlockIndex.start == -1) {
      return;
    }
    var isCode = true;
    for (var i = selectBlockIndex.start; i <= selectBlockIndex.end; i++) {
      if (blocks[i].blockType != 'code') {
        isCode = false;
        break;
      }
    }
    var editBlocks = editController.blockManager.blocks;
    StringBuffer text = StringBuffer();
    for (var i = selectBlockIndex.start; i <= selectBlockIndex.end; i++) {
      text.write(editBlocks[i].element.getText());
      if (i < selectBlockIndex.end) {
        text.writeln();
      }
    }
    yDoc.transact((transaction) {
      if (isCode) {
        //转换为文字
        var lines = text.toString().split("\n");
        var replaceList =
            lines.map((e) => WenTextElement(text: e).getYMap()).toList();
        replaceYsBlock(
          selectBlockIndex.start,
          selectBlockIndex.end - selectBlockIndex.start + 1,
          replaceList,
        );
      } else {
        //转换为代码
        replaceYsBlock(selectBlockIndex.start,
            selectBlockIndex.end - selectBlockIndex.start + 1, [
          WenCodeElement(code: text.toString(), language: language).getYMap()
        ]);
      }
      buildBlocks();
    });
    setSelection(null);
    setCursor(createBlockCursor(this, selectBlockIndex.start, 0));
  }

  void addBlock(WenBlock block) {
    var cursor = this.cursor;
    if (cursor == null) {
      return;
    }
    var blockIndex = cursor.getBlockIndex();
    if (blockIndex == null) {
      return;
    }
    insertYsBlocks(blockIndex + 1, [block.element.getYMap()]);
    setCursor(YsCursor.end(this, blockIndex + 1));
  }

  void addLine() {
    var cursor = this.cursor;
    if (cursor == null) {
      return;
    }
    var blockIndex = cursor.getBlockIndex();
    if (blockIndex == null) {
      return;
    }
    var yMap = LineElement().getYMap();
    yDoc.transact((transaction) {
      insertYsBlocks(blockIndex + 1, [yMap]);
      setCursor(YsCursor.end(this, blockIndex + 1));
    });
  }

  void setLink(String text, String link) {
    yDoc.transact((transaction) {
      insertContent([
        TextBlock(
          context: context,
          editController: editController,
          textElement: WenTextElement(
            text: text,
            url: link,
          ),
        ),
      ]);
    });
  }

  void replaceWenBlock(
      int startIndex, int replaceCount, List<WenBlock> blocks) {
    yDoc.transact((transaction) {
      if (replaceCount > 0) {
        deleteYsBlocks(startIndex, replaceCount);
      }
      if (yArray!.length == startIndex) {
        yArray!.insert(startIndex, [createEmptyTextYMap()]);
      }
      setCursor(createBlockCursor(this, startIndex, 0));
      insertContent(blocks);
    });
  }

  void addTableRowOnPrevious() {
    var cursor = this.cursor;
    if (cursor == null) {
      return;
    }
    var blockIndex = cursor.getBlockIndex();
    if (blockIndex == null) {
      return;
    }
    YsTable.of(blocks[blockIndex]).addRowOnPrevious();
  }

  void addTableRowOnNext() {
    var cursor = this.cursor;
    if (cursor == null) {
      return;
    }
    var blockIndex = cursor.getBlockIndex();
    if (blockIndex == null) {
      return;
    }
    YsTable.of(blocks[blockIndex]).addRowOnNext();
  }

  void addTableColOnPrevious() {
    var cursor = this.cursor;
    if (cursor == null) {
      return;
    }
    var blockIndex = cursor.getBlockIndex();
    if (blockIndex == null) {
      return;
    }
    YsTable.of(blocks[blockIndex]).addColOnPrevious();
  }

  void addTableColOnNext() {
    var cursor = this.cursor;
    if (cursor == null) {
      return;
    }
    var blockIndex = cursor.getBlockIndex();
    if (blockIndex == null) {
      return;
    }
    YsTable.of(blocks[blockIndex]).addColOnNext();
  }

  void deleteRow() {
    var cursor = this.cursor;
    if (cursor == null) {
      return;
    }
    var blockIndex = cursor.getBlockIndex();
    if (blockIndex == null) {
      return;
    }
    YsTable.of(blocks[blockIndex]).deleteRow();
  }

  void deleteCol() {
    var cursor = this.cursor;
    if (cursor == null) {
      return;
    }
    var blockIndex = cursor.getBlockIndex();
    if (blockIndex == null) {
      return;
    }
    YsTable.of(blocks[blockIndex]).deleteCol();
  }

  void deleteTable() {
    var cursor = this.cursor;
    if (cursor == null) {
      return;
    }
    var blockIndex = cursor.getBlockIndex();
    if (blockIndex == null) {
      return;
    }
    YsTable.of(blocks[blockIndex]).deleteTableCursor();
  }

  void deleteCode() {
    var cursor = this.cursor;
    if (cursor == null) {
      return;
    }
    var blockIndex = cursor.getBlockIndex();
    if (blockIndex == null) {
      return;
    }
    var block = blocks[blockIndex];
    if (block.blockType != 'code') {
      return;
    }
    transact((transaction) {
      replaceYsBlock(blockIndex, 1, [createEmptyTextYMap()]);
      setCursor(createTextCursor(this, blockIndex, 0));
    });
  }

  /// 判断是否全部等于某个值
  bool allPropertyIsValue(
    SelectIndex selectIndex,
    String key,
    bool Function(Object? v) value, {
    bool needTable = true,
  }) {
    for (var i = selectIndex.start; i <= selectIndex.end; i++) {
      var block = blocks[i];
      if (block.isText) {
        if (!value.call(block.yMap.get(key))) {
          return false;
        }
      } else if (needTable && block.blockType == 'table') {
        var table = YsTable.of(block);
        bool isAllValue = false;
        table.visitSelectCell(selectIndex, i, (row, col) {
          var item = table.getCellMap(row, col)?.get(key) == value;
          if (item) {
            return true;
          }
          isAllValue = false;
          return false;
        });
        if (!isAllValue) {
          return false;
        }
      }
    }
    return true;
  }

  void setItemType({required String itemType}) {
    var selectBlockIndex = getSelectBlockIndex();
    if (selectBlockIndex.start == -1 || selectBlockIndex.end == -1) {
      return;
    }
    var isItemType = allPropertyIsValue(
        selectBlockIndex, "itemType", (val) => val == itemType);
    if (isItemType) {
      itemType = "text";
    }
    yDoc.transact((transaction) {
      for (var i = selectBlockIndex.start; i <= selectBlockIndex.end; i++) {
        var block = blocks[i];
        if (block.isText) {
          YsText.of(block).setItemType(itemType);
        } else if (block.blockType == 'table') {
          YsTable.of(block).setItemType(selectBlockIndex, i, itemType);
        }
      }
    });
  }

  // 悬浮按钮设置表格的对齐方式
  void setTableAlignment(int blockIndex, String alignment) {
    var selectBlockIndex = getSelectBlockIndex();
    if (selectBlockIndex.start == -1 || selectBlockIndex.end == -1) {
      return;
    }
    YsTable.of(blocks[blockIndex])
        .setAlignment(selectBlockIndex, blockIndex, alignment);
  }

  void setAlignment(String? alignment) {
    var selectBlockIndex = getSelectBlockIndex();
    if (selectBlockIndex.start == -1 || selectBlockIndex.end == -1) {
      return;
    }
    yDoc.transact((transaction) {
      for (var i = selectBlockIndex.start; i <= selectBlockIndex.end; i++) {
        var block = blocks[i];
        if (block.isText) {
          YsText.of(block).setAlignment(alignment);
        } else if (block.blockType == 'table') {
          YsTable.of(block).setAlignment(selectBlockIndex, i, alignment);
        } else if (block.blockType == 'image') {
          YsImage.of(block).setAlignment(alignment);
        }
      }
    });
  }

  void setSelectTextAttribute(String key, Object? value) {
    if (!hasSelect) {
      return;
    }
    var selectBlockIndex = getSelectBlockIndex();
    if (selectBlockIndex.start == -1 || selectBlockIndex.end == -1) {
      return;
    }
    yDoc.transact((transaction) {
      for (var i = selectBlockIndex.start; i <= selectBlockIndex.end; i++) {
        var block = blocks[i];
        if (block.isText) {
          YsText.of(block).setAttribute(selectBlockIndex, i, key, value);
        } else if (block.blockType == 'table') {
          YsTable.of(block).setAttribute(selectBlockIndex, i, key, value);
        }
      }
    });
  }

  void setTextColor(int? color) {
    setSelectTextAttribute("color", color);
  }

  void setBackgroundColor(int? color) {
    setSelectTextAttribute("background", color);
  }

  void setBold(bool? bold) {
    setSelectTextAttribute("bold", bold);
  }

  void setItalic(bool? italic) {
    setSelectTextAttribute("italic", italic);
  }

  void setLineThrough(bool? lineThrough) {
    setSelectTextAttribute("lineThrough", lineThrough);
  }

  void setUnderline(bool? underline) {
    setSelectTextAttribute("underline", underline);
  }

  void onInputComposing(TextEditingValue composing) {}

  void deleteComposing() {}

  void adjustTable(int blockIndex, int newRowCount, int newColCount) {
    if (newRowCount == 0 || newColCount == 0) {
      YsTable.of(blocks[blockIndex]).deleteTable(blockIndex);
    } else {
      YsTable.of(blocks[blockIndex])
          .adjustTable(blockIndex, newRowCount, newColCount);
    }
  }

  void addTable(int rowCount, int colCount) {
    if (rowCount <= 0 || colCount <= 0) {
      return;
    }
    var blockIndex = cursor?.getBlockIndex();
    if (blockIndex == null) {
      return;
    }
    var isEmpty = isBlockEmpty(blockIndex);
    yDoc.transact((transaction) {
      var table = createYsTable(rowCount, colCount);
      if (isEmpty) {
        replaceYsBlock(blockIndex, 1, [table]);
        setCursor(createTableCursor(this, blockIndex, 0, 0, 0));
      } else {
        insertYsBlocks(blockIndex + 1, [table]);
        setCursor(createTableCursor(this, blockIndex + 1, 0, 0, 0));
      }
    });
    applyCursorToEditor();
  }

  bool isBlockEmpty(int index) {
    var block = blocks[index];
    if (block.isText) {
      return getYsTextLength(block.yMap) == 0;
    }
    return false;
  }

  void updateTableCellFormula(
      int blockIndex, int rowIndex, int colIndex, int offset, String formula) {
    var block = blocks[blockIndex];
    YsTable.of(block).updateCellFormula(rowIndex, colIndex, offset, formula);
  }

  void updateFormula(int blockIndex, int offset, String formula) {
    var block = blocks[blockIndex];
    YsText.of(block).updateFormula(offset, formula);
  }

  void changeBlockChecked(int blockIndex, bool? checked) {
    var block = blocks[blockIndex];
    YsText.of(block).updateChecked(checked);
  }

  void clearStyle() {
    if (!hasSelect) {
      return;
    }
    var selectBlockIndex = getSelectBlockIndex();
    if (selectBlockIndex.start == -1 || selectBlockIndex.end == -1) {
      return;
    }
    yDoc.transact((transaction) {
      for (var i = selectBlockIndex.start; i <= selectBlockIndex.end; i++) {
        var block = blocks[i];
        if (block.isText) {
          YsText.of(block).deleteAttribute(selectBlockIndex, i);
        } else if (block.blockType == 'table') {
          YsTable.of(block).deleteAttribute(selectBlockIndex, i);
        }
      }
    });
  }

  void undo() {
    if (undoManager?.canUndo() == true) {
      undoManager?.undo();
      try {
        getEditCursorPosition(chagnedPosition);
        setCursor(chagnedPosition);
        applyCursorToEditor();
      } catch (e) {
        print(e);
      }
    }
  }

  void redo() {
    if (undoManager?.canRedo() == true) {
      undoManager?.redo();
      try {
        getEditCursorPosition(chagnedPosition);
        setCursor(chagnedPosition);
        applyCursorToEditor();
      } catch (e) {}
    }
  }

  void record() {
    // undoManager?.stopCapturing();
    undoManager?.stopCapturing();
  }
}
//数据发生变化，要记录变化时的cursor

class CursorInfo {
  YsCursor? cursor;
  YsSelection? selection;

  CursorInfo({
    this.cursor,
    this.selection,
  });
}

enum DeleteFlag {
  skip,
  ok,
  clearBlock,
  error,
}

class SelectIndex {
  int start;
  int end;

  SelectIndex({
    required this.start,
    required this.end,
  });

  int get length => end - start + 1;
}

class SelectTableIndex {
  int startCol;
  int startRow;
  int endCol;
  int endRow;

  SelectTableIndex({
    required this.startCol,
    required this.startRow,
    required this.endCol,
    required this.endRow,
  });

  int get rowCount => endRow - startRow + 1;

  int get colCount => endCol - startCol + 1;
}
