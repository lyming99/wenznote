import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:wenznote/commons/widget/ignore_parent_pointer.dart';
import 'package:wenznote/commons/widget/popup_stack.dart';
import 'package:wenznote/editor/block/block.dart';
import 'package:wenznote/editor/block/element/element.dart';
import 'package:wenznote/editor/block/image/image_element.dart';
import 'package:wenznote/editor/block/table/table_range.dart';
import 'package:wenznote/editor/block/text/link.dart';
import 'package:wenznote/editor/block/text/text.dart';
import 'package:wenznote/editor/edit_controller.dart';
import 'package:wenznote/editor/widget/drop_menu.dart';
import 'package:wenznote/editor/widget/toggle_item.dart';

import '../../cursor/cursor.dart';
import '../image/image_block.dart';
import 'adjust_widget.dart';
import 'image_cell.dart';
import 'table_cell.dart';
import 'table_element.dart';
import 'text_cell.dart';

/// 表格块
/// ui 设计：逻辑、结构
/// layout 计算
/// buildWidget 帧数据：startRenderRow
class TableBlock extends WenBlock {
  EdgeInsets padding = const EdgeInsets.only(bottom: 20);

  /// 工具栏位置
  double toolButtonBottom = 12;
  double toolButtonTop = -12;

  ///最小单元格宽度
  double minCellWidth = 50.0;

  ///最小单元格高度
  double minCellHeight = 30.0;

  ///如果一行内所有cell的宽度加起来大于view的宽度，则此参数生效
  double maxCellWidth = 600.0;

  double cellPadding = 8.0;

  ///列宽
  List<double> columnWidths = [];

  ///列高
  List<double> rowHeights = [];

  ///表格数据
  WenTableElement tableElement;

  /// 行数据
  List<List<WenBlock>> rows = [];

  int _calcLength = 0;

  double borderWidth = 1;

  var tableController = TableController();

  double get horizontalOffset {
    return tableController.recordScrollOffset;
  }

  set horizontalOffset(double val) {
    tableController.recordScrollOffset = val;
    try {
      tableController.scrollController?.jumpTo(val);
    } catch (e) {}
  }

  Color get borderColor => const Color.fromARGB(255, 200, 200, 200);

  TableBlock({
    required super.context,
    required this.tableElement,
    required super.editController,
  }) {
    _initRows();
  }

  void _initRows() {
    var elementRows = tableElement.rows;
    List<List<WenBlock>> rows = [];
    if (elementRows != null) {
      var colCount = elementRows
          .map((e) => e.length)
          .reduce((value, element) => max(value, element));

      for (var elementRow in elementRows) {
        List<WenBlock> row = [];
        for (var elementCell in elementRow) {
          if (elementCell is WenTextElement) {
            row.add(TextTableCell(
              editController: editController,
              context: context,
              textElement: elementCell,
              tableBlock: this,
            ));
          } else if (elementCell is WenImageElement) {
            row.add(
              ImageTableCell(
                context: context,
                element: elementCell,
                tableBlock: this,
                editController: editController,
              )..tableBlock = this,
            );
          } else {
            row.add(
              TextTableCell(
                editController: editController,
                context: context,
                textElement: WenTextElement(),
                tableBlock: this,
              ),
            );
          }
        }
        while (row.length < colCount) {
          row.add(
            TextTableCell(
              editController: editController,
              context: context,
              textElement: WenTextElement(),
              tableBlock: this,
            ),
          );
        }
        rows.add(row);
      }
    }
    this.rows = rows;
    calcLength();
  }

  @override
  bool get canEmpty => false;

  @override
  bool get canIndent => false;

  void calcLength() {
    var len = 0;
    var rowCount = rows.length;
    for (var i = 0; i < rowCount; i++) {
      var columnCount = rows[i].length;
      for (var j = 0; j < columnCount; j++) {
        var cell = rows[i][j] as TableBaseCell;
        cell.offset = len;
        len += rows[i][j].length;
        len += 1;
      }
    }
    _calcLength = max(0, len - 1);
  }

  double get firstRowEditTop {
    return top + padding.top + toolButtonBottom;
  }

  double getRowHeight(int row) {
    return rows[row]
        .map((cell) => max(minCellHeight, cell.height + cellPadding * 2))
        .reduce((value, element) => max(value, element));
  }

  /// 计算第1个渲染行
  /// 如果返回-1，则表示越界，无需渲染
  int get startRenderRow {
    var rows = tableElement.rows;
    if (rows == null || rows.isEmpty || rows[0].isEmpty) {
      return 0;
    }
    var scrollOffset = editController.scrollOffset;
    if (scrollOffset >= firstRowEditTop) {
      var tableRectOffset = scrollOffset - firstRowEditTop;
      var rowOffset = 0.0;
      for (int i = 0; i < rows.length; i++) {
        var rowHeight = getRowHeight(i);
        if (rowOffset + rowHeight >= tableRectOffset) {
          return i;
        }
        rowOffset += rowHeight;
      }
    } else {
      //如果第一个在界面内可以返回0
      if (firstRowEditTop - scrollOffset < editController.visionHeight) {
        return 0;
      }
    }
    return 0;
  }

  ///获取第一个渲染行的顶部
  double getStartRenderRowTop() {
    var rows = tableElement.rows;
    if (rows == null || rows.isEmpty) {
      return 0;
    }
    var startRenderRow = this.startRenderRow;
    if (startRenderRow == -1) {
      return 0;
    }
    var top = padding.top + toolButtonBottom;
    for (int i = 0; i < startRenderRow; i++) {
      top += getRowHeight(i);
    }
    return top;
  }

  double get contentWidth => width - padding.left - padding.right;

  /// 计算cell原始宽高
  void calcOriginSize() {
    if (rows.isEmpty || rows[0].isEmpty) {
      return;
    }
    for (int i = 0; i < rows.length; i++) {
      for (var cell in rows[i]) {
        if (cell is TableBaseCell) {
          (cell as TableBaseCell).calcOriginSize(context);
        }
      }
    }
  }

  ///布局
  ///1.计算row是否在界面中
  ///2.如果row在界面中，则计算它的原始宽高
  ///3.通过原始宽高，minCellWidth，maxCellWidth来计算分配宽高
  ///4.计算总体高度height
  @override
  void layout(BuildContext context, Size viewSize) {
    /// 判断rows和columns是否为空
    if (isEmpty) {
      return;
    }
    calcHoverPosition();
    width = viewSize.width;

    ///对界面范围内的 cell 进行原始高度计算(无论宽度时的高度)
    calcOriginSize();

    /// 计算 table 初始列宽
    var maxOriginWidths = rows[0].map((e) {
      return min(
          maxCellWidth,
          max(((e as TableBaseCell).originWidth ?? 0) + cellPadding * 2,
              minCellWidth));
    }).toList();
    for (int i = 1; i < rowCount; i++) {
      for (int j = 0; j < colCount; j++) {
        double cellWidth = 0;
        try {
          cellWidth = ((rows[i][j] as TableBaseCell).originWidth ?? 0);
        } catch (e) {}
        var a = max(cellWidth + cellPadding * 2, minCellWidth);
        var b = min(maxCellWidth, a);
        maxOriginWidths[j] = max(b, maxOriginWidths[j]);
      }
    }

    /// 通过初始列宽分配列宽
    var allocWidths = maxOriginWidths.toList();
    var sum = allocWidths.reduce((value, element) => value + element);
    var allocAvg = (contentWidth - sum) / allocWidths.length;
    if (allocAvg > 0) {
      allocWidths = allocWidths.map((e) => e + allocAvg).toList();
    }
    columnWidths = allocWidths;

    /// 计算组件的渲染高度
    for (int i = 0; i < rows.length; i++) {
      for (int j = 0; j < columnWidths.length; j++) {
        try {
          rows[i][j].layout(context,
              Size(columnWidths[j] - cellPadding * 2, double.infinity));
        } catch (e) {}
      }
    }
    var rowHeights = List.filled(rows.length, 0.0);
    for (var i = 0; i < rows.length; i++) {
      rowHeights[i] = getRowHeight(i);
    }
    this.rowHeights = rowHeights;

    /// 计算最终高度
    height = rowHeights.reduce((value, element) => value + element) +
        toolButtonBottom +
        padding.top +
        padding.bottom;
    calcHorizontalScroll();
  }

  void calcHoverPosition() {
    for (var row in rows) {
      for (var cell in row) {
        if (cell.hoverPosition != null) {
          cell.hoverPosition = null;
          cell.relayoutFlag = true;
          break;
        }
      }
    }
    var position = hoverPosition;
    if (position == null) {
      return;
    }

    var cell = getCell(position.offset);
    if (cell == null) {
      return;
    }
    var cellOffset = TableBaseCell.of(cell).offset;
    cell.hoverPosition = TextPosition(offset: position.offset - cellOffset);
    cell.relayoutFlag = true;
  }

  ///通过 table element 的 rows 来进行渲染
  @override
  Widget buildWidget(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: TableContainer(
        tableBlock: this,
        tableController: tableController,
      ),
    );
  }

  @override
  List<PopupPositionWidget> buildFloatWidgets() {
    editController.layoutCurrentBlock(this);
    return [
      // 悬浮工具栏
      if (editController.cursorState.cursorPosition?.block == this &&
          editController.editable == true)
        PopupPositionWidget(
          left: editController.padding.left,
          right: editController.padding.right,
          top:
              (top - editController.scrollOffset + editController.padding.top) +
                  padding.top +
                  toolButtonTop,
          height: toolButtonBottom - toolButtonTop,
          child: Row(
            children: [
              ToggleItem(
                itemBuilder: (BuildContext context, bool checked, bool hover,
                    bool pressed) {
                  return Container(
                    color: hover ? theme.fontColor.withOpacity(0.1) : null,
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.grid_view,
                      color: theme.fontColor.withOpacity(0.8),
                    ),
                  );
                },
                onTap: (context) {
                  showAdjustTableDialog(context);
                },
              ),
              ToggleItem(
                itemBuilder: (BuildContext context, bool checked, bool hover,
                    bool pressed) {
                  return Container(
                    color: hover ? theme.fontColor.withOpacity(0.1) : null,
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.format_align_left,
                      color: theme.fontColor.withOpacity(0.8),
                    ),
                  );
                },
                onTap: (context) {
                  editController.setTableAlignment(this, "left");
                },
              ),
              ToggleItem(
                itemBuilder: (BuildContext context, bool checked, bool hover,
                    bool pressed) {
                  return Container(
                    color: hover ? theme.fontColor.withOpacity(0.1) : null,
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.format_align_center,
                      color: theme.fontColor.withOpacity(0.8),
                    ),
                  );
                },
                onTap: (context) {
                  editController.setTableAlignment(this, "center");
                },
              ),
              ToggleItem(
                itemBuilder: (BuildContext context, bool checked, bool hover,
                    bool pressed) {
                  return Container(
                    color: hover ? theme.fontColor.withOpacity(0.1) : null,
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.format_align_right,
                      color: theme.fontColor.withOpacity(0.8),
                    ),
                  );
                },
                onTap: (context) {
                  editController.setTableAlignment(this, "right");
                },
              ),
              Expanded(child: Container()),
              ToggleItem(
                itemBuilder: (BuildContext context, bool checked, bool hover,
                    bool pressed) {
                  return Container(
                    color: hover ? theme.fontColor.withOpacity(0.1) : null,
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.delete_outline,
                      color: theme.fontColor.withOpacity(0.8),
                    ),
                  );
                },
                onTap: (context) {
                  editController.deleteTable();
                },
              ),
            ],
          ),
        ),
    ];
  }

  bool isCellVision(Offset widgetItemOffset, {Size? size}) {
    var visionRect = Rect.fromCenter(
        center: Offset(
            editController.visionWidth / 2, editController.visionHeight / 2),
        width: editController.visionWidth * 2,
        height: editController.visionHeight * 2);
    if (size != null) {
      return (widgetItemOffset & size).overlaps(visionRect);
    }
    return visionRect.contains(widgetItemOffset);
  }

  void createCells(List<Widget> stackItems) {
    var cellTop = padding.top + toolButtonBottom;
    for (int rowIndex = 0; rowIndex < rowCount; rowIndex++) {
      var row = rows[rowIndex];
      var cellLeft = padding.left - horizontalOffset;
      for (int colIndex = 0; colIndex < colCount; colIndex++) {
        //背景
        if (!isCellVision(
            Offset(cellLeft, cellTop)
                .translate(0, top - editController.scrollOffset),
            size: Size(columnWidths[colIndex], rowHeights[rowIndex]))) {
          var cell = row[colIndex];
          (row[colIndex] as TableBaseCell).cellTop =
              cellTop + getCellRowTopOffset(rowIndex, colIndex);
          cellLeft += columnWidths[colIndex];
          continue;
        }
        stackItems.add(Positioned(
          left: cellLeft,
          top: cellTop,
          width: columnWidths[colIndex],
          height: rowHeights[rowIndex],
          child: Container(
            color: rowIndex % 2 == 0 ? Colors.grey.withOpacity(0.1) : null,
          ),
        ));

        //cell block
        stackItems.add((row[colIndex] as TableBaseCell).buildCellWidget(
          context,
          cellTop + getCellRowTopOffset(rowIndex, colIndex),
          cellLeft + getCellColLeftOffset(rowIndex, colIndex),
          minCellWidth - cellPadding * 2,
          minCellHeight - cellPadding * 2,
          alignment: getColAlignment(colIndex),
        ));
        cellLeft += columnWidths[colIndex];
      }
      cellTop += rowHeights[rowIndex];
    }
  }

  void createRowLines(List<Widget> stackItems) {
    //线条
    var cellTop = padding.top + toolButtonBottom;
    for (int rowIndex = 0; rowIndex < rows.length; rowIndex++) {
      //线条
      var cellLeft = padding.left;
      stackItems.add(Positioned(
        left: cellLeft,
        top: cellTop - 1,
        width: tableContentWidth,
        height: borderWidth,
        child: Container(
          color: borderColor,
        ),
      ));
      cellTop += rowHeights[rowIndex];
    }
    //线条
    var cellLeft = padding.left;
    stackItems.add(Positioned(
      left: cellLeft,
      top: cellTop - 1,
      width: tableContentWidth,
      height: borderWidth,
      child: Container(
        color: borderColor,
      ),
    ));
  }

  void createColLines(List<Widget> stackItems) {
    var colOffset = padding.left - horizontalOffset;
    for (var i = 0; i < colCount; i++) {
      stackItems.add(Positioned(
        left: colOffset,
        top: toolButtonBottom + padding.top,
        width: borderWidth,
        height: tableContentHeight,
        child: Container(
          color: borderColor,
        ),
      ));
      colOffset += columnWidths[i];
    }
    stackItems.add(Positioned(
      left: colOffset - borderWidth,
      top: toolButtonBottom + padding.top,
      width: borderWidth,
      height: tableContentHeight,
      child: Container(
        color: borderColor,
      ),
    ));
  }

  /// copy table item
  /// if table item > 1,copy max columns and rows to a new table
  @override
  WenElement copyElement(TextPosition start, TextPosition end) {
    var startRow = getRowIndex(start.offset);
    var startCol = getColIndex(startRow, start.offset);
    var endRow = getRowIndex(end.offset);
    var endCol = getColIndex(endRow, end.offset);
    if (startRow == endRow && startCol == endCol) {
      var offset = TableBaseCell.of(rows[startRow][startCol]).offset;
      return rows[startRow][startCol].copyElement(
        TextPosition(offset: start.offset - offset, affinity: start.affinity),
        TextPosition(offset: end.offset - offset, affinity: end.affinity),
      );
    }
    var startOffset = start.offset;
    var endOffset = end.offset;
    List<List<WenElement>> copyRows = [];
    var startRowIndex = 0;
    visitSelectCellWithRange(
        startOffset: start.offset,
        endOffset: end.offset,
        init: (int startRow, int startCol, int endRow, int endCol) {
          for (int i = startRow; i <= endRow; i++) {
            copyRows.add([]);
          }
          startRowIndex = startRow;
        },
        visit: (rowIndex, colIndex) {
          var cell = rows[rowIndex][colIndex];
          var cellStartOffset = TableBaseCell.of(cell).offset;
          var cellEndOffset = cellStartOffset + cell.length;
          var mixStart = max(cellStartOffset, startOffset);
          var mixEnd = min(cellEndOffset, endOffset);
          if (mixStart <= mixEnd) {
            copyRows[rowIndex - startRowIndex].add(cell.copyElement(
                TextPosition(offset: mixStart - cellStartOffset),
                TextPosition(offset: mixEnd - cellStartOffset)));
          }
          return true;
        });

    return WenTableElement(
      rows: copyRows,
    );
  }

  @override
  bool get needClearStyle {
    var offset =
        editController.cursorState.cursorPosition?.textPosition?.offset ?? 0;
    var cell = getCell(offset);
    return cell?.needClearStyle ?? false;
  }

  @override
  int deletePosition(TextPosition textPosition) {
    if (isEmpty) {
      return 0;
    }
    var rowIndex = getRowIndex(textPosition.offset);
    var colIndex = getColIndex(rowIndex, textPosition.offset);
    var cell = rows[rowIndex][colIndex];
    if (cell is TextTableCell) {
      if (cell.length == 0) {
        if (cell.needClearStyle) {
          cell.textElement.clearStyle();
          cell.relayoutFlag = true;
          tableElement.remarkUpdated();
          return 0;
        }
      }
    }
    var len = length;
    var cellOffset = (cell as TableBaseCell).offset;
    var deleteOffset = textPosition.offset - cellOffset;
    if (deleteOffset > 0) {
      cell.deletePosition(TextPosition(
        offset: deleteOffset,
        affinity: textPosition.affinity,
      ));
      resetEmptyCellToTextElement(
          startRow: rowIndex,
          endRow: rowIndex,
          startCol: colIndex,
          endCol: colIndex);
    }

    calcLength();
    relayoutFlag = true;
    element.remarkUpdated();
    if (len == length) {
      return 1;
    }
    return len - length;
  }

  void resetEmptyCellToTextElement({
    int startRow = 0,
    int endRow = -1,
    int startCol = 0,
    int endCol = -1,
  }) {
    if (endRow == -1) {
      endRow = rowCount - 1;
    }
    if (endCol == -1) {
      endCol = colCount - 1;
    }
    for (int i = startRow; i <= endRow; i++) {
      for (int j = startCol; j <= endCol; j++) {
        var cell = rows[i][j];
        if (cell is! TextBlock) {
          if (cell.isEmpty) {
            var element = WenTextElement();
            tableElement.rows![i][j] = element;
            rows[i][j] = TextTableCell(
                editController: editController,
                context: context,
                textElement: element,
                tableBlock: this);
          }
        }
      }
    }
  }

  @override
  void deleteRange(TextPosition start, TextPosition end) {
    if (isEmpty) {
      return;
    }
    visitSelectCellWithRange(
      startOffset: start.offset,
      endOffset: end.offset,
      visit: (int row, int col) {
        var cell = rows[row][col];
        var cellOffset = (cell as TableBaseCell).offset;
        if (start.offset <= cellOffset + cell.length &&
            end.offset > cellOffset) {
          var startPos = max(0, start.offset - cellOffset);
          var endPos = min(cellOffset + cell.length, end.offset - cellOffset);
          cell.deleteRange(
              TextPosition(
                offset: startPos,
                affinity: start.affinity,
              ),
              TextPosition(
                offset: endPos,
                affinity: end.affinity,
              ));
        }
        return true;
      },
    );
    resetEmptyCellToTextElement();
    calcLength();
    relayoutFlag = true;
    element.remarkUpdated();
  }

  int get rowCount => rows.length;

  int get colCount => rows.isEmpty ? 0 : rows[0].length;

  @override
  WenElement get element => tableElement;

  @override
  Rect? getCursorRect(TextPosition textPosition) {
    if (isEmpty) {
      return null;
    }
    var rowIndex = getRowIndex(textPosition.offset);
    var colIndex = getColIndex(rowIndex, textPosition.offset);
    var cellOffset = (rows[rowIndex][colIndex] as TableBaseCell).offset;
    var rect = rows[rowIndex][colIndex].getCursorRect(TextPosition(
      offset: textPosition.offset - cellOffset,
      affinity: textPosition.affinity,
    ));
    return rect?.translate(
        getColumnLeft(colIndex) +
            getCellColLeftOffset(rowIndex, colIndex) -
            horizontalOffset,
        getRowTop(rowIndex) + getCellRowTopOffset(rowIndex, colIndex));
  }

  double get tableContentWidth => width - padding.left - padding.right;

  double get tableContentHeight =>
      height - padding.top - padding.bottom - toolButtonBottom;

  double get tableRealWidth =>
      padding.left +
      padding.right +
      (columnWidths.isEmpty
          ? 0
          : columnWidths.reduce((value, element) => value + element));

  double getCellColLeftOffset(int row, int col) {
    return cellPadding;
  }

  String? getColAlignment(int col) {
    var alignments = tableElement.alignments;
    if (alignments == null) {
      return null;
    }
    return alignments[col];
  }

  double getCellRowTopOffset(int row, int col) {
    var cell = rows[row][col];
    var rowHeight = row < rowHeights.length ? rowHeights[row] : minCellHeight;
    return (rowHeight - cellPadding * 2 - cell.height) / 2 + cellPadding;
  }

  @override
  TextPosition? getPositionForOffset(Offset offset) {
    // 计算x和y得到 offset
    if (rows.isEmpty || rows[0].isEmpty) {
      return const TextPosition(offset: 0);
    }
    var clickOffset = offset
        .translate(-padding.left, -padding.top)
        .translate(horizontalOffset, -toolButtonBottom);
    var cellTop = 0.0;
    var rowIndex = rows.length - 1;
    for (var i = 0; i < rows.length; i++) {
      var rh = getRowHeight(i);
      if (clickOffset.dy < cellTop + rh) {
        rowIndex = i;
        break;
      } else {
        if (i == rows.length - 1) {
          break;
        }
      }
      cellTop += rh;
    }
    var colIndex = rows[0].length - 1;
    var cellLeft = 0.0;
    for (var i = 0; i < rows[0].length; i++) {
      var rw = columnWidths[i];
      if (clickOffset.dx < cellLeft + rw) {
        colIndex = i;
        break;
      } else {
        if (i == rows[0].length - 1) {
          break;
        }
      }
      cellLeft += rw;
    }
    var curCell = rows[rowIndex][colIndex];
    var cellOffset = (curCell as TableBaseCell).offset;
    var ret = curCell.getPositionForOffset(clickOffset
        .translate(-cellLeft, -cellTop)
        .translate(-getCellColLeftOffset(rowIndex, colIndex),
            -getCellRowTopOffset(rowIndex, colIndex)));
    if (ret != null) {
      return TextPosition(
        offset: ret.offset + cellOffset,
        affinity: ret.affinity,
      );
    }
    return null;
  }

  @override
  bool get isEmpty => rows.isEmpty || rows[0].isEmpty;

  @override
  TextRange? getWordBoundary(TextPosition textPosition) {
    if (isEmpty) {
      return null;
    }
    var textOffset = textPosition.offset;
    var y = getRowIndex(textOffset);
    var x = getColIndex(y, textOffset);
    var item = rows[y][x];
    var offset = (item as TableBaseCell).offset;
    var range = item.getWordBoundary(TextPosition(
      offset: textPosition.offset - offset,
      affinity: textPosition.affinity,
    ));
    if (range == null) {
      return null;
    }
    return TextRange(start: range.start + offset, end: range.end + offset);
  }

  @override
  TextRange? getLineBoundary(TextPosition textPosition) {
    if (isEmpty) {
      return null;
    }
    var textOffset = textPosition.offset;
    var y = getRowIndex(textOffset);
    var x = getColIndex(y, textOffset);
    var item = rows[y][x];
    var offset = (item as TableBaseCell).offset;
    var range = item.getLineBoundary(TextPosition(
      offset: textPosition.offset - offset,
      affinity: textPosition.affinity,
    ));
    if (range == null) {
      return null;
    }
    return TextRange(start: range.start + offset, end: range.end + offset);
  }

  int getRowIndex(int textOffset) {
    if (isEmpty) {
      return 0;
    }
    int left = 0;
    int right = rows.length - 1;
    int ans = right;
    while (left <= right) {
      int mid = (left + right) >> 1;
      var cell = rows[mid][0];
      var cellOffset = (cell as TableBaseCell).offset;
      if (textOffset >= cellOffset) {
        left = mid + 1;
        ans = mid;
      } else {
        right = mid - 1;
      }
    }
    return ans;
  }

  int getColIndex(int rowIndex, int textOffset) {
    var row = rows[rowIndex];
    int left = 0;
    int right = row.length - 1;
    int ans = right;
    while (left <= right) {
      int mid = (left + right) >> 1;
      var cell = row[mid];
      var cellOffset = (cell as TableBaseCell).offset;
      if (textOffset >= cellOffset) {
        ans = mid;
        left = mid + 1;
      } else {
        right = mid - 1;
      }
    }
    return ans;
  }

  double getRowTop(int row) {
    double ans = toolButtonBottom + padding.top;
    for (var i = 0; i < row && i < rowHeights.length; i++) {
      ans += rowHeights[i];
    }
    return ans;
  }

  double getColumnLeft(int column) {
    double ans = padding.left;
    var colWidths = columnWidths;
    for (var i = 0; i < column && i < colWidths.length; i++) {
      ans += colWidths[i];
    }
    return ans;
  }

  @override
  void inputText(EditController controller, TextEditingValue text,
      {bool isComposing = false}) {
    if (isEmpty) {
      return;
    }
    var position = controller.cursorState.cursorPosition;
    if (position == null) {
      return;
    }
    var textPosition = position.textPosition;
    if (textPosition == null) {
      return;
    }
    int rowIndex = getRowIndex(textPosition.offset);
    int columnIndex = getColIndex(rowIndex, textPosition.offset);
    var cell = rows[rowIndex][columnIndex];
    var cellTextOffset = TextPosition(
        offset: textPosition.offset - (cell as TableBaseCell).offset,
        affinity: textPosition.affinity);
    (cell as TableBaseCell).inputCellText(
        controller, this, cellTextOffset, text,
        isComposing: isComposing);
    element.remarkUpdated();
  }

  @override
  int get length => _calcLength;

  @override
  WenBlock? mergeBlock(WenBlock endBlock) {
    return null;
  }

  @override
  bool get catchEnter => true;

  @override
  WenBlock splitBlock(TextPosition textPosition) {
    return TextBlock(
        editController: editController,
        context: context,
        textElement: WenTextElement());
  }

  @override
  List<TextBox> getBoxesForSelection(TextSelection selection) {
    if (isEmpty) {
      return [];
    }
    List<double> rowOffsets = List.filled(rowCount, 0.0);
    List<double> colOffsets = List.filled(colCount, 0.0);
    rowOffsets[0] = padding.top + toolButtonBottom;
    colOffsets[0] = padding.left;
    var ret = <TextBox>[];
    var selectStart = selection.start;
    var selectEnd = selection.end;
    visitSelectCellWithRange(
      startOffset: selection.start,
      endOffset: selection.end,
      init: (startRow, startCol, endRow, endCol) {
        for (int i = 1; i <= endRow; i++) {
          rowOffsets[i] = rowHeights[i - 1] + rowOffsets[i - 1];
        }
        for (int i = 1; i <= endCol; i++) {
          colOffsets[i] = columnWidths[i - 1] + colOffsets[i - 1];
        }
      },
      visit: (row, col) {
        var colOffset = colOffsets[col];
        var rowOffset = rowOffsets[row];
        var cell = rows[row][col];
        var cellTextOffset = (cell as TableBaseCell).offset;
        if (selectStart <= cellTextOffset + cell.length &&
            selectEnd > cellTextOffset) {
          var boxes = cell.getBoxesForSelection(TextSelection(
            baseOffset: max(0, selectStart - cellTextOffset),
            extentOffset: min(
              cellTextOffset + cell.length,
              selectEnd - cellTextOffset,
            ),
          ));
          var topOffset = getCellRowTopOffset(row, col);
          var leftOffset = getCellColLeftOffset(row, col);
          ret.addAll(
            boxes
                .map((e) => TextBox.fromLTRBD(
                      e.left + colOffset + leftOffset - horizontalOffset,
                      e.top + rowOffset + topOffset,
                      e.right + colOffset + leftOffset - horizontalOffset,
                      e.bottom + rowOffset + topOffset,
                      TextDirection.ltr,
                    ))
                .toList(),
          );
        }
        return true;
      },
    );
    return ret;
  }

  @override
  bool get canSelectAll => true;

  @override
  bool selectAll() {
    var cursorPos = editController.cursorState.cursorPosition;
    if (cursorPos == null) {
      return false;
    }
    var cursorTextPos = cursorPos.textPosition;
    if (cursorTextPos == null) {
      return false;
    }
    var cellBlock = getCell(cursorTextPos.offset);
    if (cellBlock == null) {
      return false;
    }
    var selectState = editController.selectState;
    if (selectState.selectLength >= cellBlock.length) {
      return false;
    }
    var cellOffset = TableBaseCell.of(cellBlock).offset;
    editController
        .recordSelectStart(getCursorPosition(TextPosition(offset: cellOffset)));
    editController.recordSelectEnd(
        getCursorPosition(TextPosition(offset: cellOffset + cellBlock.length)));
    return true;
  }

  WenBlock? getCell(int textOffset) {
    int rowIndex = getRowIndex(textOffset);
    if (rowIndex >= rowCount) {
      return null;
    }
    int colIndex = getColIndex(rowIndex, textOffset);
    if (colIndex >= colCount) {
      return null;
    }
    return rows[rowIndex][colIndex];
  }

  @override
  bool toUp() {
    var textPos = editController.cursorState.cursorPosition?.textPosition;
    if (textPos == null) {
      return true;
    }
    var rowIndex = getRowIndex(textPos.offset);
    var colIndex = getColIndex(rowIndex, textPos.offset);
    var cell = rows[rowIndex][colIndex];
    var cellOffset = TableBaseCell.of(cell).offset;
    var range =
        cell.getLineBoundary(TextPosition(offset: textPos.offset - cellOffset));
    if (range == null) {
      return true;
    }
    if (range.start == 0 || range.start == -1) {
      if (rowIndex == 0) {
        //进入上一个block
        if (blockIndex > 0) {
          var preBlock = editController.blockManager.blocks[blockIndex - 1];
          var start = preBlock.getLineBoundary(preBlock.endPosition)?.start;
          if (start != null) {
            if (start == -1) {
              start = 0;
            }
            //1.得到上一个行的 lineBoundary centerY
            //2.重新计算心的 position
            var centerY =
                preBlock.getCursorRect(TextPosition(offset: start))?.center.dy;
            if (centerY != null) {
              centerY += preBlock.top - editController.scrollOffset;
              var x = editController.cursorRecord.recordWindowX;
              var pos = editController.getCursorPosition(Offset(x, centerY));
              editController.toPosition(pos, false);
              editController.scrollToCursorPosition();
              return true;
            }
          }
        }
      } else {
        //进入上一个cell
        var upCell = rows[rowIndex - 1][colIndex];
        var start = upCell.getLineBoundary(upCell.endPosition)?.start;
        if (start != null) {
          if (start == -1) {
            start = 0;
          }
          //1.得到上一个行的 lineBoundary centerY
          //2.重新计算心的 position
          var centerY = getCursorRect(
                  TextPosition(offset: start + TableBaseCell.of(upCell).offset))
              ?.center
              .dy;
          if (centerY != null) {
            centerY += top - editController.scrollOffset;
            var x = editController.cursorRecord.recordWindowX;
            var pos = editController.getCursorPosition(Offset(x, centerY));
            editController.toPosition(pos, false);
            return true;
          }
        }
      }
    } else {
      var start =
          cell.getLineBoundary(TextPosition(offset: range.start - 1))?.start;
      if (start != null) {
        if (start == -1) {
          start = 0;
        }
        //1.得到上一个行的 lineBoundary centerY
        //2.重新计算心的 position
        var centerY =
            getCursorRect(TextPosition(offset: start + cellOffset))?.center.dy;
        if (centerY != null) {
          centerY += top - editController.scrollOffset;
          var x = editController.cursorRecord.recordWindowX;
          var pos = editController.getCursorPosition(Offset(x, centerY));
          editController.toPosition(pos, false);
          return true;
        }
      }
    }
    editController.scrollToCursorPosition();
    return true;
  }

  @override
  bool toDown() {
    var textPos = editController.cursorState.cursorPosition?.textPosition;
    if (textPos == null) {
      return true;
    }
    var rowIndex = getRowIndex(textPos.offset);
    var colIndex = getColIndex(rowIndex, textPos.offset);
    var cell = rows[rowIndex][colIndex];
    var cellOffset = TableBaseCell.of(cell).offset;
    var range =
        cell.getLineBoundary(TextPosition(offset: textPos.offset - cellOffset));
    if (range == null) {
      return true;
    }
    if (range.end == cell.length ||
        range.end == -1 ||
        rowCount - 1 == rowIndex) {
      if (rowIndex + 1 >= rowCount) {
        //进入下一个block
        if (blockIndex < editController.blockManager.blocks.length - 1) {
          var nextBlock = editController.blockManager.blocks[blockIndex + 1];
          var start = nextBlock.getLineBoundary(nextBlock.startPosition)?.start;
          if (start != null) {
            if (start == -1) {
              start = 0;
            }
            //1.得到上一个行的 lineBoundary centerY
            //2.重新计算心的 position
            var centerY =
                nextBlock.getCursorRect(TextPosition(offset: start))?.center.dy;
            if (centerY != null) {
              centerY += nextBlock.top - editController.scrollOffset;
              var x = editController.cursorRecord.recordWindowX;
              var pos = editController.getCursorPosition(Offset(x, centerY));
              editController.toPosition(pos, false);
            }
          }
        }
      } else {
        //进入下一个cell
        var downCell = rows[rowIndex + 1][colIndex];
        var start = downCell.getLineBoundary(downCell.startPosition)?.start;
        if (start != null) {
          if (start == -1) {
            start = 0;
          }
          //1.得到上一个行的 lineBoundary centerY
          //2.重新计算心的 position
          var centerY = getCursorRect(TextPosition(
                  offset: start + TableBaseCell.of(downCell).offset))
              ?.center
              .dy;
          if (centerY != null) {
            centerY += top - editController.scrollOffset;
            var x = editController.cursorRecord.recordWindowX;
            var pos = editController.getCursorPosition(Offset(x, centerY));
            editController.toPosition(pos, false);
          }
        }
      }
    } else {
      var start =
          cell.getLineBoundary(TextPosition(offset: range.end + 1))?.start;
      if (start != null) {
        if (start == -1) {
          start = 0;
        }
        //1.得到下一行的 lineBoundary centerY
        //2.重新计算心的 position
        var centerY =
            getCursorRect(TextPosition(offset: start + cellOffset))?.center.dy;
        if (centerY != null) {
          centerY += top - editController.scrollOffset;
          var x = editController.cursorRecord.recordWindowX;
          var pos = editController.getCursorPosition(Offset(x, centerY));
          editController.toPosition(pos, false);
        }
      }
    }
    return true;
  }

  void toCellPos(int rowIndex, int colIndex) {
    editController.layoutCurrentBlock(this);
    var offset = (rows[rowIndex][colIndex] as TableBaseCell).offset;
    var curPos = getCursorPosition(TextPosition(offset: offset));
    editController.toPosition(curPos, true);
  }

  void insertRow(int rowIndex, int colIndex) {
    if (editController.insertRow(this, rowIndex, colIndex)) {
      return;
    }
    if (rowIndex >= 0 && rowIndex <= rows.length) {
      var insertRow = <WenBlock>[];
      for (int i = 0; i < colCount; i++) {
        insertRow.add(TextTableCell(
          editController: editController,
          context: context,
          textElement: WenTextElement(),
          tableBlock: this,
        ));
      }
      rows.insert(
        rowIndex,
        insertRow,
      );
      calcLength();
      toCellPos(rowIndex, colIndex);
      tableElement.rows =
          rows.map((e) => e.map((cell) => cell.element).toList()).toList();
      element.remarkUpdated();
      editController.record();
    }
  }

  int getCursorTextOffset() {
    return editController.cursorState.cursorPosition?.textPosition?.offset ?? 0;
  }

  int getSelectStartTextOffset() {
    if (editController.selectState.hasSelect) {
      if (editController.selectState.realStart?.block == this) {
        return editController.selectState.realStart?.textPosition?.offset ?? 0;
      }
      return 0;
    }
    return getCursorTextOffset();
  }

  int getSelectEndTextOffset() {
    if (editController.selectState.hasSelect) {
      if (editController.selectState.realEnd?.block == this) {
        return editController.selectState.realEnd?.textPosition?.offset ?? 0;
      }
    }
    return getCursorTextOffset();
  }

  void addRowOnPrevious() {
    var textOffset = getCursorTextOffset();
    var rowIndex = getRowIndex(textOffset);
    if (rowIndex >= 0 && rowIndex < rows.length) {
      int colIndex = getColIndex(rowIndex, textOffset);
      insertRow(rowIndex, colIndex);
    }
  }

  void addRowOnNext() {
    var textOffset = getCursorTextOffset();
    var rowIndex = getRowIndex(textOffset);
    if (rowIndex >= 0 && rowIndex < rows.length) {
      int colIndex = getColIndex(rowIndex, textOffset);
      insertRow(rowIndex + 1, colIndex);
    }
  }

  void insertCol(int rowIndex, int colIndex) {
    if (editController.insertCol(this, rowIndex, colIndex)) {
      return;
    }
    if (rowIndex >= 0 && rowIndex <= rows.length) {
      for (int i = 0; i < rowCount; i++) {
        rows[i].insert(
            colIndex,
            TextTableCell(
              editController: editController,
              context: context,
              textElement: WenTextElement(),
              tableBlock: this,
            ));
      }
      calcLength();
      toCellPos(rowIndex, colIndex);
      tableElement.rows =
          rows.map((e) => e.map((cell) => cell.element).toList()).toList();
      element.remarkUpdated();
      editController.record();
    }
  }

  void addColOnPrevious() {
    var textOffset = getCursorTextOffset();
    var rowIndex = getRowIndex(textOffset);
    if (rowIndex >= 0 && rowIndex < rows.length) {
      int colIndex = getColIndex(rowIndex, textOffset);
      insertCol(rowIndex, colIndex);
    }
  }

  void addColOnNext() {
    var textOffset = getCursorTextOffset();
    var rowIndex = getRowIndex(textOffset);
    if (rowIndex >= 0 && rowIndex < rows.length) {
      int colIndex = getColIndex(rowIndex, textOffset);
      insertCol(rowIndex, colIndex + 1);
    }
  }

  void deleteRow() {
    if (rowCount == 1) {
      editController.deleteTable();
      return;
    }
    var startOffset = getSelectStartTextOffset();
    var endOffset = getSelectEndTextOffset();
    var startRowIndex = getRowIndex(startOffset);
    var endRowIndex = getRowIndex(endOffset);
    int colIndex = getColIndex(startRowIndex, startOffset);
    rows.removeRange(startRowIndex, endRowIndex + 1);
    if (isEmpty) {
      editController.deleteTable();
      return;
    }
    calcLength();
    toCellPos(min(rowCount - 1, startRowIndex), colIndex);
    tableElement.rows =
        rows.map((e) => e.map((cell) => cell.element).toList()).toList();
    element.remarkUpdated();
    editController.record();
  }

  void deleteCol() {
    if (colCount == 1) {
      editController.deleteTable();
      return;
    }
    var startOffset = getSelectStartTextOffset();
    var endOffset = getSelectEndTextOffset();
    var startRowIndex = getRowIndex(startOffset);
    var endRowIndex = getRowIndex(endOffset);
    int startColIndex = getColIndex(startRowIndex, startOffset);
    int endColIndex = getColIndex(endRowIndex, endOffset);
    for (int i = 0; i < rows.length; i++) {
      rows[i].removeRange(startColIndex, endColIndex + 1);
    }
    if (isEmpty) {
      editController.deleteTable();
      return;
    }
    var alignments = tableElement.alignments;
    if (alignments != null) {
      var keys = alignments.keys.toList();
      for (var key in keys) {
        if (key > endColIndex) {
          var value = alignments.remove(key);
          alignments[key - 1] = "$value";
        } else if (key >= startColIndex) {
          alignments.remove(key);
        }
      }
    }
    calcLength();
    toCellPos(startRowIndex, min(colCount - 1, startColIndex));
    tableElement.rows =
        rows.map((e) => e.map((cell) => cell.element).toList()).toList();
    element.remarkUpdated();
    editController.record();
  }

  void deleteTable() {
    var index = blockIndex;
    var top = this.top;
    var textBlock = TextBlock(
      context: context,
      textElement: WenTextElement(),
      editController: editController,
    )..top = top;
    editController.blockManager.blocks[index] = textBlock;
    editController
        .layoutCurrentBlock(editController.blockManager.blocks[index]);
    editController.toPosition(textBlock.startCursorPosition, true);
    element.remarkUpdated();
    editController.record();
  }

  TextRange? getSelectRange() {
    var startOffset =
        editController.cursorState.cursorPosition?.textPosition?.offset ?? 0;
    var endOffset = startOffset;
    if (editController.selectState.hasSelect) {
      var selectStart = editController.selectState.realStart!;
      var selectEnd = editController.selectState.realEnd!;
      int selectStartBlockIndex = selectStart.blockIndex!;
      int selectEndBlockIndex = selectEnd.blockIndex!;
      int thisBlockIndex = blockIndex;
      if (thisBlockIndex < selectStartBlockIndex ||
          thisBlockIndex > selectEndBlockIndex) {
        return null;
      }
      startOffset = thisBlockIndex == selectStartBlockIndex
          ? selectStart.textPosition!.offset
          : 0;
      endOffset = thisBlockIndex == selectEndBlockIndex
          ? selectEnd.textPosition!.offset
          : length;
    }
    return TextRange(start: startOffset, end: endOffset);
  }

  TableRange? getSelectCellRange() {
    var range = getSelectRange();
    if (range == null) {
      return null;
    }
    var startOffset = range.start;
    var endOffset = range.end;
    var startRowIndex = getRowIndex(startOffset);
    var endRowIndex = getRowIndex(endOffset);
    var startColIndex = getColIndex(startRowIndex, startOffset);
    var endColIndex = getColIndex(endRowIndex, endOffset);
    return TableRange(
        startRowIndex: startRowIndex,
        endRowIndex: endRowIndex,
        startColIndex: startColIndex,
        endColIndex: endColIndex);
  }

  void setColAlignment(String? alignment, int colIndex) {
    var alignments = tableElement.alignments;
    alignments ??= HashMap();
    if (alignment == null) {
      alignments.remove(colIndex);
    } else {
      alignments[colIndex] = alignment;
    }
    tableElement.alignments = alignments;
  }

  void setAlignment(String? alignment) {
    var selectRange = getSelectCellRange();
    if (selectRange != null) {
      for (int i = selectRange.startColIndex;
          i <= selectRange.endColIndex;
          i++) {
        setColAlignment(alignment, i);
      }
      relayoutFlag = true;
      editController.layoutCurrentBlock(this);
      editController.refreshCursorPosition();
      element.remarkUpdated();
    }
  }

  void showAdjustTableDialog(BuildContext context) async {
    // 调整表格
    bool hasValue = false;
    int newColCount = 0;
    int newRowCount = 0;
    await showCustomDropMenu(
        context: context,
        // anchor: getCursorRect(TextPosition(offset: 0)),
        width: 120,
        height: 240,
        builder: (context) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 2,
                  // blurStyle: BlurStyle.outer,
                  color: Colors.grey.shade500,
                ),
              ],
            ),
            child: TableAdjustGridWidget(
              defaultColCount: colCount,
              defaultRowCount: rowCount,
              callback: (int rowCount, int colCount) {
                newRowCount = rowCount;
                newColCount = colCount;
                hasValue = true;
                hideDropMenu(context);
              },
            ),
          );
        });
    editController.requestFocus();
    if (hasValue) {
      editController.adjustTable(this, newRowCount, newColCount);
    }
  }

  List<List<WenBlock>> addJustRows(
      int newRowCount, int newColCount, BuildContext context) {
    var newRows = <List<WenBlock>>[];
    for (int i = 0; i < newRowCount; i++) {
      if (i < rows.length) {
        var row = rows[i].sublist(0, min(colCount, newColCount));
        for (int j = row.length; j < newColCount; j++) {
          row.add(TextTableCell(
            editController: editController,
            context: context,
            textElement: WenTextElement(),
            tableBlock: this,
          ));
        }
        newRows.add(row);
      } else {
        var row = <TextTableCell>[];
        for (var i = 0; i < newColCount; i++) {
          row.add(
            TextTableCell(
              editController: editController,
              context: context,
              textElement: WenTextElement(),
              tableBlock: this,
            ),
          );
        }
        newRows.add(row);
      }
    }
    return newRows;
  }

  @override
  void scrollHorizontal(double deltaX) {
    horizontalOffset += deltaX;
    if (horizontalOffset < 0) {
      horizontalOffset = 0;
    }
    var max = tableRealWidth - width;
    if (horizontalOffset > max) {
      horizontalOffset = max;
    }
    editController.layoutCurrentBlock(this);
    editController.refreshCursorPosition();
  }

  void calcHorizontalScroll() {
    if (horizontalOffset < 0) {
      horizontalOffset = 0;
    }
    var max = tableRealWidth - width;
    if (horizontalOffset > max) {
      horizontalOffset = max;
    }
  }

  void scrollToShowCellPosition(int offset) {
    var rowIndex = getRowIndex(offset);
    var colIndex = getColIndex(rowIndex, offset);
    if (colIndex >= columnWidths.length) {
      return;
    }
    if (columnWidths[colIndex] < width) {
      var cellLeft = getColumnLeft(colIndex) - horizontalOffset;
      var cellRight = cellLeft + columnWidths[colIndex];
      if (cellLeft - cellPadding < 0) {
        scrollHorizontal(-cellPadding + cellLeft);
      } else if (cellRight > width - cellPadding) {
        scrollHorizontal(cellRight - (width - cellPadding));
      }
    }
  }

  @override
  void scrollToCursorPosition(CursorPosition cursorPosition) {
    super.scrollToCursorPosition(cursorPosition);
    var offset = cursorPosition.textPosition?.offset;
    if (offset == null) {
      return;
    }
    scrollToShowCellPosition(offset);
  }

  @override
  void visitElement(
      TextPosition start, TextPosition end, WenElementVisitor visit) {
    var startOffset = start.offset;
    var endOffset = end.offset;
    for (int i = 0; i < rowCount; i++) {
      for (int j = 0; j < colCount; j++) {
        var cell = rows[i][j];
        var cellOffset = TableBaseCell.of(cell).offset;
        var cellLength = cell.length;
        //交集：max left, min right
        int selectLeft = max(startOffset - cellOffset, 0);
        int selectRight = min(cellLength, endOffset - cellOffset);
        if (selectLeft < 0 || selectRight < 0 || selectRight <= selectLeft) {
          continue;
        }
        cell.visitElement(TextPosition(offset: selectLeft),
            TextPosition(offset: selectRight), visit);
      }
    }
  }

  void splitElementInterior(TextPosition position,
      {bool splitUrlElement = false}) {
    var offset = position.offset;
    var rowIndex = getRowIndex(offset);
    var colIndex = getColIndex(rowIndex, offset);
    var cell = rows[rowIndex][colIndex];
    if (cell is TextTableCell) {
      int cellOffset = TableBaseCell.of(cell).offset;
      cell.textElement.splitElementInterior(
          TextPosition(
              offset: offset - cellOffset, affinity: position.affinity),
          splitUrlElement: splitUrlElement);
    }
  }

  WenTextElement? getTextElement(TextPosition position,
      {bool checkUrl = false}) {
    var offset = position.offset;
    var rowIndex = getRowIndex(offset);
    var colIndex = getColIndex(rowIndex, offset);
    var cell = rows[rowIndex][colIndex];
    if (cell is TextTableCell) {
      return cell.textElement.getElement(
          TextPosition(offset: position.offset - TableBaseCell.of(cell).offset),
          checkUrl: checkUrl);
    }
    return null;
  }

  /// 表格支持数据内容类型为：text(公式、链接)、图片、table
  /// 合并步骤如下：
  /// 1.将 insertBlocks 解析为 tempRows
  /// 2.将 tempRows 填充到表格
  /// 填充规则如下：
  /// 1.当内容是图片时，则替换内容为图片
  /// 2.当内容是text时，如果是复制的内容第一行第一列，则合并内容为text，如果不能合并，则替换
  /// 3.当内容是table时，则用1和2规则，在相对位置填充 table cell 数据，如果table行与列不够，则扩充行与列
  /// 4.当有多行内容时，则用1和2规则，在相对位置填充 table cell 数据，如果table行与列不够，则扩充行与列
  void insertContent(List<WenBlock> insertBlocks) {
    var cursorOffset =
        editController.cursorState.cursorPosition?.textPosition?.offset;
    if (cursorOffset == null) {
      return;
    }
    var rowIndex = getRowIndex(cursorOffset);
    var colIndex = getColIndex(rowIndex, cursorOffset);

    List<List<WenBlock>> tempRows = convertBlocksToRows(insertBlocks);
    var tempColCount = tempRows
        .map((e) => e.length)
        .reduce((value, element) => max(value, element));
    var tempRowCount = tempRows.length;
    var newRowCount = rowIndex + tempRowCount;
    var newColCount = colIndex + tempColCount;
    // 调整行与列
    if (newRowCount > rowCount || newColCount > colCount) {
      rows = addJustRows(
          max(newRowCount, rowCount), max(newColCount, colCount), context);
    }
    // 填充新数据
    for (int i = 0; i < tempRowCount; i++) {
      var row = tempRows[i];
      for (int j = 0; j < row.length; j++) {
        var insertCell = row[j];
        if (i == 0 && j == 0) {
          var oldCell = rows[i + rowIndex][j + colIndex];
          if (oldCell is TextTableCell && insertCell is TextTableCell) {
            /// 合并cell
            oldCell.textElement.insertElement(
                TextPosition(offset: cursorOffset - oldCell.offset),
                insertCell.textElement);
            oldCell.relayoutFlag = true;
            oldCell.textElement.remarkUpdated();
            continue;
          }
        }
        rows[i + rowIndex][j + colIndex] = insertCell;
      }
    }
    calcLength();
    tableElement.rows =
        rows.map((e) => e.map((cell) => cell.element).toList()).toList();
    tableElement.remarkUpdated();
    relayoutFlag = true;
    editController.layoutCurrentBlock(this);
    // 跳转到新位置
    var jumpLength = tempRows[0][0].length;
    var newCursorPosition =
        getCursorPosition(TextPosition(offset: cursorOffset + jumpLength));
    editController.toPosition(newCursorPosition, true);
  }

  /// 将blocks转换为table rows
  List<List<WenBlock>> convertBlocksToRows(List<WenBlock> blocks) {
    List<List<WenBlock>> tempRows = [];
    for (var insertBlock in blocks) {
      insertBlock.element.indent = null;
      List<WenBlock> row = [];
      if (insertBlock is TextBlock) {
        row.add(TextTableCell(
            editController: editController,
            context: context,
            textElement: insertBlock.textElement,
            tableBlock: this));
      } else if (insertBlock is ImageBlock) {
        row.add(ImageTableCell(
          editController: editController,
          context: context,
          element: insertBlock.element,
          tableBlock: this,
        ));
      } else if (insertBlock is TableBlock) {
        tempRows.addAll(insertBlock.rows);
      } else {
        var text = insertBlock.element.getText();
        row.add(TextTableCell(
            editController: editController,
            context: context,
            textElement: WenTextElement(text: text),
            tableBlock: this));
      }
      tempRows.add(row);
    }
    return tempRows;
  }

  bool isShowLink(int start, int end) {
    var startRowIndex = getRowIndex(start);
    var endRowIndex = getRowIndex(end);
    if (startRowIndex != endRowIndex) {
      return false;
    }
    var startColIndex = getColIndex(startRowIndex, start);
    var endColIndex = getColIndex(endRowIndex, end);
    if (startColIndex != endColIndex) {
      return false;
    }
    if (rows[startRowIndex][startColIndex] is TextBlock) {
      return true;
    }
    return false;
  }

  @override
  BlockLink? getLink(TextPosition textPosition) {
    var offset = textPosition.offset;
    var rowIndex = getRowIndex(offset);
    var colIndex = getColIndex(rowIndex, offset);
    var cell = rows[rowIndex][colIndex];
    if (cell is TextTableCell) {
      var element = cell.textElement.getElement(
          TextPosition(
              offset: textPosition.offset - TableBaseCell.of(cell).offset),
          checkUrl: true);
      if (element == null) {
        return null;
      }
      return BlockLink(
          textElement: element,
          textOffset: element.offset + TableBaseCell.of(cell).offset);
    }
    return null;
  }

  void calcElementLength(TextPosition position) {
    var row = getRowIndex(position.offset);
    var col = getColIndex(row, position.offset);
    var cell = rows[row][col];
    if (cell is TextBlock) {
      cell.textElement.calcLength();
      cell.relayoutFlag = true;
    }
  }

  void nextTable() {
    var textOffset =
        editController.cursorState.cursorPosition?.textPosition?.offset;
    if (textOffset == null) {
      return;
    }
    var rowIndex = getRowIndex(textOffset);
    var colIndex = getColIndex(rowIndex, textOffset);
    var newRowIndex = rowIndex;
    var newColIndex = colIndex + 1;
    if (newColIndex >= colCount) {
      newRowIndex++;
      newColIndex = 0;
    }
    bool record = false;
    if (newRowIndex >= rowCount) {
      addRowOnNext();
      record = true;
    }
    var cell = rows[newRowIndex][newColIndex];
    var cellOffset = TableBaseCell.of(cell).offset;
    editController.toPosition(
        getCursorPosition(TextPosition(offset: cellOffset + cell.length)),
        true);
    editController
        .recordSelectStart(getCursorPosition(TextPosition(offset: cellOffset)));
    editController.recordSelectEnd(
        getCursorPosition(TextPosition(offset: cellOffset + cell.length)));
    editController.refreshCursorPosition();
    if (record) {
      editController.record();
    }
  }

  void setItemType({required String itemType}) {
    var clearItem = false;
    visitSelectCell((rowIndex, colIndex) {
      var cell = rows[rowIndex][colIndex];
      if (cell is TextBlock) {
        if (cell.textElement.itemType == itemType) {
          clearItem = true;
          return false;
        }
      }
      return true;
    });
    visitSelectCell((rowIndex, colIndex) {
      var cell = rows[rowIndex][colIndex];
      if (cell is TextBlock) {
        cell.textElement.itemType = clearItem ? null : itemType;
        cell.relayoutFlag = true;
      }
      return true;
    });
    tableElement.remarkUpdated();
    editController.layoutCurrentBlock(this);
    editController.refreshCursorPosition();
    editController.record();
  }

  void visitSelectCell(TableCellVisit visit) {
    var selectRange = getSelectRange();
    if (selectRange == null) {
      return;
    }
    visitSelectCellWithRange(
        visit: visit,
        startOffset: selectRange.start,
        endOffset: selectRange.end);
  }

  void visitSelectCellWithRange({
    required int startOffset,
    required int endOffset,
    bool tableSelectMode = true,
    TableCellVisitInit? init,
    required TableCellVisit visit,
  }) {
    try {
      var startRowIndex = getRowIndex(startOffset);
      var startColIndex = getColIndex(startRowIndex, startOffset);
      var endRowIndex = getRowIndex(endOffset);
      var endColIndex = getColIndex(endRowIndex, endOffset);
      if (startColIndex > endColIndex) {
        var temp = startColIndex;
        startColIndex = endColIndex;
        endColIndex = temp;
      }
      if (startRowIndex > endRowIndex) {
        var temp = startRowIndex;
        startRowIndex = endRowIndex;
        endRowIndex = temp;
      }
      init?.call(startRowIndex, startColIndex, endRowIndex, endColIndex);
      for (int i = startRowIndex; i <= endRowIndex; i++) {
        var startCol = 0;
        var endCol = 0;
        if (tableSelectMode) {
          startCol = startColIndex;
          endCol = endColIndex;
        } else {
          endCol = rows[i].length - 1;
          if (i == startRowIndex) {
            startCol = startColIndex;
          }
          if (i == endRowIndex) {
            endCol = endColIndex;
          }
        }
        for (int j = startCol; j <= endCol; j++) {
          if (!visit.call(i, j)) {
            return;
          }
        }
      }
    } catch (e, stack) {
      // todo 由于表格内部数据有时会存在数据列数不一致导致的bug
      // 后续完善表格组件的时候去解决
      print(stack);
    }
  }

  Widget buildScrollContent(BuildContext context, ViewportOffset offset) {
    if (rows.isEmpty) {
      return Container();
    }
    var stackItems = <Widget>[];
    createCells(stackItems);
    createRowLines(stackItems);
    createColLines(stackItems);
    return Stack(
      children: [
        ...stackItems,
      ],
    );
  }
}

typedef TableCellVisitInit = Function(
    int startRow, int startCol, int endRow, int endCol);
typedef TableCellVisit = bool Function(int row, int col);

class TableController extends ChangeNotifier {
  ScrollController? scrollController;
  double recordScrollOffset = 0;

  void updateTable() {
    notifyListeners();
  }
}

class TableContainer extends StatefulWidget {
  final TableBlock tableBlock;
  final TableController tableController;

  const TableContainer({
    Key? key,
    required this.tableBlock,
    required this.tableController,
  }) : super(key: key);

  @override
  State<TableContainer> createState() => _TableContainerState();
}

class _TableContainerState extends State<TableContainer> {
  ViewportOffset? offset;
  ScrollController? scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController(
        initialScrollOffset: widget.tableController.recordScrollOffset);
    widget.tableController.scrollController = scrollController;
    scrollController!.addListener(onScrollChanged);
    widget.tableController.addListener(onTableChanged);
  }

  @override
  void dispose() {
    super.dispose();
    widget.tableController.scrollController = null;
    widget.tableController.removeListener(onTableChanged);
    scrollController!.removeListener(onScrollChanged);
  }

  void onTableChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return IgnoreParentPointer(
      ignorePointer: (box, offset) {
        var extend = scrollController?.position.maxScrollExtent;
        if (extend == 0) {
          return false;
        }
        var g = box.localToGlobal(Offset(0, box.size.height));
        if (offset.dy > g.dy - 14 && offset.dy < g.dy) {
          return true;
        }
        return false;
      },
      child: Scrollbar(
          controller: scrollController,
          child: Scrollable(
            controller: scrollController,
            axisDirection: AxisDirection.right,
            viewportBuilder: (context, offset) {
              onBuildScroll(offset);
              var block = widget.tableBlock;
              block.editController.layoutCurrentBlock(block);
              return widget.tableBlock.buildScrollContent(context, offset);
            },
          )),
    );
  }

  void onBuildScroll(ViewportOffset offset) {
    this.offset = offset;
    var block = widget.tableBlock;
    offset.applyViewportDimension(block.width);
    double minScrollExtent = 0;
    double maxScrollExtent = max(0, block.tableRealWidth - block.width);
    offset.applyContentDimensions(minScrollExtent, maxScrollExtent);
  }

  void onScrollChanged() {
    widget.tableController.recordScrollOffset = offset?.pixels ?? 0;
    widget.tableBlock.editController.updateWidgetState();
  }
}
