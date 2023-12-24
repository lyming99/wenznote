import 'dart:collection';
import 'dart:io';

import 'package:flutter/cupertino.dart';

void main() {
  var file = File("./temp/test.txt");
  var txt = file.readAsStringSync();
  var wSet = HashSet();
  var hSet = HashSet();
  var p =
      TextPainter(textDirection: TextDirection.ltr, text: TextSpan(text: txt))
        ..layout(maxWidth: 1000);
  for (var i = 0; i < txt.length; i++) {
    var boxes = p.getBoxesForSelection(
        TextSelection(baseOffset: i, extentOffset: i + 1));
    if (boxes.isNotEmpty) {
      var rect = boxes[0].toRect();
      if (wSet.contains(rect.width) || hSet.contains(rect.height)) {
        continue;
      }
      wSet.add(rect.width);
      hSet.add(rect.height);
      print('width:${rect.width} height:${rect.height}');
    }
  }
  var p2 = TextPainter(textDirection: TextDirection.ltr, text: TextSpan(text: "1",style: TextStyle(fontFamily: "微软雅黑")))
    ..layout(maxWidth: 1000);
  print('${p2.width}--${p2.height}');
  var p3 = TextPainter(textDirection: TextDirection.ltr, text: TextSpan(text: "我",style: TextStyle(fontFamily: "微软雅黑")))
    ..layout(maxWidth: 1000);
  print('${p3.width}--${p3.height}');
}
