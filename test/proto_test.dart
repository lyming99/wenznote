import 'package:wenznote/editor/proto/note.pb.dart';

void testJson() {
  NoteElement element = NoteElement(
    id: "111",
    text: "wocao",
    children: [
      NoteElement(rows: [
        NoteElement_Row(items: [
          for (int i = 0; i < 100000; i++)
            NoteElement(
              type: "text",
            )
        ]),
      ])
    ],
  );
  var st = DateTime.now().millisecondsSinceEpoch;
  var buff = element.writeToJson();
  NoteElement.fromJson(buff);
  var jsonLength = buff.length;
  print("json time: ${DateTime.now().millisecondsSinceEpoch - st} ms");
  print('json length:$jsonLength');
}

void testProto() {
  NoteElement element = NoteElement(
    id: "111",
    text: "hello",
    children: [
      NoteElement(rows: [
        NoteElement_Row(items: [
          for (int i = 0; i < 100000; i++)
            NoteElement(
              type: "text",
            )
        ]),
      ])
    ],
  );
  var st = DateTime.now().millisecondsSinceEpoch;
  var buffer = element.writeToBuffer();
  NoteElement.fromBuffer(buffer);
  print("proto time: ${DateTime.now().millisecondsSinceEpoch - st} ms");
  print('proto length:${buffer.length}');
}

void main() {
  testJson();
  testProto();
}
