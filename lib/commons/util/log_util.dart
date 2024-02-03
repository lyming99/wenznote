import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

void printLog(String log) {
  if(kDebugMode&&Platform.isWindows) {
    var file = File("log.txt");
    file.writeAsBytesSync(utf8.encode("$log\n"), mode: FileMode.append);
  }
}
