import 'dart:typed_data';

import 'package:ydart/lib0/byte_input_stream.dart';
import 'package:ydart/lib0/byte_output_stream.dart';

typedef EncryptFunction = Uint8List Function(Uint8List);
typedef DecryptFunction = Uint8List Function(Uint8List);

class EncryptByteArrayInputStream extends ByteArrayInputStream {
  final DecryptFunction decrypt;

  EncryptByteArrayInputStream(super.bytes, this.decrypt);

  @override
  String readVarString() {
    int remainingLen = readVarUint();
    if (remainingLen == 0) {
      return '';
    }
    Uint8List data = readNBytes(remainingLen);
    var dec = decrypt.call(data);
    var str = String.fromCharCodes(dec);
    return Uri.decodeComponent(str);
  }
}

class EncryptByteArrayOutputStream extends ByteArrayOutputStream {
  final EncryptFunction encrypt;

  EncryptByteArrayOutputStream(this.encrypt);

  @override
  void writeVarString(String str) {
    var value = Uri.encodeComponent(str);
    var data = Uint8List.fromList(value.codeUnits);
    var enc = encrypt.call(data);
    writeVarUint(enc.length);
    writeBytes(enc);
  }
}
