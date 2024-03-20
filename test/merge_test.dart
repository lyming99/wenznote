import 'dart:convert';
import 'dart:io';

import 'package:wenznote/editor/crdt/doc_utils.dart';
import 'package:ydart/utils/y_doc.dart';
/// 合并之后得到一堆gc
void main()async{
  var oldFile = File("./demo/oldData.data");
  print(await oldFile.length());
  var newFile = File("./demo/newData.data");
  var doc = YDoc();
  doc.applyUpdateV2(oldFile.readAsBytesSync());
  print(jsonEncode(yDocToWenElements(doc).map((e) => e.toJson()).toList()));
  doc.applyUpdateV2(newFile.readAsBytesSync());
  print(jsonEncode(yDocToWenElements(doc).map((e) => e.toJson()).toList()));

}