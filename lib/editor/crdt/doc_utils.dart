import 'dart:collection';
import 'dart:convert';

import 'package:flutter_crdt/flutter_crdt.dart';
import 'package:wenznote/editor/block/code/code.dart';
import 'package:wenznote/editor/block/element/element.dart';
import 'package:wenznote/editor/block/image/image_element.dart';
import 'package:wenznote/editor/block/line/line_element.dart';
import 'package:wenznote/editor/block/table/table_element.dart';
import 'package:wenznote/editor/block/text/text.dart';

void applyYTextToTextElement(YText? yText, WenTextElement text) {
  if (yText == null) {
    return;
  }
  var delta = yText.toDelta();
  var elements = <WenTextElement>[];
  for (var item in delta) {
    ///attributes
    var element = WenTextElement();
    var insert = item["insert"];
    if (insert is String) {
      element.text = insert;
    } else if (insert is Map) {
      element.itemType = insert["itemType"];
      element.text = insert["text"];
    } else {
      continue;
    }
    elements.add(element);
    if (!item.containsKey("attributes")) {
      continue;
    }
    var attr = item['attributes'] as Map<dynamic, dynamic>;
    element.background = attr['background'] as int?;
    element.color = attr['color'] as int?;
    element.url = attr['url'] as String?;
    element.underline = attr['underline'] as bool?;
    element.lineThrough = attr['lineThrough'] as bool?;
    element.bold = attr['bold'] as bool?;
    element.fontSize = attr['fontSize'] as double?;
    element.italic = attr['italic'] as bool?;
  }
  text.children = elements;
  text.calcLength();
}

WenElement? createWenElementFromYMap(YMap map) {
  var type = map.get("type");
  if (type == "text") {
    var textElement = WenTextElement();
    applyYMapToElement(map, textElement);
    return textElement;
  } else if (type == "title") {
    var textElement = WenTextElement();
    applyYMapToElement(map, textElement);
    return textElement;
  } else if (type == "image") {
    var imageElement = WenImageElement(
        id: map.get("id"),
        file: map.get("id"),
        width: map.get("width"),
        height: map.get("height"));
    return imageElement;
  } else if (type == "line") {
    return LineElement();
  } else if (type == "code") {
    return WenCodeElement(
      code: (map.get("code") as YText).toString(),
      language: map.get("language") ?? "text",
    );
  } else if (type == "table") {
    var element = WenTableElement();
    applyYMapToElement(map, element);
    return element;
  }
  return null;
}

Future<Doc> jsonToYDoc(int clientId, String? json) async {
  Doc doc = Doc();
  doc.clientID = clientId;
  var blocks = doc.getArray("blocks");
  if (json == null || json.isEmpty) {
    return doc;
  }
  var jsonArray = jsonDecode(json);
  if (jsonArray is! List) {
    return doc;
  }
  var elements = jsonArray
      .map((e) => WenElement.parseJson(e))
      .map((e) => e.getYMap())
      .toList();
  blocks.insert(0, elements);
  return doc;
}

Future<Doc> elementsToYDoc(List<WenElement> elements) async {
  Doc doc = Doc();
  var blocks = doc.getArray("blocks");
  blocks.insert(0, elements.map((e) => e.getYMap()).toList());
  return doc;
}

void applyYMapToElement(
  YMap map,
  WenElement element,
) {
  switch (element.runtimeType) {
    case WenCodeElement:
      var code = map.get("code");
      if (code is YText) {
        var codeElement = (element as WenCodeElement);
        codeElement.code = code.toString();
        codeElement.language = map.get("language") ?? "text";
      }
      break;
    case WenTextElement:
      var text = element as WenTextElement;
      text.level = map.get("level") ?? 0;
      text.checked = map.get("checked");
      text.itemType = map.get("itemType");
      text.alignment = map.get("alignment");
      text.indent = map.get("indent");
      text.type = map.get("type") ?? "text";
      if (map.has("text")) {
        applyYTextToTextElement(map.get("text"), text);
      }
      break;
    case WenImageElement:
      element.alignment = map.get("alignment");
      element.indent = map.get("indent");
      break;
    case WenTableElement:
      var table = element as WenTableElement;
      if (map.has("alignments")) {
        var alignments = map.get("alignments") as YMap;
        var old = table.alignments;
        old ??= HashMap();
        for (var en in alignments.entries()) {
          if (en.value == null) {
            old.remove(int.parse(en.key));
          } else {
            old[int.parse(en.key)] = en.value;
          }
        }
        table.alignments = old;
      } else {
        table.alignments = {};
      }
      var tableRows = <List<WenElement>>[];
      if (map.has("rows")) {
        var rows = map.get("rows") as YArray;
        for (var arr in rows) {
          var tableRow = <WenElement>[];
          tableRows.add(tableRow);
          var row = arr as YArray;
          for (var item in row) {
            var cell = item as YMap;
            String type = cell.get("type");
            if (type == "image") {
              var imageElement = WenImageElement(
                  id: cell.get("id"),
                  file: cell.get("id"),
                  width: cell.get("width"),
                  height: cell.get("height"));
              tableRow.add(imageElement);
            } else {
              var textElement = WenTextElement();
              applyYMapToElement(cell, textElement);
              tableRow.add(textElement);
            }
          }
        }
      }
      table.rows = tableRows;
      break;
  }
}

List<WenElement> yDocToWenElements(Doc? doc) {
  var res = <WenElement>[];
  if (doc != null) {
    var array = doc.getArray("blocks");
    for (var value in array) {
      var item = createWenElementFromYMap(value);
      if (item != null) {
        res.add(item);
      }
    }
  }
  return res;
}
