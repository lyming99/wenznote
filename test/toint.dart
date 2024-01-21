

import 'package:wenznote/commons/util/serial_util.dart';

void main() {
  var bytes = writeInt32(-100);
  var result = readInt32(bytes, 0);
  print('${result==-100}');
}
