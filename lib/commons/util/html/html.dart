import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:wenz_flutter_html/wenz_flutter_html.dart';
import 'package:wenznote/commons/service/copy_service.dart';
import 'package:wenznote/commons/util/image.dart';
import 'package:wenznote/editor/block/block.dart';
import 'package:wenznote/editor/block/code/code.dart';
import 'package:wenznote/editor/block/element/element.dart';
import 'package:wenznote/editor/block/image/image_block.dart';
import 'package:wenznote/editor/block/image/image_element.dart';
import 'package:wenznote/editor/block/table/table_block.dart';
import 'package:wenznote/editor/block/table/table_element.dart';
import 'package:wenznote/editor/block/text/text.dart';
import 'package:wenznote/editor/block/text/title.dart';
import 'package:wenznote/editor/block/video/video_element.dart';
import 'package:wenznote/editor/edit_controller.dart';
import 'package:wenznote/service/service_manager.dart';

List<String> get _htmlTags => new List<String>.from(STYLED_ELEMENTS)
  ..addAll(INTERACTABLE_ELEMENTS)
  ..addAll(REPLACED_ELEMENTS)
  ..addAll(LAYOUT_ELEMENTS)
  ..addAll(TABLE_CELL_ELEMENTS)
  ..addAll(TABLE_DEFINITION_ELEMENTS);

Future<List<WenBlock>> parseHtmlBlock(EditController editController,
    CopyService copyService, BuildContext context, String html) async {
  var copyCache = await parseCopyIdElement(copyService, context, html);
  if (copyCache != null) {
    var res = <WenBlock>[];
    for (var value in copyCache) {
      if (value is WenTextElement) {
        if (value.type == "title") {
          res.add(TitleBlock(
              editController: editController,
              context: context,
              textElement: value));
        } else {
          res.add(TextBlock(
              editController: editController,
              context: context,
              textElement: value));
        }
      } else if (value is WenImageElement) {
        res.add(ImageBlock(
            editController: editController, context: context, element: value));
      } else if (value is WenCodeElement) {
        res.add(CodeBlock(
            editController: editController, element: value, context: context));
      } else if (value is WenTableElement) {
        res.add(TableBlock(
            editController: editController,
            context: context,
            tableElement: value));
      } else if (value is VideoElement) {}
    }
    return res;
  }
  var elements = await parseHtmlToBlockElement(context, html);
  var res = <WenBlock>[];
  var children = <WenTextElement>[];
  for (var item in elements) {
    if (item is WenTextElement) {
      if (item.type == "title") {
        //给上一内容换行
        if (children.isNotEmpty) {
          res.add(TextBlock(
              editController: editController,
              context: context,
              textElement: WenTextElement(
                children: children,
              )));
          children = <WenTextElement>[];
        }
        res.add(TitleBlock(
          editController: editController,
          context: context,
          textElement: item,
        ));
      } else {
        children.add(item);
        if (item.newLine == true) {
          res.add(TextBlock(
              editController: editController,
              context: context,
              textElement: WenTextElement(
                children: children,
              )));
          children = <WenTextElement>[];
        }
      }
    } else if (item is WenImageElement) {
      res.add(ImageBlock(
          editController: editController, element: item, context: context));
    } else if (item is WenCodeElement) {
      res.add(CodeBlock(
          editController: editController, element: item, context: context));
    }
  }
  if (children.isNotEmpty) {
    res.add(TextBlock(
        editController: editController,
        context: context,
        textElement: WenTextElement(
          children: children,
        )));
  }
  return res;
}

Future<List<WenElement>> parseHtmlToBlockElement(
    BuildContext context, String html) async {
  var result = <WenElement>[];
  WenElementStyle blockElementStyle = WenElementStyle();
  var dom = HtmlParser.parseHTML(html);
  var tree = HtmlParser.lexDomTree(dom, [], _htmlTags, null, context);
  _applyInlineStyles(tree, null);
  var body = _getBodyElement(tree);

  if (body != null) {
    await _parseHtmlToBlockElement(context, body, result, blockElementStyle);
  }
  return result;
}

Future<List<WenElement>?> parseCopyIdElement(
    CopyService copyService, BuildContext context, String html) async {
  var dom = HtmlParser.parseHTML(html);
  var tree = HtmlParser.lexDomTree(dom, [], _htmlTags, null, context);
  _applyInlineStyles(tree, null);
  var body = _getBodyElement(tree);
  if (body != null) {
    var copyId = body.attributes["copyid"];
    if (copyId != null) {
      if (copyId == copyService.copyId) {
        return copyService.copyElements;
      } else {
        await copyService.readCopyCache(context);
        if (copyId == copyService.copyId) {
          return copyService.copyElements;
        }
      }
    }
  }
  return null;
}

StyledElement? _getBodyElement(StyledElement element) {
  if (element.name == "body") {
    return element;
  }
  for (var child in element.children) {
    var body = _getBodyElement(child);
    if (body != null) {
      return body;
    }
  }
  return null;
}

String _getElementText(StyledElement element) {
  if (element is TextContentElement) {
    return element.text ?? "";
  }
  var text = "";
  for (var child in element.children) {
    text += _getElementText(child);
  }
  return text;
}

Future<void> _parseHtmlToBlockElement(
    BuildContext context,
    StyledElement element,
    List<WenElement> result,
    WenElementStyle style) async {
  if (element is TextContentElement) {
    if (element.style.textDecoration != null) {
      style.underline = element.style.textDecoration
          .toString()
          .toLowerCase()
          .contains("under");
      style.lineThrough = element.style.textDecoration
          .toString()
          .toLowerCase()
          .contains("through");
    }
    if (element.style.color != null) {
      style.color = element.style.color?.value;
    }
    var text = element.text ?? "";
    for (var line in text.split("\n")) {
      result.add(
        WenTextElement(
          text: line,
        )
          ..type = style.type ?? "text"
          ..level = style.level ?? 0
          ..italic = style.italic
          ..bold = style.bold
          ..underline = style.underline
          ..lineThrough = style.lineThrough
          ..remark = style.remark
          ..newLine = true
          ..url = style.url
          ..color = style.color
          ..background = style.background
          ..itemType = style.itemType
          ..indent = style.indent,
      );
    }
    if (result.isNotEmpty) {
      result.last.newLine = false;
    }
  } else if (element.name == 'img') {
    var id = element.elementId;
    var src = element.attributes["src"];
    var imageFile =
        await ServiceManager.of(context).fileManager.getImageFile(id);
    if (imageFile != null && File(imageFile).existsSync()) {
      var size = await readImageFileSize(imageFile);
      result.add(WenImageElement(
        id: id,
        file: imageFile,
        width: size.width,
        height: size.height,
      ));
      return;
    }
    if (src != null) {
      var fileItem =
          await ServiceManager.of(context).fileManager.downloadImageFile(src);
      if (fileItem != null) {
        var imageFile = await ServiceManager.of(context)
            .fileManager
            .getImageFile(fileItem.uuid);
        if (imageFile != null) {
          var size = await readImageFileSize(imageFile);
          result.add(WenImageElement(
            id: fileItem.uuid!,
            file: imageFile,
            width: size.width,
            height: size.height,
          ));
        }
      }
    }
  } else if (element.name == 'video') {
    //todo 视频支持
  } else if (element.name == 'video') {
    //todo 音频支持
  } else if (element.name == 'svg') {
    //todo svg支持
  } else {
    if (element.name == "h1") {
      style.type = "title";
      style.level = 1;
      style.bold = null;
    } else if (element.name == "h2") {
      style.type = "title";
      style.level = 2;
      style.bold = null;
    } else if (element.name == "h3") {
      style.type = "title";
      style.level = 3;
      style.bold = null;
    } else if (element.name == "h4") {
      style.type = "title";
      style.level = 4;
      style.bold = null;
    } else if (element.name == "h5") {
      style.type = "title";
      style.level = 5;
      style.bold = null;
    } else if (element.name == "h6") {
      style.type = "title";
      style.level = 6;
      style.bold = null;
    } else if (element.name == "pre") {
      result.add(
        WenCodeElement(
          code: _getElementText(element),
          language: element.attributes["lang"] ?? "text",
        ),
      );
      return;
    } else {
      if (element.style.fontWeight != null) {
        style.bold = element.style.fontWeight == FontWeight.bold;
      }
      if (element.style.fontStyle != null) {
        style.italic = element.style.fontStyle == FontStyle.italic;
      }
      style.type = "text";
    }
    //只支持文字链接
    if (element.name == "a") {
      style.url = element.attributes["href"];
      var text = _getElementText(element);
      //只支持文字链接，如果包含图片，去除图片
      if (text.isNotEmpty) {
        result.add(WenTextElement(
          text: text,
          url: style.url,
        ));
        return;
      } else {
        //其他复杂链接直接清除
        style.url = null;
      }
    }
    if (element.attributes['linethrough'] == 'true') {
      style.lineThrough = true;
    }
    if (element.attributes['bold'] == 'true') {
      style.bold = true;
    }
    if (element.attributes['italic'] == 'true') {
      style.italic = true;
    }
    if (element.attributes['underline'] == 'true') {
      style.underline = true;
    }
    if (element.attributes['color'] != null) {
      try {
        style.color = int.parse(element.attributes["color"]!);
      } catch (e) {
        print(e);
      }
    }
    if (element.attributes['background'] != null) {
      try {
        style.background = int.parse(element.attributes["background"]!);
      } catch (e) {
        print(e);
      }
    }
    if (element.attributes['indent'] != null) {
      try {
        style.indent = int.parse(element.attributes["indent"]!);
      } catch (e) {
        print(e);
      }
    }
    if (element.attributes['itemtype'] != null) {
      style.itemType = element.attributes['itemtype'];
    }
    bool newLine = ![
      "a",
      "b",
      "code",
      "em",
      "font",
      "label",
      "i",
      "input",
      "span",
      "strong",
      "textarea",
      "pre",
      "u",
      "empty"
    ].contains(element.name);
    WenTextElement? title;
    if (style.type == "title") {
      var ret = WenTextElement(
        type: "title",
        level: style.level ?? 0,
        children: [],
        alignment: style.alignment,
        itemType: style.itemType,
      );
      result.add(ret);
      title = ret;
      result = <WenElement>[];
    }
    try {
      for (var child in element.children) {
        await _parseHtmlToBlockElement(context, child, result, style.copy());
      }
      if (result.isNotEmpty) {
        result.last.newLine = newLine;
      } else if (element.children.isEmpty) {
        if (element.name != "empty") {
          result.add(
            WenTextElement()
              ..type = style.type ?? "text"
              ..level = style.level ?? 0
              ..italic = style.italic
              ..bold = style.bold
              ..lineThrough = style.lineThrough
              ..underline = style.underline
              ..remark = style.remark
              ..newLine = newLine
              ..url = style.url
              ..color = style.color
              ..indent = style.indent
              ..itemType = style.itemType
              ..background = style.background,
          );
        }
      }
    } finally {
      if (style.type == "title") {
        title!.children = [];
        for (var item in result) {
          if (item is WenTextElement) {
            title.children!.add(item);
          }
        }
        title.calcLength();
      }
    }
  }
}

void _parseTextBlock(
    StyledElement element, WenTextElement root, WenElementStyle style) {}

StyledElement _applyInlineStyles(
    StyledElement tree, OnCssParseError? errorHandler) {
  if (tree.attributes.containsKey("style")) {
    final newStyle = inlineCssToStyle(tree.attributes['style'], errorHandler);
    if (newStyle != null) {
      tree.style = tree.style.merge(newStyle);
    }
  }

  for (var item in tree.children) {
    _applyInlineStyles(item, errorHandler);
  }
  return tree;
}
