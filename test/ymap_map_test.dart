import 'package:ydart/types/y_map.dart';

void main() {
  var testCount = 100000;
  var cache = <YMap, Object>{};
  for (var i = 0; i < testCount; i++) {
    var map = YMap();
    if (!cache.containsKey(map)) {
      cache[map] = Object();
    }
  }
  print(cache.length);
  assert(cache.length == testCount);
}
