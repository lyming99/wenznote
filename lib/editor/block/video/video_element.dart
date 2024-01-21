import 'package:wenznote/editor/block/element/element.dart';

import '../../proto/note.pb.dart';

class VideoElement extends WenElement {
  String _id = "";
  String _file = "";
  int _width = 0;
  int _height = 0;

  VideoElement({
    required String id,
    required String file,
    required int width,
    required int height,
    super.type = "video",
  }) {
    _id = id;
    _file = file;
    _width = width;
    _height = height;
  }

  VideoElement copy() {
    return VideoElement(
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
    return "";
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

  factory VideoElement.fromJson(Map<dynamic, dynamic> json) {
    return VideoElement(
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
