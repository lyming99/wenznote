import 'dart:convert';
import 'dart:io';

import 'package:wenznote/editor/crdt/doc_utils.dart';
import 'package:ydart/utils/y_doc.dart';

void searchFile(String path) {
  if (path.contains("0ea76bf0")) {
    print('$path');
    return;
  }
  var isDir = File(path).statSync().type == FileSystemEntityType.directory;
  if (isDir) {
    var list = Directory(path).listSync();
    for (var element in list) {
      searchFile(element.path);
    }
  }
}

void main() {
  searchFile(
      "/Users/lyming/Library/Containers/cn.wennote.app/Data/Documents/");
  var dir = Directory(
      "/Users/lyming/Library/Containers/cn.wennote.app/Data/Documents/user-local/notes/");
  var list = dir.listSync();
  for (var item in list) {
    var isFile = item.statSync().type == FileSystemEntityType.file;
    if (isFile) {
      var file = File(item.path);
      try {
        var doc = YDoc();
        doc.applyUpdateV2(file.readAsBytesSync());
        var elements = yDocToWenElements(doc);
        var jsonList = elements.map((e) => e.toJson()).toList();
        var str = jsonEncode(jsonList);
        // if(str.contains("实践")&&str.contains("打坐")){
        print('$str');
        // }
      } catch (e) {
        print(e);
      }
    }
  }
}
