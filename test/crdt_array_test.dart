import 'package:flutter_crdt/flutter_crdt.dart';

void main() {
  var doc = Doc();
  var map = doc.getArray("map");
  map.observeDeep((eventType, transaction) {
    print('${eventType}');
    var first = eventType.first;
    if(first is YArrayEvent){
      var path = first.path;
      var keys = first.keys;
      var delta = first.delta;
      var changes = first.changes;
      var added = changes.added;
      var dels = changes.deleted;
      print('wocao');
    }
  });
  map.insert(0, [1]);
  map.insert(0, [2]);
  map.insert(0, [3]);
  map.insert(1, [1]);
  print('hlleo');
}

void printLen(Doc doc) {
  print('doc len:${encodeStateAsUpdateV2(doc, null).length}');
}
