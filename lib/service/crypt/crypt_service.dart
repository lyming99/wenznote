import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:wenznote/service/service_manager.dart';

/// 加解密算法，建议使用 kms 算法
class CryptService {
  ServiceManager serviceManager;

  CryptService(this.serviceManager);

  Key key = Key.fromUtf8("my 32 length key................");

  Uint8List encode(Uint8List data)   {
    if (serviceManager.userService.currentUser == null) {
      return data;
    }
    // var encrypter = Encrypter(AES(key));
    // var result = encrypter.encryptBytes(data, iv: IV.fromLength(16));
    // return result.bytes;
    return data;
  }

  Uint8List  decode(Uint8List data)   {
    if (serviceManager.userService.currentUser == null) {
      return data;
    }
    // var encrypter = Encrypter(AES(key));
    // var result = encrypter.decryptBytes(Encrypted(data), iv: IV.fromLength(16));
    // return result as Uint8List;
    return data;
  }
}
