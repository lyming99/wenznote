import 'package:flutter_crdt/flutter_crdt.dart';

import '../../proto/note.pb.dart';
import '../element/element.dart';

class WenImageElement extends WenElement {
  String _id = "";
  String _file = "";
  int _width = 0;
  int _height = 0;

  WenImageElement({
    required String id,
    required String file,
    required int width,
    required int height,
    super.type = "image",
  }) {
    _id = id;
    _file = file;
    _width = width;
    _height = height;
  }

  WenImageElement copy() {
    return WenImageElement(
      id: id,
      file: file,
      width: width,
      height: height,
    );
  }

  @override
  String getHtml({FilePathBuilder? filePathBuilder}) {
    return '<img src="$file" id="$id" width="$width" height="$height" file="$file"/>';
  }

  @override
  String getMarkDown({FilePathBuilder? filePathBuilder}) {
    return "![](${filePathBuilder?.call(id) ?? ("assets/$id")})";
  }

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    json.addAll({
      "id": id,
      "file": file,
      "width": width,
      "height": height,
    });
    return json;
  }
  factory WenImageElement.fromJson(Map<dynamic, dynamic> json) {
    return WenImageElement(
      id: json["id"] ?? "0",
      file: json["file"] ?? "",
      width: json["width"] ?? 0,
      height: json["height"] ?? 0,
    )..copyProperties(WenElement.fromJson(json));
  }

  String get file => _file;

  set file(String value) {
    _file = value;
    remarkUpdated();
  }

  int get width => _width;

  set width(int value) {
    _width = value;
    remarkUpdated();
  }

  int get height => _height;

  set height(int value) {
    _height = value;
    remarkUpdated();
  }

  String get id => _id;

  set id(String value) {
    _id = value;
    remarkUpdated();
  }

  @override
  NoteElement toNoteElement() {
    var ret = super.toNoteElement();
    ret.id = id;
    ret.file = file;
    ret.width = width;
    ret.height = height;
    return ret;
  }
}
