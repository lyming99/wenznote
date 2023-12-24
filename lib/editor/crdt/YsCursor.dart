import 'package:flutter_crdt/flutter_crdt.dart';
import 'package:note/editor/crdt/YsTable.dart';
import 'package:note/editor/crdt/YsText.dart';

import 'YsTree.dart';

enum BlockType {
  text,
  table,
  image,
  line,
  code,
}

class YsCursor {
  static YsCursor create(YsTree tree, int blockIndex, int offset) {
    var textMap = tree.yArray!.get(blockIndex) as YMap;
    if (textMap.get("type") == "text") {
      return YsCursor.text(tree, blockIndex, offset);
    } else if (textMap.get("type") == "image") {
      return YsCursor.image(tree, blockIndex, offset);
    } else if (textMap.get("type") == "line") {
      return YsCursor.line(tree, blockIndex, offset);
    } else if (textMap.get("type") == "code") {
      return YsCursor.code(tree, blockIndex, offset);
    } else if (textMap.get("type") == "table") {
      return YsCursor.table(tree, blockIndex, 0, 0, 0);
    }
    return YsCursor.text(tree, blockIndex, offset);
  }

  static YsCursor start(YsTree tree, int blockIndex) {
    return create(tree, blockIndex, 0);
  }

  static YsCursor end(YsTree tree, int blockIndex) {
    var blockMap = tree.yArray!.get(blockIndex) as YMap;
    if (blockMap.get("type") == "text") {
      return YsCursor.text(tree, blockIndex, getYsTextLength(blockMap));
    } else if (blockMap.get("type") == "image") {
      return YsCursor.image(tree, blockIndex, 1);
    } else if (blockMap.get("type") == "line") {
      return YsCursor.line(tree, blockIndex, 1);
    } else if (blockMap.get("type") == "code") {
      return YsCursor.code(tree, blockIndex, getYsCodeTextLength(blockMap));
    } else if (blockMap.get("type") == "table") {
      var tableInfo = YsTableInfo(blockMap);
      var cellMap =
          tableInfo.getCellMap(tableInfo.rowCount - 1, tableInfo.colCount - 1);
      int offset = 0;
      if (cellMap != null) {
        if (cellMap.get('type') == "image") {
          offset = 1;
        } else {
          offset = getYsTextLength(cellMap);
        }
      }
      return YsCursor.table(tree, blockIndex, tableInfo.rowCount - 1,
          tableInfo.colCount - 1, offset);
    }
    return YsCursor.text(tree, blockIndex, getYsTextLength(blockMap));
  }

  late YsTree tree;
  late BlockType blockType;
  late List<RelativePosition> positions;

  YsCursor.table(
      this.tree, int blockIndex, int rowIndex, int colIndex, int textOffset) {
    var tableMap = tree.yArray!.get(blockIndex) as YMap;
    var rows = tableMap.get("rows") as YArray;
    var row = rows.get(rowIndex) as YArray;
    var cell = row.get(colIndex);
    RelativePosition cellRelativePosition;
    if (cell.get("type") == "text") {
      var text = cell.get("text") as YText;
      cellRelativePosition =
          createRelativePositionFromTypeIndex(text, textOffset);
    } else {
      cellRelativePosition =
          createRelativePositionFromTypeIndex(row, colIndex, textOffset);
    }
    var relativePositions = [
      createRelativePositionFromTypeIndex(tree.yArray!, blockIndex),
      createRelativePositionFromTypeIndex(rows, rowIndex),
      createRelativePositionFromTypeIndex(row, colIndex),
      cellRelativePosition,
    ];
    positions = relativePositions;
    blockType = BlockType.table;
  }

  YsCursor.text(this.tree, int blockIndex, int offset) {
    var textMap = tree.yArray!.get(blockIndex) as YMap;
    var text = textMap.get("text") as YText;
    var relativePositions = [
      createRelativePositionFromTypeIndex(tree.yArray!, blockIndex),
      createRelativePositionFromTypeIndex(text, offset),
    ];
    blockType = BlockType.text;
    positions = relativePositions;
  }

  YsCursor.image(this.tree, int blockIndex, int offset) {
    var relativePositions = [
      createRelativePositionFromTypeIndex(tree.yArray!, blockIndex, offset),
    ];
    blockType = BlockType.image;
    positions = relativePositions;
  }

  YsCursor.line(this.tree, int blockIndex, int offset) {
    var relativePositions = [
      createRelativePositionFromTypeIndex(tree.yArray!, blockIndex, offset),
    ];
    blockType = BlockType.line;
    positions = relativePositions;
  }

  YsCursor.code(this.tree, int blockIndex, int offset) {
    var textMap = tree.yArray!.get(blockIndex) as YMap;
    var text = textMap.get("code") as YText;
    var relativePositions = [
      createRelativePositionFromTypeIndex(tree.yArray!, blockIndex),
      createRelativePositionFromTypeIndex(text, offset),
    ];
    blockType = BlockType.code;
    positions = relativePositions;
  }

  int? getBlockIndex() {
    if (positions.isEmpty) {
      return null;
    }
    var abs =
        createAbsolutePositionFromRelativePosition(positions.first, tree.yDoc);
    return abs?.index;
  }

  int? getTableTextOffset() {
    if (positions.length < 4) {
      return null;
    }
    var abs =
        createAbsolutePositionFromRelativePosition(positions[3], tree.yDoc);
    if (abs != null) {
      var blockIndex = getBlockIndex();
      var rowIndex = getTableRowIndex();
      var colIndex = getTableColIndex();
      if (blockIndex == null || rowIndex == null || colIndex == null) {
        return null;
      }
      var yMap =
          YsTable.of(tree.blocks[blockIndex]).getCellMap(rowIndex, colIndex);
      if (yMap?.get("type") == 'text') {
        return abs.index + abs.assoc;
      }
      return abs.assoc;
    } else {
      return null;
    }
  }

  int? getTextOffset() {
    switch (blockType) {
      case BlockType.code:
      case BlockType.text:
        if (positions.length < 2) {
          return null;
        }
        var abs =
            createAbsolutePositionFromRelativePosition(positions[1], tree.yDoc);
        return abs?.index;
      case BlockType.table:
        return getTableTextOffset();
      case BlockType.image:
      case BlockType.line:
        if (positions.isEmpty) {
          return null;
        }
        var abs =
            createAbsolutePositionFromRelativePosition(positions[0], tree.yDoc);
        return abs?.assoc;
    }
  }

  int? getTableColIndex() {
    if (blockType != BlockType.table) {
      return null;
    }
    if (positions.length < 3) {
      return null;
    }
    var abs =
        createAbsolutePositionFromRelativePosition(positions[2], tree.yDoc);
    return abs?.index;
  }

  DeleteFlag delete(int index, int length) {
    var blockIndex = getBlockIndex();
    if (blockIndex == null) {
      return DeleteFlag.error;
    }
    var blockMap = (tree.yArray!.get(blockIndex) as YMap);
    switch (blockType) {
      case BlockType.code:
        (blockMap.get("code") as YText).delete(index, length);
        return DeleteFlag.ok;
      case BlockType.text:
        (blockMap.get("text") as YText).delete(index, length);
        return DeleteFlag.ok;
      case BlockType.table:
        var rowIndex = getTableRowIndex();
        var colIndex = getTableColIndex();
        if (rowIndex == null || colIndex == null) {
          return DeleteFlag.error;
        }
        var rows = blockMap.get("rows") as YArray;
        var rowArr = rows.get(rowIndex) as YArray;
        var colMap = rowArr.get(colIndex) as YMap;
        if (colMap.get("type") == "text") {
          var yText = colMap.get("text") as YText?;
          yText?.delete(index, length);
        } else {
          if (index == 0 && length == 1) {
            return DeleteFlag.clearBlock;
          }
          return DeleteFlag.ok;
        }
        break;
      case BlockType.image:
        if (index == 0 && length == 1) {
          return DeleteFlag.clearBlock;
        }
        return DeleteFlag.skip;
      case BlockType.line:
        if (index == 0 && length == 1) {
          return DeleteFlag.clearBlock;
        }
        return DeleteFlag.skip;
    }
    return DeleteFlag.skip;
  }

  int? getTableRowIndex() {
    if (blockType != BlockType.table) {
      return null;
    }
    if (positions.length < 2) {
      return null;
    }
    var abs =
        createAbsolutePositionFromRelativePosition(positions[1], tree.yDoc);
    return abs?.index;
  }

  YsCursor copyWith({
    YsTree? tree,
    BlockType? blockType,
    List<RelativePosition>? positions,
  }) {
    var result = YsCursor(
      tree: tree ?? this.tree,
      blockType: blockType ?? this.blockType,
      positions: positions ?? [...this.positions],
    );

    return result;
  }

  YsCursor({
    required this.tree,
    required this.blockType,
    required this.positions,
  });
}

YsCursor createTableCursor(
    YsTree tree, int blockIndex, int rowIndex, int colIndex, int textOffset) {
  return YsCursor.table(tree, blockIndex, rowIndex, colIndex, textOffset);
}

YsCursor createBlockCursor(YsTree tree, int blockIndex, int offset) {
  return YsCursor.create(tree, blockIndex, offset);
}

YsCursor createTextCursor(YsTree tree, int blockIndex, int offset) {
  return YsCursor.text(tree, blockIndex, offset);
}

YsCursor createImageCursor(YsTree tree, int blockIndex, int offset) {
  return YsCursor.image(tree, blockIndex, offset);
}

YsCursor createLineCursor(YsTree tree, int blockIndex, int offset) {
  return YsCursor.line(tree, blockIndex, offset);
}

YsCursor createCodeCursor(YsTree tree, int blockIndex, int offset) {
  return YsCursor.code(tree, blockIndex, offset);
}
