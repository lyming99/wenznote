import 'dart:io';

import 'package:wenznote/commons/util/mehod_time_record.dart';
import 'package:ydart/utils/y_doc.dart';

void main() async{
  var path = "D:/project/wen-note-app/local/user-1/notes/cb7fa6c0-e419-11ee-8c9c-6dd9f6d9736c.wnote";
  var file = File(path);
  var bytes = file.readAsBytesSync();
  var doc = YDoc();
  await file.withLog(() {
    doc.applyUpdateV2(bytes);
  }, logTitle: "decodeDoc");
  await file.withLog(() {
    doc.encodeStateAsUpdateV2();
  }, logTitle: "encodeDoc");
}
