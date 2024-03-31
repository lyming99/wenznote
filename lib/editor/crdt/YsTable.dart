import 'dart:math';

import 'package:wenznote/editor/block/block.dart';
import 'package:wenznote/editor/block/element/element.dart';
import 'package:wenznote/editor/block/image/image_block.dart';
import 'package:wenznote/editor/block/table/table_block.dart';
import 'package:wenznote/editor/block/text/text.dart';
import 'package:wenznote/editor/crdt/YsBlock.dart';
import 'package:wenznote/editor/crdt/YsText.dart';
import 'package:wenznote/editor/crdt/YsTree.dart';
import 'package:ydart/ydart.dart';

import 'YsCursor.dart';

class YsTable {
  YsBlock block;

  YsTable.of(this.block);

  /// table delete single select range
  /// 单个 block 选择了 range
  /// 现在进行删除，该当如何？
  /// 遍历选择的 cell： start middle end
  /// 开始的cell
  void deleteSingleSelectRange({
    required YsCursor startCursor,
    required YsCursor endCursor,
    required int blockIndex,
    required int startTextIndex,
    required int endTextIndex,
  }) {
    var startRowIndex = startCursor.getTableRowIndex();
    var startColIndex = startCursor.getTableColIndex();
    var endRowIndex = endCursor.getTableRowIndex();
    var endColIndex = endCursor.getTableColIndex();
    if (startRowIndex == null ||
        startColIndex == null ||
        endRowIndex == null ||
        endColIndex == null) {
      return;
    }
    var tableInfo = YsTableInfo(block.yMap);
    //1.只选择了一个cell，对选择的cell进行删除range
    if (startRowIndex == endRowIndex && startColIndex == endColIndex) {
      tableInfo.deleteCellText(
          startRowIndex, startColIndex, startTextIndex, endTextIndex);
      block.tree.setCursor(createTableCursor(block.tree, blockIndex,
          startRowIndex, startColIndex, startTextIndex));
      block.tree.applyCursorToEditor();
      return;
    }
    //2.选择了多个cell
    //将middle清空
    //将start删除[startTextPosition，cellEnd]
    //将end删除[cellStart，endTextPosition]
    for (int i = startRowIndex; i <= endRowIndex; i++) {
      var startCol = min(startColIndex, endColIndex);
      var endCol = max(startColIndex, endColIndex);
      if (i == startRowIndex) {
        startCol = startColIndex;
      }
      if (i == endRowIndex) {
        endCol = endColIndex;
      }
      for (int j = startCol; j <= endCol; j++) {
        //i 为 row，j 为 col
        var cellMap = tableInfo.getCellMap(i, j) as YMap;
        if (i == startRowIndex && j == startColIndex) {
          //此处进行删除首个cell操作
          tableInfo.deleteCellText(
              i, j, startTextIndex, getYsTextLength(cellMap));
        } else if (i == endRowIndex && j == endColIndex) {
          tableInfo.deleteCellText(i, j, 0, endTextIndex);
        } else {
          tableInfo.clearCell(i, j);
        }
      }
    }
    block.tree.setCursor(createTableCursor(
        block.tree, blockIndex, startRowIndex, startColIndex, startTextIndex));
    block.tree.applyCursorToEditor();
  }

  void enter() {
    var cursor = block.tree.cursor;
    if (cursor == null) {
      return;
    }
    var blockIndex = cursor.getBlockIndex();
    if (blockIndex == null) {
      return;
    }
    var rowIndex = cursor.getTableRowIndex();
    if (rowIndex == null) {
      return;
    }
    var colIndex = cursor.getTableColIndex();
    if (colIndex == null) {
      return;
    }
    var textOffset = cursor.getTextOffset();
    if (textOffset == null) {
      return;
    }
    var tableInfo = YsTableInfo(block.yMap);
    var cellMap = tableInfo.getCellMap(rowIndex, colIndex);
    if (cellMap == null) {
      return;
    }
    if (cellMap.get("type") != 'text') {
      return;
    }
    var text = cellMap.get("text");
    if (text is! YText) {
      return;
    }
    text.insert(textOffset, '\n');
    var newCursor = createTableCursor(
        block.tree, blockIndex, rowIndex, colIndex, textOffset + 1);
    block.tree.setCursor(newCursor);
  }

  YMap? getCellMap(int rowIndex, int colIndex) {
    var rows = block.yMap.get("rows");
    if (rows is! YArray) {
      return null;
    }
    var row = rows.get(rowIndex);
    if (row is! YArray) {
      return null;
    }

    var cell = row.get(colIndex);
    if (cell is! YMap) {
      return null;
    }
    return cell;
  }

  void clearCellContent(int rowIndex, int colIndex) {
    var rows = block.yMap.get("rows");
    if (rows is! YArray) {
      return;
    }
    var row = rows.get(rowIndex);
    if (row is! YArray) {
      return;
    }
    row.delete(colIndex, 1);
    row.insert(colIndex, [createEmptyTextYMap()]);
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
    var rowIndex = cursor.getTableRowIndex();
    if (rowIndex == null) {
      return;
    }
    var colIndex = cursor.getTableColIndex();

    if (colIndex == null) {
      return;
    }
    var cell = getCellMap(rowIndex, colIndex);
    if (cell == null) {
      return;
    }
    //1.如果cell是图片型，可以直接替换为文字型
    if (cell.get("type") == 'image') {
      clearCellContent(rowIndex, colIndex);
      block.tree.setCursor(
          createTableCursor(block.tree, blockIndex, rowIndex, colIndex, 0));
      return;
    }
    //2.如果在cell开头，不做动作
    if (textOffset == 0) {
      return;
    }
    //3.删除文字
    var text = cell.get('text');
    if (text is YText) {
      text.delete(textOffset - 1, 1);
      block.tree.setCursor(createTableCursor(
          block.tree, blockIndex, rowIndex, colIndex, textOffset - 1));
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
    var rowIndex = cursor.getTableRowIndex();
    if (rowIndex == null) {
      return;
    }
    var colIndex = cursor.getTableColIndex();

    if (colIndex == null) {
      return;
    }
    var cell = getCellMap(rowIndex, colIndex);
    if (cell == null) {
      return;
    }
    //1.如果cell是图片型，可以直接替换为文字型
    if (cell.get("type") == 'image') {
      clearCellContent(rowIndex, colIndex);
      block.tree.setCursor(
          createTableCursor(block.tree, blockIndex, rowIndex, colIndex, 0));
      return;
    }
    var text = cell.get('text');
    if (text is! YText) {
      return;
    }
    //2.如果在cell结尾，不做动作
    if (textOffset == text.length) {
      return;
    }
    //3.删除文字
    text.delete(textOffset, 1);
    block.tree.setCursor(createTableCursor(
        block.tree, blockIndex, rowIndex, colIndex, textOffset));
  }

  List<List<YMap>> getTableCellMaps(TableBlock first) {
    var cellMaps = <List<YMap>>[];
    for (var row in first.rows) {
      var cellRow = <YMap>[];
      for (var cell in row) {
        var cellMap = cell.element.getYMap();
        cellRow.add(cellMap);
      }
      cellMaps.add(cellRow);
    }
    return cellMaps;
  }

  List<List<YMap>> getContentCellMap(List<WenBlock> content) {
    List<List<YMap>> result = [];
    for (var item in content) {
      if (item is TableBlock) {
        result.addAll(getTableCellMaps(item));
        continue;
      }
      var row = <YMap>[];
      if (item is TextBlock) {
        row.add(item.element.getYMap());
      }
      if (item is ImageBlock) {
        row.add(item.element.getYMap());
      }
      result.add(row);
    }
    if (result.isEmpty) {
      return result;
    }
    var maxColCount = result
        .reduce(
            (value, element) => value.length > element.length ? value : element)
        .length;
    for (var row in result) {
      while (row.length < maxColCount) {
        row.add(createEmptyTextYMap());
      }
    }
    return result;
  }

  int get rowCount {
    var rows = block.yMap.get("rows");
    if (rows is! YArray) {
      return 0;
    }
    return rows.length;
  }

  int get colCount {
    var rows = block.yMap.get("rows");
    if (rows is! YArray) {
      return 0;
    }
    var row = rows.get(0);
    if (row is! YArray) {
      return 0;
    }
    return row.length;
  }

  YArray getRow(int rowIndex) {
    var rows = block.yMap.get("rows");
    if (rows is! YArray) {
      rows = YArray();
      block.yMap.set("rows", rows);
    }
    return rows.get(rowIndex) as YArray;
  }

  void addRow(YArray row) {
    var rows = block.yMap.get("rows");
    if (rows is! YArray) {
      rows = YArray();
      block.yMap.set("rows", rows);
    }
    rows.insert(rows.length, [row]);
  }

  void replaceCursorCells(List<List<YMap>> cellMaps) {
    if (cellMaps.isEmpty) {
      return;
    }
    if (cellMaps.first.isEmpty) {
      return;
    }
    var cursor = block.tree.cursor;
    if (cursor == null) {
      return;
    }
    var rowIndex = cursor.getTableRowIndex();
    if (rowIndex == null) {
      return;
    }
    var colIndex = cursor.getTableColIndex();
    if (colIndex == null) {
      return;
    }
    var contentColCount = cellMaps.first.length;
    var newColCount = colIndex + contentColCount;
    var colCount = this.colCount;
    var rowCount = this.rowCount;
    var insertRowPos = rowIndex;
    for (List<YMap> insertRow in cellMaps) {
      if (insertRowPos < rowCount) {
        YArray tableRow = getRow(insertRowPos);
        tableRow.delete(colIndex, min(colCount - colIndex, contentColCount));
        tableRow.insert(colIndex, insertRow);
      } else {
        YArray tableRow = YArray();
        for (int i = 0; i < colIndex; i++) {
          tableRow.insert(i, [createEmptyTextYMap()]);
        }
        tableRow.insert(colIndex, insertRow);
        addRow(tableRow);
      }
      insertRowPos++;
    }
    if (colCount < newColCount) {
      for (var i = 0; i < rowCount; i++) {
        var tableRow = getRow(i);
        var curColCount = tableRow.length;
        for (int j = curColCount; j < newColCount; j++) {
          tableRow.insert(j, [createEmptyTextYMap()]);
        }
      }
    }
  }

  void replaceCursorCell(YMap yMap) {
    var cursor = block.tree.cursor;
    if (cursor == null) {
      return;
    }
    var rowIndex = cursor.getTableRowIndex();
    if (rowIndex == null) {
      return;
    }
    var colIndex = cursor.getTableColIndex();
    if (colIndex == null) {
      return;
    }
    var row = getRow(rowIndex);
    row.delete(colIndex);
    row.insert(colIndex, [yMap]);
  }

  void insertCursorCellText(YMap yMap) {
    var cursor = block.tree.cursor;
    if (cursor == null) {
      return;
    }
    var blockIndex = cursor.getBlockIndex();
    if (blockIndex == null) {
      return;
    }
    var rowIndex = cursor.getTableRowIndex();
    if (rowIndex == null) {
      return;
    }
    var colIndex = cursor.getTableColIndex();
    if (colIndex == null) {
      return;
    }
    var cell = getCellMap(rowIndex, colIndex);
    if (cell == null) {
      return;
    }
    if (cell.get("type") == 'text') {
      var textOffset = cursor.getTextOffset();
      if (textOffset == null) {
        return;
      }
      insertYsText(cell, textOffset, yMap);
      block.tree.setCursor(createTableCursor(block.tree, blockIndex, rowIndex,
          colIndex, textOffset + (yMap.get('text') as YText).length));
    } else {
      replaceCursorCell(yMap);
      block.tree.setCursor(
          createTableCursor(block.tree, blockIndex, rowIndex, colIndex, 1));
    }
  }

  void insertContent(List<WenBlock> content) {
    if (content.isEmpty) {
      return;
    }
    var cursor = block.tree.cursor;
    if (cursor == null) {
      return;
    }
    var blockIndex = cursor.getBlockIndex();
    if (blockIndex == null) {
      return;
    }
    var rowIndex = cursor.getTableRowIndex();
    if (rowIndex == null) {
      return;
    }
    var colIndex = cursor.getTableColIndex();
    if (colIndex == null) {
      return;
    }
    // 1. n=1
    if (content.length == 1) {
      var first = content.first;
      if (first is TableBlock) {
        // replace cells to table
        List<List<YMap>> cellMaps = getTableCellMaps(first);
        replaceCursorCells(cellMaps);
        block.tree.setCursor(
            createTableCursor(block.tree, blockIndex, rowIndex, colIndex, 0));
      } else {
        if (first is ImageBlock) {
          // replace with image cell
          replaceCursorCell(first.element.getYMap());
          block.tree.setCursor(
              createTableCursor(block.tree, blockIndex, rowIndex, colIndex, 1));
        }
        if (first is TextBlock) {
          // insert text
          insertCursorCellText(first.element.getYMap());
        }
      }
    }
    // 2.n>1
    if (content.length > 1) {
      // content to cells
      List<List<YMap>> cellMaps = getContentCellMap(content);
      // replace cells to table
      replaceCursorCells(cellMaps);
      block.tree.setCursor(
          createTableCursor(block.tree, blockIndex, rowIndex, colIndex, 0));
    }
  }

  void addRowOnPrevious() {
    if (block.blockType != 'table') {
      return;
    }
    var cursor = block.tree.cursor;
    if (cursor == null) {
      return;
    }
    var blockIndex = cursor.getBlockIndex();
    if (blockIndex == null) {
      return;
    }
    var rowIndex = cursor.getTableRowIndex();
    if (rowIndex == null) {
      return;
    }
    var colIndex = cursor.getTableRowIndex();
    if (colIndex == null) {
      return;
    }
    var textOffset = cursor.getTextOffset();
    if (textOffset == null) {
      return;
    }
    block.tree.yDoc.transact((transaction) {
      var rows = block.yMap.get("rows");
      if (rows is! YArray) {
        return;
      }
      var colCount = this.colCount;
      rows.insert(
          rowIndex, [for (var i = 0; i < colCount; i++) createEmptyTextYMap()]);
      block.tree.setCursor(createTableCursor(
          block.tree, blockIndex, rowIndex, colIndex, textOffset));
    });
  }

  void addRowOnNext() {
    if (block.blockType != 'table') {
      return;
    }
    var cursor = block.tree.cursor;
    if (cursor == null) {
      return;
    }
    var blockIndex = cursor.getBlockIndex();
    if (blockIndex == null) {
      return;
    }
    var rowIndex = cursor.getTableRowIndex();
    if (rowIndex == null) {
      return;
    }
    var colIndex = cursor.getTableRowIndex();
    if (colIndex == null) {
      return;
    }
    var textOffset = cursor.getTextOffset();
    if (textOffset == null) {
      return;
    }
    block.tree.yDoc.transact((transaction) {
      var rows = block.yMap.get("rows");
      if (rows is! YArray) {
        return;
      }
      var colCount = this.colCount;
      rows.insert(rowIndex + 1,
          [for (var i = 0; i < colCount; i++) createEmptyTextYMap()]);
      block.tree.setCursor(createTableCursor(
          block.tree, blockIndex, rowIndex, colIndex, textOffset));
    });
  }

  void addColOnPrevious() {
    if (block.blockType != 'table') {
      return;
    }
    var cursor = block.tree.cursor;
    if (cursor == null) {
      return;
    }
    var blockIndex = cursor.getBlockIndex();
    if (blockIndex == null) {
      return;
    }
    var rowIndex = cursor.getTableRowIndex();
    if (rowIndex == null) {
      return;
    }
    var colIndex = cursor.getTableRowIndex();
    if (colIndex == null) {
      return;
    }
    var textOffset = cursor.getTextOffset();
    if (textOffset == null) {
      return;
    }
    block.tree.yDoc.transact((transaction) {
      var rows = block.yMap.get("rows");
      if (rows is! YArray) {
        return;
      }
      var rowCount = this.rowCount;
      for (var i = 0; i < rowCount; i++) {
        (rows.get(i) as YArray).insert(colIndex, [createEmptyTextYMap()]);
      }
      block.tree.setCursor(createTableCursor(
          block.tree, blockIndex, rowIndex, colIndex, textOffset));

      // alignments修改
      var alignments = block.yMap.get("alignments");
      if (alignments is! YMap) {
        return;
      }
      var removeKeys = <String>[];
      var curColCount = colCount;
      var changeMap = <String, String>{};
      for (var entry in alignments.typeMapEnumerateValues().entries) {
        var index = int.parse(entry.key);
        if (index >= curColCount) {
          removeKeys.add(entry.key);
        }
        if (index >= colIndex) {
          removeKeys.add("$index");
          removeKeys.remove('${index + 1}');
          changeMap['${index + 1}'] = entry.value as String;
        }
      }
      for (var key in removeKeys) {
        alignments.delete(key);
      }
      for (var entry in changeMap.entries) {
        alignments.set(entry.key, entry.value);
      }
    });
  }

  void addColOnNext() {
    if (block.blockType != 'table') {
      return;
    }
    var cursor = block.tree.cursor;
    if (cursor == null) {
      return;
    }
    var blockIndex = cursor.getBlockIndex();
    if (blockIndex == null) {
      return;
    }
    var rowIndex = cursor.getTableRowIndex();
    if (rowIndex == null) {
      return;
    }
    var colIndex = cursor.getTableRowIndex();
    if (colIndex == null) {
      return;
    }
    var textOffset = cursor.getTextOffset();
    if (textOffset == null) {
      return;
    }
    block.tree.yDoc.transact((transaction) {
      var rows = block.yMap.get("rows");
      if (rows is! YArray) {
        return;
      }
      var rowCount = this.rowCount;
      for (var i = 0; i < rowCount; i++) {
        (rows.get(i) as YArray).insert(colIndex + 1, [createEmptyTextYMap()]);
      }
      block.tree.setCursor(createTableCursor(
          block.tree, blockIndex, rowIndex, colIndex, textOffset));

      // alignments修改
      var alignments = block.yMap.get("alignments");
      if (alignments is! YMap) {
        return;
      }
      var removeKeys = <String>[];
      var curColCount = colCount;
      var changeMap = <String, String>{};
      for (var entry in alignments.typeMapEnumerateValues().entries) {
        var index = int.parse(entry.key);
        if (index >= curColCount) {
          removeKeys.add(entry.key);
        }
        if (index >= colIndex + 1) {
          removeKeys.add("$index");
          removeKeys.remove('${index + 1}');
          changeMap['${index + 1}'] = entry.value as String;
        }
      }
      for (var key in removeKeys) {
        alignments.delete(key);
      }
      for (var entry in changeMap.entries) {
        alignments.set(entry.key, entry.value);
      }
    });
  }

  void deleteRow() {
    if (block.blockType != 'table') {
      return;
    }
    var cursor = block.tree.cursor;
    if (cursor == null) {
      return;
    }
    var blockIndex = cursor.getBlockIndex();
    if (blockIndex == null) {
      return;
    }
    var rowIndex = cursor.getTableRowIndex();
    if (rowIndex == null) {
      return;
    }
    var colIndex = cursor.getTableRowIndex();
    if (colIndex == null) {
      return;
    }
    var textOffset = cursor.getTextOffset();
    if (textOffset == null) {
      return;
    }
    if (rowCount == 1) {
      deleteTableCursor();
      return;
    }
    var selectIndex = block.tree.getSelectTableIndex();
    if (selectIndex == null) {
      return;
    }
    block.tree.yDoc.transact((transaction) {
      var rows = block.yMap.get("rows");
      if (rows is! YArray) {
        return;
      }
      rows.delete(selectIndex.startRow, selectIndex.rowCount);
      block.tree.setCursor(createTableCursor(
          block.tree, blockIndex, min(rowIndex, rowCount - 1), colIndex, 0));
    });
  }

  void deleteCol() {
    if (block.blockType != 'table') {
      return;
    }
    var cursor = block.tree.cursor;
    if (cursor == null) {
      return;
    }
    var blockIndex = cursor.getBlockIndex();
    if (blockIndex == null) {
      return;
    }
    var rowIndex = cursor.getTableRowIndex();
    if (rowIndex == null) {
      return;
    }
    var colIndex = cursor.getTableRowIndex();
    if (colIndex == null) {
      return;
    }
    var textOffset = cursor.getTextOffset();
    if (textOffset == null) {
      return;
    }
    var selectIndex = block.tree.getSelectTableIndex();
    if (selectIndex == null) {
      return;
    }
    if (colCount == 1) {
      deleteTableCursor();
      return;
    }
    block.tree.yDoc.transact((transaction) {
      var rows = block.yMap.get("rows");
      if (rows is! YArray) {
        return;
      }
      var rowCount = this.rowCount;
      for (var i = 0; i < rowCount; i++) {
        (rows.get(i) as YArray)
            .delete(selectIndex.startCol, selectIndex.colCount);
      }
      block.tree.setCursor(createTableCursor(
          block.tree, blockIndex, selectIndex.startRow, min(colCount - 1, selectIndex.startCol), 0));
      // alignments修改
      var alignments = block.yMap.get("alignments");
      if (alignments is! YMap) {
        return;
      }
      var removeKeys = <String>[];
      var curColCount = colCount;
      var changeMap = <String, String>{};
      for (var entry in alignments.typeMapEnumerateValues().entries) {
        var index = int.parse(entry.key);
        if (index >= curColCount) {
          removeKeys.add(entry.key);
        }
        if (index >= selectIndex.startCol) {
          removeKeys.add("$index");
          removeKeys.remove('${index - selectIndex.colCount}');
          changeMap['${index - selectIndex.colCount}'] = entry.value as String;
        }
      }
      for (var key in removeKeys) {
        alignments.delete(key);
      }
      for (var entry in changeMap.entries) {
        alignments.set(entry.key, entry.value);
      }
    });
  }

  void deleteTableCursor() {
    if (block.blockType != 'table') {
      return;
    }
    var cursor = block.tree.cursor;
    if (cursor == null) {
      return;
    }
    var blockIndex = cursor.getBlockIndex();
    if (blockIndex == null) {
      return;
    }
    block.tree.transact((transaction) {
      block.tree.replaceYsBlock(blockIndex, 1, [createEmptyTextYMap()]);
      block.tree.setCursor(createTextCursor(block.tree, blockIndex, 0));
    });
  }

  void deleteTable(int blockIndex) {
    block.tree.replaceYsBlock(blockIndex, 1, [createEmptyTextYMap()]);
    block.tree.setCursor(createTextCursor(block.tree, blockIndex, 0));
  }

  void setItemType(
      SelectIndex selectIndex, int currentBlockIndex, String itemType) {
    visitSelectCell(selectIndex, currentBlockIndex, (row, col) {
      var cell = getCellMap(row, col);
      if (cell != null) {
        if (isTextYMap(cell)) {
          cell.set("itemType", itemType);
        }
      }
      return true;
    });
  }

  void visitSelectCell(
      SelectIndex selectIndex, int currentBlockIndex, TableCellVisit visit) {
    if (block.tree.hasSelect) {
      // 多个cell
      if (selectIndex.start == selectIndex.end) {
        // 只选择了一个表格
        var tableInfo = block.tree.getSelectTableIndex();
        if (tableInfo == null) {
          return;
        }
        for (var rowIndex = tableInfo.startRow;
            rowIndex <= tableInfo.endRow;
            rowIndex++) {
          var startCol = tableInfo.startCol;
          var endCol = tableInfo.endCol;
          if (rowIndex != tableInfo.startRow) {
            startCol = min(startCol, endCol);
          }
          if (rowIndex != tableInfo.endRow) {
            endCol = max(startCol, endCol);
          }
          for (var colIndex = startCol; colIndex <= endCol; colIndex++) {
            visit.call(rowIndex, colIndex);
          }
        }
      } else {
        var rowCount = this.rowCount;
        var colCount = this.colCount;
        // 范围选择中选择了表格: 整个表格、选择到结束、开始到选择
        if (selectIndex.start != currentBlockIndex &&
            selectIndex.end != currentBlockIndex) {
          // 1.整个表格
          for (var rowIndex = 0; rowIndex < rowCount; rowIndex++) {
            for (var colIndex = 0; colIndex < colCount; colIndex++) {
              visit.call(rowIndex, colIndex);
            }
          }
        }
        var selection = block.tree.selection;
        if (selection == null) {
          return;
        }
        if (selectIndex.start == currentBlockIndex) {
          // 2.选择到结束
          var selectStart = selection.start;
          if (selectStart == null) {
            return;
          }
          var selectStartRow = selectStart.getTableRowIndex();
          var selectStartCol = selectStart.getTableColIndex();
          if (selectStartRow == null ||
              selectStartCol == null ||
              selectStartRow == -1 ||
              selectStartCol == -1) {
            return;
          }
          for (var rowIndex = selectStartRow; rowIndex < rowCount; rowIndex++) {
            var startCol = 0;
            var endCol = colCount - 1;
            if (rowIndex == selectStartRow) {
              startCol = selectStartCol;
            }
            for (var colIndex = startCol; colIndex <= endCol; colIndex++) {
              visit.call(rowIndex, colIndex);
            }
          }
        }
        if (selectIndex.end == currentBlockIndex) {
          // 3.开始到选择
          var selectEnd = selection.end;
          if (selectEnd == null) {
            return;
          }
          var selectEndRow = selectEnd.getTableRowIndex();
          var selectEndCol = selectEnd.getTableColIndex();
          if (selectEndRow == null ||
              selectEndCol == null ||
              selectEndRow == -1 ||
              selectEndCol == -1) {
            return;
          }
          for (var rowIndex = 0; rowIndex <= selectEndRow; rowIndex++) {
            var startCol = 0;
            var endCol = colCount - 1;
            if (rowIndex == selectEndRow) {
              endCol = selectEndCol;
            }
            for (var colIndex = startCol; colIndex <= endCol; colIndex++) {
              visit.call(rowIndex, colIndex);
            }
          }
        }
      }
    } else {
      // 单个cell
      var cursor = block.tree.cursor;
      if (cursor == null) {
        return;
      }
      var selectRow = cursor.getTableRowIndex();
      var selectCol = cursor.getTableColIndex();
      if (selectRow == null || selectCol == null) {
        return;
      }
      visit.call(selectRow, selectCol);
    }
  }

  void setAlignment(
      SelectIndex selectBlockIndex, int currentBlockIndex, String? alignment) {
    var minCol = colCount;
    var maxCol = 0;
    visitSelectCell(selectBlockIndex, currentBlockIndex, (row, col) {
      minCol = min(minCol, col);
      maxCol = max(maxCol, col);
      return true;
    });
    block.tree.yDoc.transact((transaction) {
      var alignments = block.yMap.get("alignments");
      if (alignments is! YMap) {
        alignments = YMap();
        block.yMap.set("alignments", alignments);
      }
      for (var i = minCol; i <= maxCol; i++) {
        alignments.set("$i", alignment);
      }
    });
  }

  void setAttribute(
      SelectIndex selectIndex, int curBlockIndex, String key, Object? value) {
    visitSelectCell(selectIndex, curBlockIndex, (row, col) {
      var map = getCellMap(row, col);
      if (map == null) {
        return true;
      }
      var startTextIndex = 0;
      var endTextIndex = getYsTextLength(map);
      if (curBlockIndex == selectIndex.start) {
        var cursor = block.tree.selection?.start;
        if (cursor != null) {
          if (row == cursor.getTableRowIndex() &&
              col == cursor.getTableColIndex()) {
            startTextIndex = cursor.getTextOffset() ?? startTextIndex;
          }
        }
      }
      if (curBlockIndex == selectIndex.end) {
        var cursor = block.tree.selection?.end;
        if (cursor != null) {
          if (row == cursor.getTableRowIndex() &&
              col == cursor.getTableColIndex()) {
            endTextIndex = cursor.getTextOffset() ?? endTextIndex;
          }
        }
      }
      var text = map.get("text");
      if (text is! YText) {
        return true;
      }
      text.format(startTextIndex, endTextIndex - startTextIndex, {key: value});
      return true;
    });
  }

  void deleteAttribute(SelectIndex selectIndex, int curBlockIndex) {
    visitSelectCell(selectIndex, curBlockIndex, (row, col) {
      var map = getCellMap(row, col);
      if (map == null) {
        return true;
      }
      var startTextIndex = 0;
      var endTextIndex = getYsTextLength(map);
      if (curBlockIndex == selectIndex.start) {
        var cursor = block.tree.selection?.start;
        if (cursor != null) {
          if (row == cursor.getTableRowIndex() &&
              col == cursor.getTableColIndex()) {
            startTextIndex = cursor.getTextOffset() ?? startTextIndex;
          }
        }
      }
      if (curBlockIndex == selectIndex.end) {
        var cursor = block.tree.selection?.end;
        if (cursor != null) {
          if (row == cursor.getTableRowIndex() &&
              col == cursor.getTableColIndex()) {
            endTextIndex = cursor.getTextOffset() ?? endTextIndex;
          }
        }
      }
      var text = map.get("text");
      if (text is! YText) {
        return true;
      }
      text.format(startTextIndex, endTextIndex - startTextIndex, clearStyleMap);
      return true;
    });
  }

  void adjustTable(int blockIndex, int newRowCount, int newColCount) {
    bool needRemoveCursor(YsCursor? cursor) {
      if (cursor == null) {
        return false;
      }
      var cursorBlockIndex = cursor.getBlockIndex();
      if (cursorBlockIndex == blockIndex) {
        var cursorRowIndex = cursor.getTableRowIndex();
        var cursorColIndex = cursor.getTableColIndex();
        if (cursorColIndex != null && cursorRowIndex != null) {
          if (cursorColIndex >= newColCount || cursorRowIndex >= newRowCount) {
            return true;
          }
        }
      }
      return false;
    }

    void adjustCursor() {
      if (needRemoveCursor(block.tree.cursor)) {
        block.tree.setCursor(null);
        block.tree.applyCursorToEditor();
      }
      if (needRemoveCursor(block.tree.selection?.start) ||
          needRemoveCursor(block.tree.selection?.end)) {
        block.tree.setSelection(null);
        block.tree.applySelectionToEditor();
      }
    }

    block.tree.transact((transaction) {
      if (newRowCount < rowCount) {
        // 新的行小于现有的行，删除部分行
        deleteRows(newRowCount, rowCount - newRowCount);
      } else if (newRowCount > rowCount) {
        addRows(rowCount, newRowCount - rowCount);
      }
      if (newColCount < colCount) {
        deleteCols(newColCount, colCount - newColCount);
      } else if (newColCount > colCount) {
        addCols(colCount, newColCount - colCount);
      }
      adjustCursor();
    });
  }

  void deleteRows(int index, int length) {
    var map = block.yMap;
    var rows = map.get("rows");
    if (rows is! YArray) {
      return;
    }
    rows.delete(index, length);
  }

  void addRows(int index, int length) {
    var map = block.yMap;
    var rows = map.get("rows");
    if (rows is! YArray) {
      return;
    }
    rows.insert(index, [for (var i = 0; i < length; i++) createRow(colCount)]);
  }

  void deleteCols(int index, int length) {
    var map = block.yMap;
    var rows = map.get("rows");
    if (rows is! YArray) {
      return;
    }
    var rowCount = rows.length;
    for (var i = 0; i < rowCount; i++) {
      var row = rows.get(i);
      if (row is YArray) {
        row.delete(index, length);
      }
    }
  }

  void addCols(int index, int length) {
    var map = block.yMap;
    var rows = map.get("rows");
    if (rows is! YArray) {
      return;
    }
    var rowCount = rows.length;
    for (var i = 0; i < rowCount; i++) {
      var row = rows.get(i);
      if (row is YArray) {
        row.insert(
            index, [for (var j = 0; j < length; j++) createEmptyTextYMap()]);
      }
    }
  }

  YArray createRow(int colCount) {
    var arr = createYArray(block.tree.yDoc);
    arr.insert(0, [
      for (var i = 0; i < colCount; i++) createEmptyTextYMap(),
    ]);
    return arr;
  }

  void updateCellFormula(
      int rowIndex, int colIndex, int offset, String formula) {
    block.tree.transact((transaction) {
      var rows = block.yMap.get("rows");
      if (rows is! YArray) {
        return;
      }
      var row = rows.get(rowIndex);
      if (row is! YArray) {
        return;
      }
      var cell = row.get(colIndex);
      if (cell is! YMap) {
        return;
      }
      var text = cell.get("text");
      if (text is! YText) {
        return;
      }
      text.delete(offset, 1);
      text.insertEmbed(offset, {
        "type": "text",
        "text": formula,
        "itemType": "formula",
      });
      block.updateBlock();
    });
  }

  void insertRow(int rowIndex, int colIndex) {
    addRows(rowIndex, 1);
  }

  void insertCol(int rowIndex, int colIndex) {
    addCols(colIndex, 1);
  }
}

class TableCellCount {
  int rowCount;
  int colCount;

  TableCellCount(this.rowCount, this.colCount);
}

class YsTableInfo {
  late List<List<YsTableCellInfo>> rows;
  late YArray rowsArray;

  int get rowCount => rows.length;

  int get colCount => rows.isEmpty ? 0 : rows[0].length;

  YsTableInfo(YMap map) {
    rows = [];
    if (!map.containsKey("rows")) {
      map.set("rows", YArray());
    }
    rowsArray = map.get("rows") as YArray;
    for (var i = 0; i < rowsArray.length; i++) {
      var row = <YsTableCellInfo>[];
      var array = rowsArray.get(i) as YArray;
      for (int j = 0; j < array.length; j++) {
        row.add(YsTableCellInfo(array.get(j) as YMap));
      }
      rows.add(row);
    }
  }

  void clearCell(int rowIndex, int colIndex) {
    if (rowIndex >= rowsArray.length) {
      return;
    }
    var array = rowsArray.get(rowIndex);
    if (array is! YArray) {
      return;
    }
    if (colIndex >= array.length) {
      return;
    }
    var cell = getCellMap(rowIndex, colIndex);
    if (cell != null &&
        cell.get("type") == 'text' &&
        getYsTextLength(cell) == 0) {
      return;
    }
    array.delete(colIndex);
    array.insert(colIndex, [
      createEmptyTextYMap(),
    ]);
  }

  void deleteCellText(
      int rowIndex, int colIndex, int startTextIndex, int endTextIndex) {
    var cellMap = getCellMap(rowIndex, colIndex);
    if (cellMap == null) {
      return;
    }
    if (cellMap.get("type") == "text") {
      var yText = cellMap.get("text");
      if (yText is YText) {
        yText.delete(startTextIndex, endTextIndex - startTextIndex);
      }
    } else {
      if (startTextIndex != endTextIndex) {
        clearCell(rowIndex, colIndex);
      }
    }
  }

  YMap? getCellMap(int rowIndex, int colIndex) {
    if (rowIndex >= rowsArray.length) {
      return null;
    }
    var array = rowsArray.get(rowIndex);
    if (array is! YArray) {
      return null;
    }
    if (colIndex >= array.length) {
      return null;
    }
    return array.get(colIndex) as YMap?;
  }
}

class YsTableCellInfo {
  YMap cellMap;

  YsTableCellInfo(this.cellMap);
}

YArray createTableRow(int colCount) {
  var arr = YArray();
  arr.insert(0, [for (var i = 0; i < colCount; i++) createEmptyTextYMap()]);
  return arr;
}

YMap createYsTable(int rowCount, int colCount) {
  var table = YMap();
  var rows = YArray();
  rows.insert(0, [for (var i = 0; i < rowCount; i++) createTableRow(colCount)]);
  table.set("type", "table");
  table.set("rows", rows);
  return table;
}
