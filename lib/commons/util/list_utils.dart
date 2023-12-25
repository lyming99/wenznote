import 'dart:collection';

extension on List<dynamic> {
  Map groupBy(Object Function(Object o) map) {
    Map result = HashMap();
    for (var item in this) {
      var key = map.call(item);
      var list = result[key];
      list ??= [];
      (list as List).add(item);
    }
    return result;
  }
}

