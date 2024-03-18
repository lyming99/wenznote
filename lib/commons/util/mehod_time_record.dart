import 'dart:async';

import 'package:synchronized/extension.dart';
import 'package:wenznote/commons/util/log_util.dart';

extension MethodTimeRecord on Object {
  Future<T> synchronizedWithLog<T>(
    FutureOr<T> Function() computation, {
    Duration? timeout,
    String? logTitle,
  }) {
    printLog("[$logTitle] start.");
    var dateStart = DateTime.now();
    try {
      return synchronized(computation, timeout: timeout);
    } finally {
      var dateEnd = DateTime.now();
      printLog(
          "[$logTitle] use time: ${dateEnd.millisecondsSinceEpoch - dateStart.millisecondsSinceEpoch}ms");
    }
  }

  Future<T> withLog<T>(
    FutureOr<T> Function() computation, {
    Duration? timeout,
    String? logTitle,
  }) async {
    printLog("[$logTitle] start.");
    var dateStart = DateTime.now();
    try {
      return await computation.call();
    } finally {
      var dateEnd = DateTime.now();
      printLog(
          "[$logTitle] use time: ${dateEnd.millisecondsSinceEpoch - dateStart.millisecondsSinceEpoch}ms");
    }
  }
}
