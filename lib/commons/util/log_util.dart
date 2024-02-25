import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

void printLog(String log) {
  if (kDebugMode && Platform.isWindows) {
    var file = File("log.txt");
    var time = DateTime.now().toIso8601String();
    var logFormat = "[$time] $log";
    print(logFormat);
    file.writeAsBytesSync(utf8.encode("$logFormat\n"), mode: FileMode.append);
  }
}
