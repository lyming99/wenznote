import 'dart:collection';
import 'dart:io';

import 'package:dart_markdown/dart_markdown.dart';
import 'package:dart_markdown/src/charcode.dart';
import 'package:dart_markdown/src/inline_syntaxes/delimiter_syntax.dart';
import 'package:wenznote/editor/block/element/element.dart';
import 'package:wenznote/editor/block/image/image_element.dart';
import 'package:wenznote/editor/block/line/line_element.dart';
import 'package:wenznote/editor/block/table/table_element.dart';
import 'package:wenznote/editor/block/text/text.dart';
import 'package:path/path.dart';

import '../../../service/file/file_manager.dart';
import '../image.dart';

class MarkdownFileInfo {
  String? title;
  String? filename;
  String? filepath;
  List<WenElement>? elements;
}

Future<MarkdownFileInfo?> readMarkdownInfo(
    FileManager fileManager, String filepath) async {
  var file = File(filepath);
  var stat = file.statSync();
  if (stat.type != FileSystemEntityType.file) {
    return null;
  }
  var content = await file.readAsString();
  MarkdownFileInfo ans = MarkdownFileInfo();
  ans.filename = basename(filepath);
  var markdown = Markdown(
    enableTaskList: true,
    extensions: [
      DelimiterSyntax('\\\$+',
          requiresDelimiterRun: true,
          startCharacter: $dollar,
          allowIntraWord: true,
          tags: [
            DelimiterTag('formula-inline', 1),
            DelimiterTag('formula-block', 2),
          ]),
    ],
  );
  var nodes = markdown.parse(content);
  var elements = getElements(nodes);
  var dirPath = File(filepath).parent.path;
  await readImageFile(fileManager, dirPath, elements);
  ans.elements = elements;
  return ans;
}

Future<List<WenElement>> parseMarkdown(
    FileManager fileManager, String content) async {
  var markdown = Markdown(
    enableTaskList: true,
    extensions: [
      DelimiterSyntax('\\\$+',
          requiresDelimiterRun: true,
          startCharacter: $dollar,
          allowIntraWord: true,
          tags: [
            DelimiterTag('formula-inline', 1),
            DelimiterTag('formula-block', 2),
          ]),
    ],
  );
  var nodes = markdown.parse(content);
  var elements = getElements(nodes);
  await readImageFile(fileManager, "", elements);
  return elements;
}

List<WenElement> getElements(List<Node> nodes) {
  List<WenElement> elements = [];
  for (var node in nodes) {
    var visitor = WenElementParseVisitor();
    node.accept(visitor);
    elements.addAll(visitor.getWenElements());
  }
  return elements;
}

Future<void> readImageFile(
    FileManager fileManager, String dir, List<WenElement> elements) async {
  for (var element in elements) {
    try {
      if (element is WenImageElement) {
        var filepath = join(dir, element.file);
        var file = await fileManager.downloadImageFile(filepath);
        if (file == null) {
          continue;
        }
        var imageFile = await fileManager.getImageFile(file.uuid);
        if (imageFile == null) {
          continue;
        }
        var size = await readImageFileSize(imageFile);
        element.id = file.uuid ?? "";
        element.file = imageFile;
        element.width = size.width;
        element.height = size.height;
      }
    } on Exception catch (e) {
      break;
    }
    if (element is WenTableElement) {
      var rows = element.rows;
      if (rows != null) {
        for (var row in rows) {
          await readImageFile(fileManager, dir, row);
        }
      }
    }
  }
  elements.removeWhere((element) =>
      element is WenImageElement &&
      (element.id.isEmpty || element.width == 0 || element.height == 0));
}

/// 标题：h1-h6
/// 图片：img
/// 表格: tbody tr td
/// 分割线：hr
/// 公式：换行支持如何实现？
/// 行内代码：pre code
/// list：列表会包含多个item，需要换行
///
class WenElementParseVisitor implements NodeVisitor {
  var elements = <WenElement>[];
  var attrStack = Queue();
  int level = 0;

  @override
  bool visitElementBefore(Element element) {
    if (element.type == "image") {
      elements.add(WenSplitElement());
      elements.add(WenImageElement(
          id: "",
          file: element.attributes['destination'] ?? "",
          width: 0,
          height: 0));
      elements.add(WenSplitElement());
      return false;
    }
    if (element.type == "htmlBlock") {
      //在这里对html进行解析
      var text = element.textContent;
      if (text.startsWith("<img ")) {
        var index = text.indexOf(RegExp('src[ ]*=[ ]*["\']'));
        if (index == -1) {
          return false;
        }
        var first = text.indexOf(RegExp("['\"]"), index);
        if (first == -1) {
          return false;
        }
        var end = text.indexOf(text[first], first + 1);
        if (end == -1) {
          return false;
        }
        var src = text.substring(first + 1, end);
        elements.add(WenSplitElement());
        elements.add(WenImageElement(id: "", file: src, width: 0, height: 0));
        elements.add(WenSplitElement());
        return false;
      }
      if (text.startsWith("</img>")) {
        return false;
      }
    }
    var attr = <String, dynamic>{};
    if (attrStack.isNotEmpty) {
      attr.addAll(attrStack.last);
    }
    if (element.type == "atxHeading") {
      level = int.parse(element.attributes['level'] ?? "0");
    } else if (element.type == "strongEmphasis") {
      attr['bold'] = true;
    } else if (element.type == "link") {
      attr['url'] = element.attributes['destination'];
    } else if (element.type == "listItem") {
      if (element.attributes['number'] != null) {
        // 有序列表
        attr["itemType"] = "oli";
      } else if (element.attributes['taskListItem'] != null) {
        // 任务列表
        attr["itemType"] = "check";
        attr["checked"] = element.attributes['taskListItem'] != "unchecked";
      } else {
        // 无序列表
        attr["itemType"] = "li";
      }
      elements.add(WenSplitElement());
    } else if (element.type == "thematicBreak") {
      elements.add(WenSplitElement());
      elements.add(LineElement());
      elements.add(WenSplitElement());
      return false;
    } else if (element.type == "table") {
      elements.add(WenSplitElement());
      var tableVisitor = TableVisitor();
      element.accept(tableVisitor);
      elements.add(tableVisitor.getTableElement());
      elements.add(WenSplitElement());
      return false;
    }
    attrStack.addLast(attr);
    return true;
  }

  @override
  void visitElementAfter(Element element) {
    // 处理
    attrStack.removeLast();
    if (element.type == "listItem") {
      elements.add(WenSplitElement());
    }
  }

  @override
  void visitText(Text text) {
    var attr = attrStack.last;
    var textElement = WenTextElement(
      text: text.textContent,
      bold: attr['bold'],
      italic: attr['italic'],
      lineThrough: attr['lineThrough'],
      url: attr['url'],
      itemType: attr['itemType'],
      checked: attr['checked'],
      level: level,
    );
    elements.add(textElement);
  }

  List<WenElement> getWenElements() {
    WenTextElement? last;
    var ans = <WenElement>[];
    for (var element in elements) {
      if (element is! WenTextElement) {
        if (last != null) {
          last.calcLength();
          ans.add(last);
        }
        last = null;
      }
      if (element is WenSplitElement) {
        last = null;
        continue;
      }
      if (element is WenTextElement) {
        last ??= (element.copyStyle(null, [])
          ..level = element.level
          ..checked = element.checked);
        last.children?.add(element);
        element.level = 0;
        continue;
      }
      ans.add(element);
    }
    if (last != null) {
      last.calcLength();
      ans.add(last);
    }
    return ans;
  }
}

class TableVisitor implements NodeVisitor {
  var table = WenTableElement(
    rows: [],
    alignments: {},
  );
  var cellIndex = 0;

  @override
  bool visitElementBefore(Element<Node> element) {
    var type = element.type;
    if (type == "tableRow") {
      cellIndex = 0;
      table.rows?.add([]);
    }
    if (type == "tableHeadCell") {
      var attr = element.attributes;
      var align = attr["textAlign"];
      if (align != null) {
        table.alignments?[cellIndex] = align;
      }
      cellIndex++;
      visitCell(element);
      return false;
    } else if (type == "tableBodyCell") {
      visitCell(element);
      return false;
    }
    return true;
  }

  void visitCell(Element<Node> element) {
    var row = table.rows?.last;
    if (row != null) {
      var cellVisitor = TableCellVisitor();
      element.accept(cellVisitor);
      row.add(cellVisitor.getCellElement());
    }
  }

  @override
  void visitElementAfter(Element<Node> element) {}

  @override
  void visitText(Text text) {}

  WenElement getTableElement() {
    return table;
  }
}

class TableCellVisitor extends NodeVisitor {
  List<WenElement> elements = [];
  var attrStack = Queue();

  @override
  bool visitElementBefore(element) {
    if (element.type == "image") {
      elements.add(WenSplitElement());
      elements.add(WenImageElement(
          id: "",
          file: element.attributes['destination'] ?? "",
          width: 0,
          height: 0));
      elements.add(WenSplitElement());
      return false;
    }
    var attr = <String, dynamic>{};
    if (attrStack.isNotEmpty) {
      attr.addAll(attrStack.last);
    }
    if (element.type == "strongEmphasis") {
      attr['bold'] = true;
    } else if (element.type == "link") {
      attr['url'] = element.attributes['destination'];
    } else if (element.type == "listItem") {
      if (element.attributes['number'] != null) {
        // 有序列表
        attr["itemType"] = "oli";
      } else if (element.attributes['taskListItem'] != null) {
        // 任务列表
        attr["itemType"] = "check";
        attr["checked"] = element.attributes['taskListItem'] != "unchecked";
      } else {
        // 无序列表
        attr["itemType"] = "li";
      }
      elements.add(WenSplitElement());
    } else if (element.type == "thematicBreak") {
      elements.add(WenSplitElement());
      elements.add(LineElement());
      elements.add(WenSplitElement());
      return false;
    } else if (element.type == "table") {
      elements.add(WenSplitElement());
      var tableVisitor = TableVisitor();
      element.accept(tableVisitor);
      elements.add(tableVisitor.getTableElement());
      elements.add(WenSplitElement());
      return false;
    }
    attrStack.addLast(attr);
    return true;
  }

  @override
  void visitElementAfter(element) {
    if (attrStack.isNotEmpty) {
      attrStack.removeLast();
    }
  }

  @override
  void visitText(text) {
    var attr = attrStack.last;
    elements.add(WenTextElement(
      text: text.textContent,
      bold: attr['bold'],
      italic: attr['italic'],
      lineThrough: attr['lineThrough'],
      url: attr['url'],
      itemType: attr['itemType'],
      checked: attr['checked'],
    ));
  }

  WenElement getCellElement() {
    if (elements.isNotEmpty) {
      var element = elements.first;
      if (element is WenTextElement) {
        var item = element.copyStyle(null, []);
        for (var child in elements) {
          if (child is WenTextElement) {
            item.children?.add(child);
          }
        }
        return item;
      }
      if (element is WenImageElement) {
        return element;
      }
    }
    return WenTextElement();
  }
}
