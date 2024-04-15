import 'dart:convert';
import 'dart:io';

import 'package:wenznote/editor/crdt/doc_utils.dart';
import 'package:ydart/utils/y_doc.dart';
/// 合并之后得到一堆gc
void main()async{
  var file = File("./local/user-1/notes/c105b9c0-d4ae-11ee-b836-390d3f057077.wnote");

  var oldFile = File("./demo/oldData.data");
  print(await oldFile.length());
  var newFile = File("./demo/newData.data");
  var doc = YDoc();
  doc.applyUpdateV2(file.readAsBytesSync());
  var elements = yDocToWenElements(doc);
  var text = elements.map((e) => e.getMarkDown()).join("\n");
  print(text);
}