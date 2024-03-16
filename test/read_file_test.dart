import 'dart:io';

import 'package:ydart/utils/y_doc.dart';

void main() {
  var bytes = File(
          "/Users/***/Library/Containers/cn.wennote.app/Data/Documents/user-1/notes/7cd9ca90-babc-11ee-b0a6-7d5dbd3db2fd.wnote")
      .readAsBytesSync();

  var doc = YDoc();
  doc.applyUpdateV2(bytes);
}
