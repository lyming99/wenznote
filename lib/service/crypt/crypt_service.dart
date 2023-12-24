import 'dart:typed_data';

/// 加解密算法，建议使用 kms 算法
class CryptService {
  static Future<Uint8List> encode(Uint8List data) async {
    return data;
  }

  static Future<Uint8List> decode(Uint8List data) async {
    return data;
  }
}
