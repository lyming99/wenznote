import 'package:uuid/uuid.dart';

void main() async {
  var uuid = Uuid();
  var a = uuid.v1();
  var b = uuid.v1();
  var c = uuid.v1();
  print('a:$a');
  print('b:$b');
  print('c:$c');
}
