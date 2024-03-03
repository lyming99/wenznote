import 'package:flutter_crdt/flutter_crdt.dart';

void main(){
  Doc doc = Doc();
  var state = 1;
  doc.on('update', (args) {
    print("on update content:$state");
  });
  doc.transact((transaction) {
    state=2;
    doc.getText("hello").insert(0, "hello");
    print("update end...");
  });
  doc.transact((transaction) {
    state=3;
    doc.getText("hello").insert(0, "hello");
    print("update end...");
  });
}