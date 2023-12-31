import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';

Future<Uint8List> encode(Uint8List data) async {
  Key key = Key.fromUtf8("my32lengthsupersecretnooneknows1");
  var iv = IV.fromUtf8("1234567812345678");
  var encrypter = Encrypter(AES(key, mode: AESMode.cbc));
  var result = encrypter.encryptBytes(data, iv: iv);
  return result.bytes;
}

Future<Uint8List> decode(Uint8List data) async {
  var iv = IV.fromUtf8("1234567812345678");
  Key key = Key.fromUtf8("my32lengthsupersecretnooneknows1");
  var encrypter = Encrypter(AES(key, mode: AESMode.cbc));
  var result = encrypter.decryptBytes(Encrypted(data), iv: iv);
  return Uint8List.fromList(result);
}

void main() async {
  print('hello world!');
  String s = "hello" * 4;
  var bytes = utf8.encode(s);
  var enc = await encode(Uint8List.fromList(bytes));
  var dec = await decode(enc);

  print('bytes length:${bytes.length}');
  print('enc length:${enc.length}');
  print('dec length:${dec.length}');
  print("dec result:${utf8.decode(dec)}");
}
