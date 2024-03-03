import 'package:flutter_crdt/flutter_crdt.dart';

void main() {
  var doc = Doc();
  doc.clientID = 1;
  var text = doc.getText("text");
  text.insert(0, "hello");
  
}

void printLen(Doc doc) {
  print('doc len:${encodeStateAsUpdateV2(doc, null).length}');
}
