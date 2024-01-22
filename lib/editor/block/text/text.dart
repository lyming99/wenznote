import 'dart:collection';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_crdt/flutter_crdt.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:wenznote/commons/util/html.dart';
import 'package:wenznote/commons/util/widget_util.dart';
import 'package:wenznote/commons/widget/ignore_parent_pointer.dart';
import 'package:wenznote/commons/widget/popup_stack.dart';
import 'package:wenznote/editor/block/text/link.dart';
import 'package:wenznote/editor/block/text/rich_text_painter.dart';
import 'package:wenznote/editor/proto/note.pb.dart';
import 'package:wenznote/editor/theme/theme.dart';
import 'package:wenznote/editor/widget/toggle_item.dart';

import '../../edit_controller.dart';
import '../../widget/drag.dart';
import '../../widget/formula_dialog.dart';
import '../block.dart';
import '../element/element.dart';
import 'hide_text_mode.dart';

typedef TextElementVisitor = bool Function(WenTextElement child);

///文字节点，如果是公式，则如何？itemType=formula，text就是
class WenTextElement extends WenElement {
  WenTextElement? parent;
  List<WenTextElement>? children;
  String? _text;
  int? _color;
  int? _background;

  //加粗
  bool? _bold;

  //斜体
  bool? _italic;
  double? _fontSize;

  bool? _checked;

  //有序列表oli、无序列表li、任务列表check
  String? _itemType;

  //下滑线
  bool? _underline;

  //删除线
  bool? _lineThrough;

  //标记
  bool? _remark;

  WenTextElement({
    String? text,
    int? color,
    int? background,
    bool? bold,
    bool? italic,
    bool? lineThrough,
    bool? underline,
    bool? remark,
    this.children,
    double? fontSize,
    bool? checked,
    String? itemType,
    super.alignment,
    super.indent,
    super.url,
    super.newLine = false,
    super.type = "text",
    super.level = 0,
  }) {
    _text = text;
    _color = color;
    _background = background;
    _bold = bold;
    _italic = italic;
    _lineThrough = lineThrough;
    _underline = underline;
    _remark = remark;
    _fontSize = fontSize;
    _checked = checked;
    _itemType = itemType;
    calcLength();
  }

  WenTextElement copyStyle(String? text, List<WenTextElement>? children) {
    return WenTextElement(
      text: text,
      color: color,
      background: background,
      bold: bold,
      italic: italic,
      underline: underline,
      lineThrough: lineThrough,
      children: children,
      type: type,
      level: level,
      url: url,
      itemType: itemType,
      alignment: alignment,
      indent: indent,
    );
  }

  InlineSpan getSpan({
    required BuildContext context,
    List<TextPosition>? hoverPositions,
    required List<HideTextMode> hideModes,
  }) {
    //如果是自定义类型的element，则返回 WidgetSpan
    if (isLeafItem) {
      return WidgetSpan(
          child: ElementSpanWidget(
        element: this,
      ));
    }
    //删除线和下划线，可以考虑增加波浪线、虚线之类的风格：decorationStyle
    TextDecoration? decoration = TextDecoration.combine([
      if (lineThrough == true) TextDecoration.lineThrough,
      if (underline == true) TextDecoration.underline,
    ]);

    if (url != null && hoverPositions != null) {
      for (var hover in hoverPositions) {
        var hoverDecoration = hoverCheck(hover);
        decoration = TextDecoration.combine([
          if (hoverDecoration != null) hoverDecoration,
          if (decoration != null) decoration
        ]);
      }
    }
    var showBackground =
        background == null ? null : Color(background!).withOpacity(0.8);
    var textColor =
        color == null ? (url != null ? Colors.lightBlue : null) : Color(color!);
    if (hideText) {
      bool ok = false;
      if (!ok && hideModes.contains(HideTextMode.color)) {
        if (textColor != null) {
          showBackground = textColor.withOpacity(0.8);
          textColor = Colors.transparent;
          ok = true;
        }
      }
      if (!ok && hideModes.contains(HideTextMode.background)) {
        if (showBackground != null) {
          textColor = Colors.transparent;
          ok = true;
        }
      }
      if (!ok && hideModes.contains(HideTextMode.underline)) {
        if (underline == true) {
          showBackground = textColor?.withOpacity(0.2) ?? Colors.grey;
          textColor = Colors.transparent;
        }
      }
    }
    return TextSpan(
      // mouseCursor: SystemMouseCursors.text,
      text: text,
      children: children
          ?.map((e) => e.getSpan(
                context: context,
                hoverPositions: hoverPositions,
                hideModes: hideModes,
              ))
          .toList(),
      style: TextStyle(
        color: textColor,
        backgroundColor: showBackground,
        fontStyle: italic == true ? FontStyle.italic : null,
        fontWeight: bold == true ? FontWeight.bold : null,
        fontSize: fontSize?.toDouble(),
        decoration: decoration,
        height: 1.2,
      ),
    );
  }

  TextDecoration? hoverCheck(TextPosition hoverPosition) {
    TextDecoration? decoration;
    if (hoverPosition.offset > offset &&
        hoverPosition.offset < offset + textLength) {
      decoration = TextDecoration.underline;
    } else {
      if (hoverPosition.affinity == TextAffinity.upstream) {
        if (hoverPosition.offset == offset + textLength) {
          decoration = TextDecoration.underline;
        }
      } else if (hoverPosition.affinity == TextAffinity.downstream) {
        if (hoverPosition.offset == offset) {
          decoration = TextDecoration.underline;
        }
      }
    }
    return decoration;
  }

  void visitChildren(TextElementVisitor visitor) {
    _visitChildren(visitor);
  }

  bool _visitChildren(TextElementVisitor visitor) {
    if (!visitor.call(this)) {
      return false;
    }
    var children = this.children;
    if (children != null) {
      for (var child in children) {
        if (!child._visitChildren(visitor)) {
          return false;
        }
      }
    }
    return true;
  }

  int calcLength({int offset = 0}) {
    this.offset = offset;
    if (isLeafItem) {
      length = 1;
      return 1;
    }
    var len = textLength;
    var children = this.children;
    if (children != null) {
      for (var child in children) {
        len += child.calcLength(offset: offset + len);
      }
    }
    length = len;
    children?.removeWhere(
        (element) => element.text == null || element.text!.isEmpty);
    return len;
  }

  bool get isLeafItem {
    return itemType == "formula" || itemType == "image";
  }

  /// 删除表情符号会用到
  String deleteCharBoundary(String text, int offset) {
    var range = CharacterBoundary(text).getTextBoundaryAt(offset);
    return text.replaceRange(range.start, range.end, "");
  }

  void delete(TextPosition textPosition) {
    int offset = textPosition.offset;
    if (isLeafItem) {
      if (offset == 1) {
        itemType = null;
        text = null;
      }
    } else if (offset <= textLength) {
      text = deleteCharBoundary(text ?? "", offset);
    } else {
      for (var child in (children ?? <WenTextElement>[])) {
        if (child.isLeafItem) {
          if (offset == child.offset + 1) {
            child.text = null;
            child.itemType = null;
            break;
          }
        } else if (offset <= child.offset + child.length) {
          child.text =
              deleteCharBoundary(child.text ?? "", offset - child.offset);
          // child.text = child.text?.replaceRange(
          //     offset - child.offset - 1, offset - child.offset, "");
          break;
        }
      }
      children?.removeWhere((element) => element.text?.isEmpty ?? true);
    }
    calcLength();
  }

  void merge(WenTextElement textElement) {
    var children = this.children ?? <WenTextElement>[];
    children.add(textElement.copyStyle(textElement.text, null));
    if (textElement.children != null) {
      children.addAll(textElement.children!);
    }
    children.removeWhere((element) => element.text?.isEmpty ?? true);
    this.children = children;
    calcLength();
  }

  void deleteRange(TextPosition start, TextPosition end) {
    int startOffset = start.offset;
    int endOffset = end.offset;
    if (isLeafItem) {
      if (startOffset < 1 && endOffset >= 1) {
        text = null;
        itemType = null;
      }
    } else if (startOffset < textLength) {
      text = text?.replaceRange(startOffset, min(endOffset, textLength), "");
    }
    children?.forEach((element) {
      if (element.isLeafItem) {
        int elementOffset = element.offset;
        if (startOffset <= elementOffset && endOffset >= elementOffset + 1) {
          element.text = null;
          element.itemType = null;
        }
      } else {
        int elementTextLength = element.textLength;
        int elementOffset = element.offset;
        int elementEndOffset = elementTextLength + elementOffset;
        if (startOffset < elementEndOffset && endOffset > elementOffset) {
          int subStart = max(0, startOffset - elementOffset);
          int subEnd = min(elementTextLength, endOffset - elementOffset);
          element.text = element.text?.replaceRange(subStart, subEnd, "");
        }
      }
    });
    children?.removeWhere((element) => element.text?.isEmpty ?? true);
    calcLength();
  }

  WenTextElement splitText(TextPosition cursorTextPosition) {
    int cursorOffset = cursorTextPosition.offset;
    if (isLeafItem) {
      if (cursorOffset == 1) {
        return WenTextElement(
          type: type,
          text: null,
          indent: indent,
        );
      } else {
        var ans = WenTextElement(
          type: type,
          text: text,
          indent: indent,
          itemType: itemType,
        );
        itemType = null;
        text = null;
        type = type;
        return ans;
      }
    } else if (cursorOffset <= textLength) {
      WenTextElement ans = WenTextElement(
        type: type,
        text: text?.substring(cursorOffset),
        children: children,
        indent: indent,
        itemType: itemType,
      );
      text = text?.substring(0, cursorOffset);
      children = [];
      calcLength();
      return ans;
    }
    var newChildren = <WenTextElement>[];
    var nextElementChildren = <WenTextElement>[];
    bool splitStart = false;
    for (var child in (children ?? <WenTextElement>[])) {
      if (!splitStart) {
        newChildren.add(child);
        if (child.isLeafItem) {
          if (cursorOffset <= child.offset + 1) {
            splitStart = true;
          }
          if (cursorOffset == child.offset) {
            newChildren.removeLast();
            nextElementChildren.add(child);
          }
        } else if (cursorOffset <= child.offset + (child.textLength)) {
          splitStart = true;
          WenTextElement childSplit = child.copyStyle(
              child.text?.substring(cursorOffset - child.offset), null);
          nextElementChildren.add(childSplit);
          child.text = child.text?.substring(0, cursorOffset - child.offset);
        }
      } else {
        nextElementChildren.add(child);
      }
    }
    children = newChildren;
    calcLength();
    return WenTextElement(
      children: nextElementChildren,
      indent: indent,
      itemType: itemType,
      type: type,
    );
  }

  void insertElement(TextPosition textPosition, WenTextElement element) {
    var end = splitText(textPosition);
    merge(element);
    merge(end);
  }

  int get elementTextLength {
    if (isLeafItem) {
      return 1;
    }
    return text?.length ?? 0;
  }

  int inputText(
    TextPosition textPosition,
    TextEditingValue text,
  ) {
    int offset = textPosition.offset;
    if (isLeafItem) {
      return offset;
    } else if (offset <= elementTextLength) {
      var newText = this.text ?? "";
      this.text = newText.replaceRange(offset, offset, text.text);
    } else {
      var children = this.children ?? <WenTextElement>[];
      for (var i = 0; i < children.length; i++) {
        var child = children[i];
        if (child.isLeafItem) {
          if (child.offset == offset) {
            children.insert(
                i,
                WenTextElement(
                  text: text.text,
                ));
            break;
          } else if (child.offset + 1 == offset) {
            children.insert(
                i + 1,
                WenTextElement(
                  text: text.text,
                ));
            break;
          }
        } else if (offset <= (child.offset + child.elementTextLength)) {
          if (offset == child.offset + child.elementTextLength &&
              child.url != null) {
            if (i < children.length - 1 && children[i + 1].url == null) {
              continue;
            } else {
              children.insert(
                  i + 1,
                  WenTextElement(
                    text: text.text,
                  ));
            }
          } else {
            var newText = child.text ?? "";
            child.text = newText.replaceRange(
                offset - child.offset, offset - child.offset, text.text);
          }
          break;
        }
      }
    }
    calcLength();
    return offset + text.text.length;
  }

  WenTextElement subElement(TextPosition start, TextPosition end) {
    if (isLeafItem) {
      if (start.offset <= 0 && end.offset >= 1) {
        return copyStyle(text, children);
      }
      return WenTextElement();
    } else {
      String text = "";
      String curText = this.text ?? "";
      if (start.offset < textLength) {
        text = curText.substring(
            start.offset, max(start.offset, min(end.offset, textLength)));
      }
      List<WenTextElement> texts = [];
      for (var child in children ?? <WenTextElement>[]) {
        int left = max(0, start.offset - child.offset);
        int right = max(0, min(child.textLength, end.offset - child.offset));
        if (left < right) {
          if (child.isLeafItem) {
            texts.add(child.copyStyle(child.text, null));
          } else {
            texts
                .add(child.copyStyle(child.text?.substring(left, right), null));
          }
        }
      }
      return copyStyle(text, texts);
    }
  }

  WenTextElement? getLink(TextPosition position) {
    return getElement(position, checkUrl: true);
  }

  WenTextElement? getElement(TextPosition position, {bool checkUrl = false}) {
    for (var child in children ?? <WenTextElement>[]) {
      var ret = child.getElement(position, checkUrl: checkUrl);
      if (ret != null) {
        return ret;
      }
    }
    if (position.offset > offset && position.offset < offset + textLength) {
      if (!checkUrl || url != null) {
        return this;
      }
    }
    if (position.offset == offset) {
      if (position.affinity == TextAffinity.downstream) {
        if (!checkUrl || url != null) {
          return this;
        }
      }
    }
    if (position.offset == offset + textLength) {
      if (position.affinity == TextAffinity.upstream) {
        if (!checkUrl || url != null) {
          return this;
        }
      }
    }
    return null;
  }

  ///在内部对 position 位置的element进行分割:用于着色器改变范围的element属性值
  void splitElementInterior(TextPosition position,
      {bool splitUrlElement = false}) {
    var element = getElement(position);
    if (element != null) {
      if (element.isLeafItem) {
        return;
      }
      if (!splitUrlElement && element.url != null) {
        return;
      }
      var text = element.text;
      if (text != null) {
        String newText = text.substring(0, position.offset - element.offset);
        String insertText = text.substring(position.offset - element.offset);
        if (insertText.isNotEmpty) {
          if (element == this) {
            element.text = null;
            var children = this.children ?? [];
            children.insert(0, element.copyStyle(insertText, null)..level = 0);
            children.insert(0, element.copyStyle(newText, null)..level = 0);
            this.children = children;
          } else {
            var children = this.children;
            if (children != null) {
              for (var i = 0; i < children.length; i++) {
                if (children[i] == element) {
                  element.text = newText;
                  children.insert(i + 1, element.copyStyle(insertText, null));
                  break;
                }
              }
            }
          }
        }
      }
      calcLength();
    }
  }

  int get textLength => elementTextLength;

  @override
  String getHtml({bool isRoot = true, FilePathBuilder? filePathBuilder}) {
    Queue<String> markQueue = Queue();

    if (isRoot) {
      String attr = "";
      if (itemType != null) {
        attr += " itemType='$itemType'";
      }
      if (indent != null) {
        attr += " indent='$indent'";
      }
      if (level > 0) {
        markQueue.addLast("</h$level>");
        if (isRoot) {
          markQueue.addLast("<h$level$attr>");
        } else {
          markQueue.addLast("<h$level>");
        }
      } else {
        markQueue.addLast("</p>");
        markQueue.addLast("<p$attr>");
      }
    }
    if (url != null) {
      markQueue.addLast("</a>");
      markQueue.addLast("<a href='$url'>");
    }
    if (color != null ||
        background != null ||
        lineThrough == true ||
        underline == true) {
      markQueue.addLast("</font>");
      String style = "";
      if (color != null) {
        style += " color='$color'";
      }
      if (lineThrough == true) {
        style += " lineThrough='true'";
      }
      if (underline == true) {
        style += " underline='true'";
      }
      if (background != null) {
        style += " background='$background'";
      }
      markQueue.addLast("<font $style>");
    }
    var htmlText = htmlSerializeEscape(text ?? "");
    for (var child in (children ?? <WenTextElement>[])) {
      var text = child.text;
      if (text == null) {
        continue;
      }
      htmlText += child.getHtml(isRoot: false);
    }
    while (markQueue.isNotEmpty) {
      htmlText = markQueue.removeLast() + htmlText + markQueue.removeLast();
    }
    return htmlText;
  }

  @override
  String getMarkDown({FilePathBuilder? filePathBuilder, bool root = true}) {
    if (root) {
      String ans = "";
      String itemTypeText = "";
      if (itemType == "li") {
        itemTypeText = "- ";
      } else if (itemType == "check") {
        itemTypeText = "- [${checked == true ? "x" : " "}] ";
      }
      switch (level) {
        case 0:
          ans = itemTypeText;
          break;
        default:
          ans = "${"#" * level} $itemTypeText";
          break;
      }
      ans += (text ?? "");
      var children = this.children;
      if (children != null) {
        for (var element in children) {
          ans += element.getMarkDown(
              filePathBuilder: filePathBuilder, root: false);
        }
      }
      return ans;
    } else {
      String ans = text ?? "";
      if (url != null) {
        ans = "[$ans]($url)";
      } else if (itemType == "formula") {
        ans = "\$$ans\$";
      }
      if (bold == true) {
        ans = "**$ans**";
      }
      if (lineThrough == true) {
        ans = "~~$ans~~";
      }
      if (italic == true) {
        ans = "*$ans*";
      }
      if (underline == true) {
        ans = "<u>$ans</u>";
      }
      if (color != null) {
        ans = "<span style='color: #${color?.toRadixString(16)}'>$ans</span>";
      }
      return ans;
    }
  }

  @override
  String getText() {
    StringBuffer text = StringBuffer(this.text ?? "");
    for (var child in (children ?? <WenTextElement>[])) {
      if (child.isLeafItem) {
        text.write(" ");
      } else {
        text.write(child.text ?? "");
      }
    }
    return text.toString();
  }

  @override
  Map<String, dynamic> toJson() {
    return super.toJson()
      ..addAll({
        if (text != null) "text": text,
        if (color != null) "color": color,
        if (background != null) "background": background,
        if (bold != null) "bold": bold,
        if (italic != null) "italic": italic,
        if (lineThrough != null) "lineThrough": lineThrough,
        if (underline != null) "underline": underline,
        if (remark != null) "underline": remark,
        if (itemType != null) "itemType": itemType,
        if (checked != null) "checked": checked,
        if (children != null && children?.isNotEmpty == true)
          "children": children?.map((e) => e.toJson()).toList(),
      });
  }

  factory WenTextElement.fromJson(Map<dynamic, dynamic> json) {
    var block = WenElement.fromJson(json);
    return WenTextElement(
      text: json["text"],
      color: json["color"],
      background: json["background"],
      bold: json["bold"],
      italic: json["italic"],
      lineThrough: json["lineThrough"],
      underline: json["underline"],
      remark: json["remark"],
      itemType: json["itemType"],
      checked: json["checked"],
      children: json["children"] != null
          ? List.of(json["children"])
              .map((i) => WenTextElement.fromJson(i))
              .toList()
          : null,
    )..copyProperties(block);
  }

  @override
  void clearStyle() {
    super.clearStyle();
    bold = null;
    italic = null;
    lineThrough = null;
    underline = null;
    color = null;
    remark = null;
    background = null;
    itemType = null;
  }

  bool? get remark => _remark;

  set remark(bool? value) {
    _remark = value;
    remarkUpdated();
  }

  bool? get lineThrough => _lineThrough;

  set lineThrough(bool? value) {
    _lineThrough = value;
    remarkUpdated();
  }

  bool? get underline => _underline;

  set underline(bool? value) {
    _underline = value;
    remarkUpdated();
  }

  String? get itemType => _itemType;

  set itemType(String? value) {
    _itemType = value;
    remarkUpdated();
  }

  bool? get checked => _checked;

  set checked(bool? value) {
    _checked = value;
    remarkUpdated();
  }

  double? get fontSize => _fontSize;

  set fontSize(double? value) {
    _fontSize = value;
    remarkUpdated();
  }

  bool? get italic => _italic;

  set italic(bool? value) {
    _italic = value;
    remarkUpdated();
  }

  bool? get bold => _bold;

  set bold(bool? value) {
    _bold = value;
    remarkUpdated();
  }

  int? get background => _background;

  set background(int? value) {
    _background = value;
    remarkUpdated();
  }

  int? get color => _color;

  set color(int? value) {
    _color = value;
    remarkUpdated();
  }

  String? get text => _text;

  set text(String? value) {
    _text = value;
    remarkUpdated();
  }

  @override
  bool get updated {
    if (super.updated) {
      return true;
    }
    if (children != null) {
      for (var child in children!) {
        if (child.updated) {
          return true;
        }
      }
    }
    return false;
  }

  @override
  Map calcJson() {
    var ret = super.calcJson();
    if (children != null) {
      for (var child in children!) {
        child.updated = false;
      }
    }
    return ret;
  }

  @override
  NoteElement toNoteElement() {
    var ret = super.toNoteElement();
    ret.underline = underline ?? false;
    ret.lineThrough = lineThrough ?? false;
    ret.fontSize = fontSize ?? 0;
    ret.itemType = itemType ?? "";
    ret.checked = checked ?? false;
    ret.bold = bold ?? false;
    ret.italic = italic ?? false;
    ret.text = text ?? "";
    ret.color = color ?? 0;
    ret.background = background ?? 0;
    return ret;
  }

  @override
  YMap getYMap() {
    var map = YMap();
    var allAttrs = getAllAttributes();
    for (var attr in allAttrs.entries) {
      map.set(attr.key, attr.value);
    }
    var text = YText();
    map.set("text", text);
    var elements = getElements();
    var length = 0;
    for (var element in elements) {
      if (element.itemType == 'formula') {
        text.insertEmbed(length, {
          'itemType': 'formula',
          'text': element.text,
        });
        length += 1;
      } else {
        text.insert(length, element.text ?? "", element.getTextAttributes());
        length += element.length;
      }
    }
    return map;
  }

  List<WenTextElement> getElements() {
    List<WenTextElement> result = [];
    var text = this.text;
    if (text != null) {
      result.add(WenTextElement(
        text: text,
        color: color,
        background: background,
        bold: bold,
        italic: italic,
        lineThrough: lineThrough,
        underline: underline,
        url: url,
      ));
    }
    var children = this.children;
    if (children != null) {
      for (var child in children) {
        result.add(WenTextElement(
          text: child.text,
          color: child.color ?? color,
          background: child.background ?? background,
          bold: child.bold ?? bold,
          italic: child.italic ?? italic,
          lineThrough: child.lineThrough ?? lineThrough,
          underline: child.underline ?? underline,
          url: child.url ?? url,
          itemType: child.itemType,
        ));
      }
    }
    return result;
  }

  Map<String, Object?> getTextAttributes() {
    Map<String, Object?> result = {
      'color': color,
      'background': background,
      'bold': bold,
      'italic': italic,
      'lineThrough': lineThrough,
      'underline': underline,
      'url': url,
    };
    result.removeWhere((key, value) => value == null);
    return result;
  }

  Map<String, dynamic> getAllAttributes() {
    return super.toJson()
      ..addAll({
        if (text != null) "text": text,
        if (color != null) "color": color,
        if (background != null) "background": background,
        if (bold != null) "bold": bold,
        if (italic != null) "italic": italic,
        if (lineThrough != null) "lineThrough": lineThrough,
        if (underline != null) "underline": underline,
        if (remark != null) "underline": remark,
        if (itemType != null) "itemType": itemType,
        if (checked != null) "checked": checked,
      });
  }
}

class ElementSpanWidget extends StatelessWidget {
  WenTextElement element;

  ElementSpanWidget({Key? key, required this.element}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class TextBlock extends WenBlock {
  WenTextElement textElement;
  InlineSpan? textSpan;
  RichTextPainter? textPainter;
  List<PlaceholderSpan> placeholderSpans = [];
  List<PlaceholderDimensions> dimensions = [];
  Map<String, Size> formulaSizeMap = {};

  TextBlock({
    required super.context,
    required super.editController,
    required this.textElement,
  }) {
    height = 30;
  }

  int get level => textElement.level;

  set level(int val) {
    textElement.level = val;
  }

  @override
  List<TextSelection>? get searchRanges {
    String? searchKey = editController.searchState.searchKey;
    if (searchKey == null || searchKey.isEmpty) {
      return null;
    }
    List<TextSelection> result = [];
    int index = 0;
    do {
      index = textElement
          .getText()
          .toLowerCase()
          .indexOf(searchKey.toLowerCase(), index);
      if (index != -1) {
        result.add(TextSelection(
          baseOffset: index,
          extentOffset: searchKey.length + index,
        ));
        index = index + searchKey.length;
      }
    } while (index != -1);
    return result;
  }

  double get textPainterWidth {
    var indent = textElement.indent ?? 0;
    return max(
        0,
        width -
            indent * indentWidth -
            checkItemWidth -
            quotePaddingHorizontal * 2 -
            quoteBarWidth);
  }

  InlineSpan createTextSpan() {
    var span = textElement.getSpan(
      context: context,
      hoverPositions: [
        if (hoverPosition != null) hoverPosition!,
      ],
      hideModes: editController.hideTextModes ?? [],
    );
    double fontSize = span.style?.fontSize ?? theme.fontSize;
    if (textElement.level > 0) {
      switch (textElement.level) {
        case 1:
          fontSize = theme.fontSize * 2;
          break;
        case 2:
          fontSize = theme.fontSize * 1.5;
          break;
        case 3:
          fontSize = theme.fontSize * 1.25;
          break;
        case 4:
          fontSize = theme.fontSize * 1;
          break;
        case 5:
          fontSize = theme.fontSize * 0.875;
          break;
        case 6:
          fontSize = theme.fontSize * 0.85;
          break;
      }
    }
    var fontColor = theme.fontColor;
    if (textElement.type == "quote") {
      fontColor = fontColor.withOpacity(0.8);
    }
    return TextSpan(
        children: [span],
        style: TextStyle(
          fontWeight: textElement.level == 0 ? null : FontWeight.bold,
          fontSize: fontSize,
          color: fontColor,
          // fontFamilyFallback: const [
          //   "MiSans",
          //   "微软雅黑",
          //   "-apple-system",
          //   "BlinkMacSystemFont",
          //   "Segoe UI",
          //   "Noto Sans",
          //   "Helvetica",
          //   "Arial",
          //   "sans-serif",
          //   "Apple Color Emoji",
          //   "Segoe UI Emoji",
          // ],
          height: textElement.level == 0 ? 1.5 : 1.25,
        ).useSystemChineseFont());
  }

  @override
  bool get canEmpty => true;

  @override
  bool get canIndent => true;

  @override
  WenElement get element => textElement;

  @override
  bool get needClearStyle {
    return (textElement.itemType != null && textElement.itemType != "text") ||
        level > 0;
  }

  double get checkItemWidth {
    if (textElement.itemType == "li") {
      return (textPainter?.preferredLineHeight ?? 16) * 1.2;
    }
    if (textElement.itemType == "check") {
      return (textPainter?.preferredLineHeight ?? 16) * 1.2;
    }
    return 0;
  }

  double get quotePaddingVertical {
    if (element.type == "quote") {
      return 10;
    }
    return 0;
  }

  double get quotePaddingHorizontal {
    if (element.type == "quote") {
      return 10;
    }
    return 0;
  }

  double get quotePaddingTop {
    return getPreviousIsQuote() ? 0 : quotePaddingVertical;
  }

  double get quotePaddingBottom {
    return getNextIsQuote() ? 0 : quotePaddingVertical;
  }

  double get quoteBarWidth {
    if (element.type == "quote") {
      return 4;
    }
    return 0;
  }

  @override
  TextPosition? getPositionForOffset(Offset offset) {
    offset = offset.translate(
        -alignmentOffsetX - (width - textPainterWidth - quotePaddingHorizontal),
        -quotePaddingTop);
    return textPainter?.getPositionForOffset(offset);
  }

  @override
  TextRange? getWordBoundary(TextPosition textPosition) {
    return textPainter?.getWordBoundary(textPosition);
  }

  @override
  TextRange? getLineBoundary(TextPosition textPosition) {
    return textPainter?.getLineBoundary(textPosition);
  }

  double get alignmentOffsetX {
    if (element.alignment == "right") {
      return (textPainterWidth - (textPainter?.width ?? 0));
    } else if (element.alignment == "center") {
      return (textPainterWidth - (textPainter?.width ?? 0)) / 2;
    }
    return 0;
  }

  @override
  List<ui.TextBox> getBoxesForSelection(TextSelection selection) {
    if (isEmpty) {
      if (editController.cursorState.cursorPosition?.block == this) {
        return [];
      }
      return [
        ui.TextBox.fromLTRBD(
            width - textPainterWidth - quotePaddingHorizontal,
            quotePaddingTop,
            width - textPainterWidth + 2,
            height,
            TextDirection.ltr)
      ];
    }
    return (textPainter
            ?.getBoxesForSelection(
          selection,
          boxWidthStyle: ui.BoxWidthStyle.tight,
          boxHeightStyle: ui.BoxHeightStyle.max,
        )
            .map((e) {
          var rect = e.toRect().translate(
              width -
                  textPainterWidth -
                  quotePaddingHorizontal +
                  alignmentOffsetX,
              quotePaddingTop);
          return ui.TextBox.fromLTRBD(
              rect.left, rect.top, rect.right, rect.bottom, e.direction);
        }).toList()) ??
        [];
  }

  @override
  Rect? getCursorRect(TextPosition textPosition) {
    var offset = textPainter?.getOffsetForCaret(
            textPosition, const Rect.fromLTWH(0, 0, 2, 2)) ??
        Offset.zero.translate(1, 0);

    var height = textPainter?.getFullHeightForCaret(textPosition, Rect.zero);
    offset = offset.translate(
        width - textPainterWidth - quotePaddingHorizontal, quotePaddingTop);
    offset = offset.translate(alignmentOffsetX, 0);
    if (height != null) {
      return offset.translate(-1, 0) & Size(2, height);
    }
    return offset.translate(-1, 0) &
        Size(2, this.height - (quotePaddingTop + quotePaddingBottom));
  }

  @override
  void layout(BuildContext context, Size viewSize) {
    this.context = context;
    TextStyle? style = this.textSpan?.style;
    var relayout = EditTheme.of(context).fontColor != style?.color;
    if (viewSize.width <= 0) {
      return;
    }
    if (!relayout) {
      if (!relayoutFlag && width == viewSize.width) {
        return;
      }
    }
    relayoutFlag = false;
    width = viewSize.width;
    var textSpan = createTextSpan();
    var dimensions = <PlaceholderDimensions>[];
    var widgetSpans = <PlaceholderSpan>[];
    calcPlaceHolderDimensions(textSpan, widgetSpans, context, dimensions);
    placeholderSpans = widgetSpans;
    this.dimensions = dimensions;
    var richTextPainter = RichTextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      strutStyle: StrutStyle.fromTextStyle(
        textSpan.style ?? const TextStyle(),
        forceStrutHeight: false,
      ),
      textHeightBehavior: const TextHeightBehavior(
        applyHeightToLastDescent: true,
        applyHeightToFirstAscent: true,
      ),
      textAlign: calcTextAlign(),
      textScaleFactor: 1.02,
    );

    if (dimensions.isNotEmpty) {
      richTextPainter.setPlaceholderDimensions(dimensions);
    }
    richTextPainter.layout(maxWidth: textPainterWidth);
    this.textSpan = textSpan;
    textPainter = richTextPainter;
    height = richTextPainter.height + quotePaddingTop + quotePaddingBottom;
  }

  void calcPlaceHolderDimensions(
      InlineSpan textSpan,
      List<PlaceholderSpan> widgetSpans,
      BuildContext context,
      List<PlaceholderDimensions> dimensions) {
    textSpan.visitChildren((InlineSpan span) {
      if (span is PlaceholderSpan) {
        widgetSpans.add(span);
        if (span is WidgetSpan) {
          var child = span.child;
          if (child is ElementSpanWidget) {
            var element = child.element;
            if (element.itemType == "formula") {
              var size = formulaSizeMap.putIfAbsent(element.text ?? "", () {
                var tex = Math.tex(
                  element.text ?? "",
                  textStyle: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: Colors.black),
                );
                if (tex.ast == null) {
                  return const Size(30, 20);
                }
                return calcWidgetSize(
                  tex,
                  maxSize: const Size(1000, 100),
                  context: context,
                );
              });
              dimensions.add(PlaceholderDimensions(
                  size: size, alignment: ui.PlaceholderAlignment.baseline));
              return true;
            }
          }
        }
        dimensions.add(const PlaceholderDimensions(
            size: Size(10, 10), alignment: ui.PlaceholderAlignment.baseline));
      }
      return true;
    });
  }

  @override
  List<PopupPositionWidget> buildFloatWidgets() {
    List<PopupPositionWidget> result = [];
    return result;
  }

  @override
  double get indentWidth {
    if (element.type == "quote") {
      return 10;
    }
    return super.indentWidth;
  }

  /// 注意这里要对table cell进行处理，table cell不支持直接与editController交互
  @override
  List<PopupPositionWidget> buildBackgroundWidgets() {
    List<PopupPositionWidget> result = [];
    if (textElement.type == "quote") {
      var startIndex = blockIndex;
      var endIndex = startIndex;
      var startY = blocks[startIndex].top - divideWidth / 2;
      var endY =
          blocks[endIndex].top + blocks[endIndex].height + divideWidth / 2;

      ///背景
      result.add(PopupPositionWidget(
          top:
              startY + editController.padding.top - editController.scrollOffset,
          left: editController.padding.left,
          width: width,
          height: min(endY - startY, editController.visionHeight),
          child: Container(
            color: theme.quoteBgColor,
          )));

      ///线条
      result.add(PopupPositionWidget(
          top:
              startY + editController.padding.top - editController.scrollOffset,
          left: editController.padding.left,
          width: quoteBarWidth,
          height: min(endY - startY, editController.visionHeight),
          child: Container(
            color: theme.quoteBarColor,
          )));
    }
    return result;
  }

  bool getPreviousIsQuote() {
    var previous = previousBlock;
    if (previous is TextBlock) {
      if (previous.element.type == "quote") {
        return true;
      }
    }
    return false;
  }

  bool getNextIsQuote() {
    var previous = nextBlock;
    if (previous is TextBlock) {
      if (previous.element.type == "quote") {
        return true;
      }
    }
    return false;
  }

  int getTheSameTypeIndex() {
    var index = blockIndex;
    var count = blockCount;
    var blocks = this.blocks;
    var endIndex = index;
    for (var i = index; i < count; i++) {
      if (blocks[i].element.type != element.type) {
        return endIndex;
      }
      endIndex = i;
    }
    return endIndex;
  }

  bool isQuote(WenBlock? block) {
    return block != null && block.element.type == "quote";
  }

  Widget buildCheckItem(BuildContext context) {
    return ToggleItem(
      itemBuilder:
          (BuildContext context, bool checked, bool hover, bool pressed) {
        return fluent.Checkbox(
          checked: checked,
          onChanged: (val) {
            textElement.checked = val;
            if (editController.editable) {
              editController.requestFocus();
            }
            editController.changeBlockChecked(this, val);
          },
        );
      },
      checked: textElement.checked == true,
    );
  }

  @override
  Widget buildWidget(BuildContext context) {
    this.context = context;
    Widget? itemWidget;
    if (textElement.itemType == "li") {
      itemWidget = Icon(
        Icons.circle,
        size: 5,
        color: theme.fontColor,
      );
    } else if (textElement.itemType == "check") {
      itemWidget = IgnoreParentPointer(
        child: buildCheckItem(context),
      );
    }
    var spanWidgets = <Widget>[];
    var placeholders = textPainter?.inlinePlaceholderBoxes;
    if (placeholders != null) {
      for (int i = 0; i < placeholders.length; i++) {
        var sizeBox = placeholders[i].toRect();
        var placeholderSpan = placeholderSpans[i];
        if (placeholderSpan is WidgetSpan) {
          var child = placeholderSpan.child;
          if (child is ElementSpanWidget) {
            spanWidgets.add(
              Positioned(
                left: sizeBox.left + alignmentOffsetX,
                top: sizeBox.top,
                child: Builder(builder: (context) {
                  return MouseRegion(
                    cursor: MaterialStateMouseCursor.clickable,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () async {
                        var formula = await showDialog(
                            useSafeArea: true,
                            context: context,
                            builder: (context) {
                              return FormulaWidget(
                                formula: child.element.text,
                                title: "输入公式",
                              );
                            });
                        if (formula is Map && formula["ok"] == true) {
                          relayoutFlag = true;
                          editController.updateFormula(
                              this, child.element, formula["formula"]);
                        }
                      },
                      child: buildDragItem(Math.tex(
                        child.element.text ?? "",
                        textStyle: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w400),
                      )),
                    ),
                  );
                }),
              ),
            );
          }
        }
      }
    }
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.only(
        top: quotePaddingTop,
        bottom: quotePaddingBottom,
        left: quotePaddingHorizontal + quoteBarWidth,
        right: quotePaddingHorizontal,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: (element.indent ?? 0) * indentWidth,
          ),
          if (textElement.itemType != null && textElement.itemType != "")
            SizedBox(
              width: checkItemWidth,
              height: checkItemWidth,
              child: Center(child: itemWidget),
            ),
          Expanded(
            child: MouseRegion(
              // cursor: SystemMouseCursors.text,
              child: Stack(
                children: [
                  Container(
                    alignment: calcAlignment(),
                    child: SizedBox(
                      width: textPainter?.width,
                      child: textPainter == null
                          ? Container()
                          : CustomPaint(
                              painter: RichPainter(
                                painter: textPainter!,
                              ),
                            ),
                    ),
                  ),
                  ...spanWidgets,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  int deletePosition(TextPosition textPosition) {
    int len = length;
    relayoutFlag = true;
    textElement.delete(textPosition);
    return len - length;
  }

  @override
  void inputText(EditController controller, TextEditingValue text,
      {bool isComposing = false}) {
    var position = controller.cursorState.cursorPosition;
    if (position == null) {
      return;
    }
    var textPosition = position.textPosition;
    if (textPosition == null) {
      return;
    }

    int offset = textPosition.offset + text.text.length;
    if (isComposing) {
      textElement.insertElement(
          textPosition, WenTextElement(text: text.text, underline: true));
    } else {
      textElement.inputText(textPosition, text);
    }
    relayoutFlag = true;
    controller.layoutCurrentBlock(this);
    var newTextPosition = position.textPosition = TextPosition(
      offset: offset,
      affinity: textPosition.affinity,
    );
    position.rect = getCursorRect(newTextPosition);
    controller.toPosition(position, true, applyUpdate: isComposing == false);
  }

  @override
  WenBlock? mergeBlock(WenBlock endBlock) {
    if (endBlock is TextBlock) {
      if (isEmpty) {
        endBlock.top = top;
        return endBlock;
      }
      textElement.merge(endBlock.textElement);
      relayoutFlag = true;
      return this;
    }
    return null;
  }

  @override
  void deleteRange(TextPosition start, TextPosition end) {
    relayoutFlag = true;
    textElement.deleteRange(start, end);
  }

  @override
  WenBlock splitBlock(TextPosition textPosition) {
    relayoutFlag = true;
    WenTextElement element = textElement.splitText(textPosition);
    if (element.length == 0) {
      return TextBlock(
          editController: editController,
          context: context,
          textElement: WenTextElement(type: textElement.type));
    }
    return TextBlock(
      editController: editController,
      context: context,
      textElement: element..level = level,
    );
  }

  @override
  int get length => textElement.length;

  @override
  WenElement copyElement(TextPosition start, TextPosition end) {
    return textElement.subElement(start, end);
  }

  @override
  BlockLink? getLink(ui.TextPosition textPosition) {
    var element = textElement.getLink(textPosition);
    if (element != null) {
      return BlockLink(textElement: element, textOffset: element.offset);
    }
    return null;
  }

  @override
  WenElement? getElement(ui.TextPosition textPosition) {
    return textElement.getElement(textPosition);
  }

  @override
  void visitElement(
      ui.TextPosition start, ui.TextPosition end, WenElementVisitor visit) {
    var startIndex = start.offset;
    var endIndex = end.offset;
    if (startIndex < textElement.textLength ||
        (startIndex == 0 && textElement.textLength == 0)) {
      visit.call(this, textElement);
    }
    var children = textElement.children;
    if (children != null) {
      for (var child in children) {
        int childStartIndex = child.offset;
        int childEndIndex = child.offset + child.textLength;
        if (childStartIndex >= startIndex && childStartIndex < endIndex) {
          visit.call(this, child);
        } else if (childEndIndex > startIndex && childEndIndex < endIndex) {
          visit.call(this, child);
        } else if (startIndex >= childStartIndex &&
            startIndex < childEndIndex) {
          visit.call(this, child);
        } else if (endIndex > childStartIndex && endIndex < childEndIndex) {
          visit.call(this, child);
        }
      }
    }
  }
}
