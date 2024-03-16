import 'dart:collection';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:wenznote/editor/block/block.dart';
import 'package:wenznote/editor/block/code/code.dart';
import 'package:wenznote/editor/block/image/image_block.dart';
import 'package:wenznote/editor/block/image/image_element.dart';
import 'package:wenznote/editor/block/line/line_block.dart';
import 'package:wenznote/editor/block/line/line_element.dart';
import 'package:wenznote/editor/block/table/image_cell.dart';
import 'package:wenznote/editor/block/table/table_block.dart';
import 'package:wenznote/editor/block/table/table_element.dart';
import 'package:wenznote/editor/block/table/text_cell.dart';
import 'package:wenznote/editor/block/text/text.dart';
import 'package:wenznote/editor/block/text/title.dart';
import 'package:wenznote/editor/crdt/YsCode.dart';
import 'package:wenznote/editor/crdt/YsText.dart';
import 'package:wenznote/editor/edit_controller.dart';
import 'package:ydart/ydart.dart';
import 'YsItem.dart';
import 'doc_utils.dart';

class YsBlock extends YsItem {
  WenBlock? block;
  Map<YMap, dynamic> cache = {};

  YsBlock({required super.tree, required super.yMap});

  void init() {
    buildBlock();
    //如何将 ymap 转换为 element？
    yMap.deepEventHandler = ((event, trans) {
      updateBlock();
      tree.editController.refreshCursorPosition();
      tree.editController.updateWidgetState();
    });
  }

  void buildBlock() {
    updateTime = tree.changeClock++;
    var map = yMap;
    var type = map.get("type") as String?;
    if (type == "text" || type == "quote") {
      var textElement = WenTextElement(type: type!);
      applyYMapToElement(map, textElement);
      block = TextBlock(
        context: tree.context,
        editController: tree.editController,
        textElement: textElement,
      );
    } else if (type == "title") {
      var textElement = WenTextElement();
      applyYMapToElement(map, textElement);
      block = TitleBlock(
        context: tree.context,
        editController: tree.editController,
        textElement: textElement,
      );
    } else if (type == "image") {
      var imageElement = WenImageElement(
          id: map.get("id") as String,
          file: map.get("id") as String,
          width: map.get("width") as int,
          height: map.get("height") as int);
      block = ImageBlock(
        context: tree.context,
        editController: tree.editController,
        element: imageElement,
      );
    } else if (type == "line") {
      block = LineBlock(
        context: tree.context,
        editController: tree.editController,
        element: LineElement(),
      );
    } else if (type == "code") {
      block = CodeBlock(
        element: WenCodeElement(
          code: (map.get("code") as YText).toString(),
          language: map.get("language") as String,
        ),
        context: context,
        editController: editController,
      );
    } else if (type == "table") {
      // alignments
      // rows
      block = TableBlock(
          context: context,
          tableElement: WenTableElement(),
          editController: editController);
      applyToTableBlock(map, block as TableBlock);
    }
  }

  void applyToTableBlock(YMap map, TableBlock table) {
    if (map.containsKey("alignments")) {
      var alignments = map.get("alignments") as YMap;
      var old = table.tableElement.alignments;
      old ??= HashMap();
      var values = alignments.typeMapEnumerateValues();
      for (var en in values.entries) {
        if (en.value == null) {
          old.remove(int.parse(en.key));
        } else {
          old[int.parse(en.key)] = en.value as String;
        }
      }
      table.tableElement.alignments = old;
    }
    var tableRows = <List<WenBlock>>[];
    if (map.containsKey("rows")) {
      var newCache = <AbstractType, dynamic>{};
      var rows = map.get("rows") as YArray;
      for (var arr in rows.enumerateList()) {
        var tableRow = <WenBlock>[];
        tableRows.add(tableRow);
        var row = arr as YArray;
        for (var item in row.enumerateList()) {
          var cell = item as YMap;
          WenBlock block;
          if (cache.containsKey(cell)) {
            block = cache[cell];
          } else {
            String type = cell.get("type") as String;
            if (type == "image") {
              var imageElement = WenImageElement(
                  id: cell.get("id") as String,
                  file: cell.get("id") as String,
                  width: cell.get("width") as int,
                  height: cell.get("height") as int);
              block = ImageTableCell(
                context: context,
                element: imageElement,
                editController: editController,
                tableBlock: table,
              );
              cell.deepEventHandler = ((eventList, transaction) {
                var imageElement = WenImageElement(
                    id: cell.get("id") as String,
                    file: cell.get("id") as String,
                    width: cell.get("width") as int,
                    height: cell.get("height") as int);
                (block as ImageTableCell).element = imageElement;
                block.relayoutFlag = true;
              });
            } else {
              var textElement = WenTextElement();
              applyYMapToElement(cell, textElement);
              block = TextTableCell(
                context: context,
                textElement: textElement,
                editController: editController,
                tableBlock: table,
              );
              cell.deepEventHandler = ((eventList, transaction) {
                var textElement = WenTextElement();
                applyYMapToElement(cell, textElement);
                (block as TextTableCell).textElement = textElement;
                block.relayoutFlag = true;
              });
            }
          }
          newCache[cell] = block;
          tableRow.add(block);
        }
      }
    }
    table.tableElement.rows =
        tableRows.map((e) => e.map((cell) => cell.element).toList()).toList();
    table.rows = tableRows;
    table.calcLength();
    table.relayoutFlag = true;
  }

  void updateBlock() {
    updateTime = tree.changeClock++;
    //将 event target 内容更新到 block，触发 block relayout
    if (block is TableBlock) {
      applyToTableBlock(yMap, block as TableBlock);
    } else {
      applyYMapToElement(yMap, block!.element);
    }
    block?.relayoutFlag = true;
  }

  BuildContext get context => tree.context;

  EditController get editController => tree.editController;

  String get blockType => (yMap.get("type") as String?) ?? "text";

  bool get isText {
    var type = blockType;
    return type == 'text' || type == 'quote' || type == 'title';
  }

  void addIndent({required int blockIndex}) {
    // text image code line table
    if (isText || blockType == "image") {
      var indent = yMap.get("indent");
      if (indent is! int) {
        indent = 1;
      } else {
        indent += 1;
        if (indent >= 6) {
          indent = 6;
        }
      }
      yMap.set("indent", indent);
    } else {
      if (blockType == "code") {
        YsCode.of(this).addIndent(blockIndex: blockIndex);
      }
    }
  }

  void removeIndent({required int blockIndex}) {
    if (isText || blockType == "image") {
      var indent = yMap.get("indent");
      if (indent is! int) {
        indent = 0;
      } else {
        indent -= 1;
        if (indent <= 0) {
          indent = 0;
        }
      }
      yMap.set("indent", indent);
    } else {
      if (blockType == "code") {
        YsCode.of(this).removeIndent(blockIndex: blockIndex);
      }
    }
  }

  int getLength() {
    var type = blockType;
    if (type == 'text' || type == 'title' || type == 'quote') {
      return getYsTextLength(yMap);
    }
    if (type == 'image' || type == 'line') {
      return 1;
    }
    if (type == 'code') {
      return getYsCodeTextLength(yMap);
    }
    return 0;
  }

  void changeTextLevel(int level) {
    if (isText) {
      yMap.set("level", level);
      if (block is TextBlock) {
        (block as TextBlock).level = level;
        block!.relayoutFlag = true;
      }
    }
  }

  void changeTextToQuote(bool quote) {
    if (isText) {
      if (quote) {
        if (yMap.get("type") != 'quote') {
          yMap.set("type", 'quote');
        }
      } else {
        if (yMap.get("type") != 'text') {
          yMap.set("type", 'text');
        }
      }
    }
  }
}

bool isTextYMap(YMap map) {
  var type = map.get("type");
  return type == 'text' || type == 'quote' || type == 'title';
}
