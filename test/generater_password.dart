import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

void main(){
  var pwd = generatePassword("1");
  var b64 = Key.fromBase64(pwd);
  print(b64.base16);
}
String generatePassword(String password) {
  final bytes = utf8.encode(password);
  final sha256Str = sha256.convert(bytes);
  return base64Encode(sha256Str.bytes.sublist(0, 32));
}