import 'package:flutter_crdt/flutter_crdt.dart';
import 'package:flutter_crdt/lib0/decoding.dart';
import 'package:flutter_crdt/lib0/encoding.dart';

void main() {
  var encoder = Encoder();
  writeVarUint(encoder, 2656000000001);
  var decoder = Decoder(encoder.cbuf);
  var read = readVarUint(decoder);
  print('$read');
  var doc = Doc();
  doc.on("update", (p0) {
    print('update...');
  });

  var map = doc.getMap("map");
  var text = map.set("text", YText()) as YText;
  text.observe((eventType, transaction) {
    print('hello');
  });
  text.insert(0, "text");
  text.insert(0, "woca");
  var re = createRelativePositionFromTypeIndex(text, 8);
  text.insert(8, "hello");
  var pos = createAbsolutePositionFromRelativePosition(re, doc);
  var type = pos?.type;
  var index = pos?.index;
  print('$index');
  print('$type');
}

void printLen(Doc doc) {
  print('doc len:${encodeStateAsUpdateV2(doc, null).length}');
}
