import 'package:wenznote/editor/block/code/code.dart';
import 'package:wenznote/editor/block/image/image_element.dart';
import 'package:wenznote/editor/block/line/line_element.dart';
import 'package:wenznote/editor/block/table/table_element.dart';
import 'package:wenznote/editor/block/text/text.dart';
import 'package:wenznote/editor/proto/note.pb.dart';
import 'package:uuid/uuid.dart';
import 'package:ydart/ydart.dart';

typedef FilePathBuilder = String Function(String uuid);

const clearStyleMap = {
  "color": null,
  "bold": null,
  "italic": null,
  "fontSize": null,
  "underline": null,
  "lineThrough": null,
  "background": null,
};

class WenElement {
  bool _newLine = false;
  String _type = "unkown";
  int _level = 0;
  int? _indent;
  String? _url;
  int _offset = 0;
  String? _alignment;
  bool _updated = false;
  Map? _json;
  int length = 0;
  bool hideText = true;

  WenElement({
    bool newLine = false,
    String type = "unkown",
    int level = 0,
    String? url,
    int offset = 0,
    int? indent,
    String? alignment,
  }) {
    _newLine = newLine;
    _type = type;
    _level = level;
    _url = url;
    _offset = offset;
    _indent = indent;
    _alignment = alignment;
  }

  String getHtml({FilePathBuilder? filePathBuilder}) {
    return "";
  }

  String getText() {
    return "";
  }

  String getMarkDown({FilePathBuilder? filePathBuilder}) {
    return "";
  }

  Map<String, dynamic> toJson() {
    return {
      if (newLine) "newLine": newLine,
      "type": type,
      "level": level,
      if (url != null) "url": url,
      if (indent != null) "indent": indent,
      if (alignment != null) "alignment": alignment,
    };
  }

  Map calcJson() {
    if (_json == null || updated) {
      _json = toJson();
      _updated = false;
    }
    return _json!;
  }

  void remarkUpdated() {
    _updated = true;
  }

  factory WenElement.fromJson(Map json) {
    return WenElement(
      newLine: json["newLine"] == true,
      type: json["type"],
      level: json["level"],
      url: json["url"],
      indent: json["indent"],
      alignment: json["alignment"],
    ).._json = json;
  }

  void copyProperties(WenElement other) {
    _offset = other._offset;
    _newLine = other._newLine;
    _type = other._type;
    _level = other._level;
    _url = other._url;
    _indent = other._indent;
    _alignment = other._alignment;
  }

  factory WenElement.parseJson(Map<dynamic, dynamic> json) {
    switch (json['type']) {
      case "title":
      case "text":
      case "quote":
        return WenTextElement.fromJson(json);
      case "image":
        return WenImageElement.fromJson(json);
      case "code":
        return WenCodeElement.fromJson(json);
      case "table":
        return WenTableElement.fromJson(json);
      case "line":
        return LineElement();
    }
    return WenElement.fromJson(json);
  }

  void clearStyle() {
    url = null;
    alignment = null;
    indent = null;
  }

  static String createUuid() {
    return const Uuid().v1();
  }

  /// quote/text/title/image/code/table/line
  String get type => _type;

  set type(String value) {
    _type = value;
    remarkUpdated();
  }

  int get level => _level;

  set level(int value) {
    _level = value;
    remarkUpdated();
  }

  int? get indent => _indent;

  set indent(int? value) {
    _indent = value;
    remarkUpdated();
  }

  String? get url => _url;

  set url(String? value) {
    _url = value;
    remarkUpdated();
  }

  int get offset => _offset;

  set offset(int value) {
    _offset = value;
    remarkUpdated();
  }

  String? get alignment {
    return _alignment;
  }

  set alignment(String? val) {
    _alignment = val;
    remarkUpdated();
  }

  bool get newLine => _newLine;

  set newLine(bool value) {
    _newLine = value;
    remarkUpdated();
  }

  bool get updated => _updated;

  set updated(val) {
    _updated = val;
  }

  NoteElement toNoteElement() {
    var ret = NoteElement();
    ret.type = type;
    ret.newline = newLine;
    ret.level = level;
    ret.indent = indent ?? 0;
    ret.url = url ?? "";
    ret.alignment = alignment ?? "";
    return ret;
  }

  YMap getYMap() {
    var map = YMap();
    var allAttrs = toJson();
    for (var attr in allAttrs.entries) {
      if (attr is List) {
        continue;
      }
      if (attr is Map) {
        continue;
      }
      map.set(attr.key, attr.value);
    }
    return map;
  }
}

/// 分割element用的，并不会保存到实质文件
class WenSplitElement extends WenElement {
  WenSplitElement({super.type = "split"});

  @override
  String getMarkDown({FilePathBuilder? filePathBuilder}) {
    return "";
  }
}

class WenElementStyle {
  String? type;
  int? level;
  int? color;
  int? background;
  bool? bold;
  bool? italic;
  double? fontSize;
  String? fontFamily;
  bool newLine;

  String? url;
  String? src;

  bool? lineThrough;

  bool? underline;
  bool? remark;

  int? indent;

  String? itemType;

  String? alignment;

  WenElementStyle copy() {
    return WenElementStyle(
      type: type,
      color: color,
      background: background,
      bold: bold,
      italic: italic,
      fontSize: fontSize,
      fontFamily: fontFamily,
      lineThrough: lineThrough,
      underline: underline,
      url: url,
      level: level,
      src: src,
      newLine: newLine,
      indent: indent,
      itemType: itemType,
    );
  }

  WenElementStyle({
    this.type,
    this.color,
    this.background,
    this.bold,
    this.italic,
    this.fontSize,
    this.fontFamily,
    this.lineThrough,
    this.remark,
    this.underline,
    this.url,
    this.src,
    this.level,
    this.newLine = false,
    this.indent,
    this.itemType,
  });
}
