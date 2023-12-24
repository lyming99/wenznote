import 'package:uuid/uuid.dart';

void main() {
  var map = {};
  var start=DateTime.now().millisecondsSinceEpoch;
  for(var i=0;i<10000;i++) {
    var uuid = Uuid().v1();
    if(map.containsKey(uuid)){
      print('repeat');
      break;
    }
    map[uuid]=true;
  }
  var end = DateTime.now().millisecondsSinceEpoch;
  print('use time: ${end-start} ms');
}
