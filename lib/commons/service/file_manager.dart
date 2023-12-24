import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import "dart:ui" as ui show Image, ImageByteFormat;

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:note/editor/edit_controller.dart';
import 'package:note/service/service_manager.dart';
import 'package:note/service/user/user_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../util/image.dart';

class DocCacheMap {
  int maxContentSize;
  var idQueue = Queue<String>();
  var docMap = HashMap<String, dynamic>();

  DocCacheMap(this.maxContentSize);

  Object? getObject(String key) {
    var ret = docMap[key];
    if (ret != null) {
      idQueue.remove(key);
      idQueue.addLast(key);
    }
    return ret;
  }

  void putObject(String key, Object object) {
    idQueue.addLast(key);
    docMap[key] = object;
    while (docMap.length > maxContentSize) {
      String key = idQueue.removeFirst();
      removeObject(key);
    }
  }

  void removeObject(String key) {
    docMap.remove(key);
  }
}

class FileManager {
  ServiceManager serviceManager;
  var docCacheMap = DocCacheMap(1000);

  FileManager(this.serviceManager);

  String createUuid() {
    var uuid = const Uuid();
    return uuid.v1();
  }

  String get _wenNoteDir {
    return "WenNote";
  }

  Future<String?> writeImage(
    Uint8List image, {
    bool isFile = false,
    String suffix = ".png",
  }) async {
    var id = createUuid();
    var imageDir = await getImageDir();
    Directory(imageDir).createSync(recursive: true);
    if (isFile) {
      var file = File("$imageDir/$id$suffix");
      await file.writeAsBytes(image);
      return id;
    }
    var file = File("$imageDir/$id$suffix");
    var size = readImageSize(MemoryInput(image));
    var imageMemory = Image.memory(
      image,
      cacheWidth: size.width,
      cacheHeight: size.height,
    );
    var uiImage = await ImageUtils.loadImageByProvider(imageMemory.image);
    var bytes = await uiImage.toByteData(format: ui.ImageByteFormat.png);
    if (bytes != null) {
      await file.writeAsBytes(bytes.buffer.asUint8List());
      return id;
    }
    return null;
  }

  Future<String?> writeImageFile(String filepath) async {
    var id = createUuid();
    var imageDir = await getImageDir();
    Directory(imageDir).createSync(recursive: true);
    File(filepath).copySync("$imageDir/$id${getFileSuffix(filepath)}");
    return id;
  }

  Future<String> getImageFile(String id) async {
    var imageDir = await getImageDir();
    const types = [
      ".png",
      ".gif",
      ".jpg",
      ".jpeg",
      ".webp",
      "",
    ];
    for (var item in types) {
      if (File("$imageDir/$id$item").existsSync()) {
        return "$imageDir/$id$item";
      }
    }
    return "$imageDir/$id";
  }

  Future<String?> downloadImageFile(String file) async {
    var id = createUuid();
    var saveFile = await getImageFile(id);
    if (File(file).existsSync()) {
      File(file).copySync(saveFile);
      return id;
    } else if (file.startsWith("http")) {
      var get = await Dio().get(file,
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
          ));
      if (get.statusCode == 200) {
        File(saveFile).writeAsBytesSync(get.data);
        return id;
      }
    }
    return null;
  }

  Future<String> getDocDir() async {
    var dir = await getApplicationDocumentsDirectory();
    return "${dir.path}/$_wenNoteDir/${serviceManager.userService.userPath}documents";
  }

  Future<String> getImageDir() async {
    var dir = await getApplicationDocumentsDirectory();
    return "${dir.path}/$_wenNoteDir/${serviceManager.userService.userPath}images";
  }

  Future<String> getConfigDir() async {
    var dir = await getApplicationDocumentsDirectory();
    return "${dir.path}/$_wenNoteDir/${serviceManager.userService.userPath}config";
  }

  Future<List<FileSystemEntity>> get docFileList async {
    var docDir = await getDocDir();
    return Directory(docDir).listSync();
  }

  Future<List<FileSystemEntity>> get imageFileList async {
    var dir = await getImageDir();
    return Directory(dir).listSync();
  }

  Future<String> getWenNoteRootDir() async {
    var dir = await getApplicationDocumentsDirectory();
    String docDir = "${dir.path}/$_wenNoteDir";
    if (!Directory(docDir).existsSync()) {
      Directory(docDir).createSync(recursive: true);
    }
    return docDir;
  }

  Future<String> readDocFileJsonContent(String uuid) async {
    String docDir = await getDocDir();
    String docFile = "$docDir/$uuid.json";
    if (!Directory(docDir).existsSync()) {
      Directory(docDir).createSync(recursive: true);
    }
    if (!File(docFile).existsSync()) {
      File(docFile).createSync();
    }
    return File(docFile).readAsStringSync();
  }

  Future<List> readDocFileContent(String uuid) async {
    try {
      var cache = docCacheMap.getObject(uuid);
      if (cache != null) {
        return cache as List;
      }
    } catch (err) {
      print(err);
    }
    String docDir = await getDocDir();
    String docFile = "$docDir/$uuid.wennote";
    if (!Directory(docDir).existsSync()) {
      Directory(docDir).createSync(recursive: true);
    }
    if (!File(docFile).existsSync()) {
      var content = await readDocFileJsonContent(uuid);
      if (content.isNotEmpty) {
        return jsonDecode(content) as List;
      }
      return [];
    }
    var buff = await File(docFile).readAsBytes();
    if (buff.isEmpty) {
      return [];
    }
    var unzipBuff = GZipDecoder().decodeBytes(buff);
    var str = utf8.decode(unzipBuff);
    if (str.isEmpty) {
      return [];
    }
    var result = jsonDecode(str) as List;
    docCacheMap.putObject(uuid, result);
    return result;
  }

  Future<void> executeSaveThread(String uuid, List content) async {
    docCacheMap.putObject(uuid, content);
    String docDir = await getDocDir();
    String docFile = "$docDir/$uuid.wennote";

    if (!Directory(docDir).existsSync()) {
      Directory(docDir).createSync(recursive: true);
    }
    if (!File(docFile).existsSync()) {
      File(docFile).createSync();
    }
    await _saveDocJsonFile(uuid, content);
  }

  Future<void> _saveDocJsonFile(String uuid, List content) async {
    String docDir = await getDocDir();
    String docFile = "$docDir/$uuid.wennote";

    if (!Directory(docDir).existsSync()) {
      Directory(docDir).createSync(recursive: true);
    }
    if (!File(docFile).existsSync()) {
      File(docFile).createSync();
    }
    var encode = jsonEncode(content);
    var saveBuff = GZipEncoder().encode(utf8.encode(encode));
    //100万文字估计会有很大的数据，可能需要压缩一下
    if (saveBuff != null) {
      File(docFile).writeAsBytesSync(saveBuff);
    }
  }

  Future<void> saveDocStringFile(String? uuid, String? content) async {
    if (uuid == null || content == null) {
      return;
    }
    String docDir = await getDocDir();
    String docFile = "$docDir/$uuid.wennote";
    if (!Directory(docDir).existsSync()) {
      Directory(docDir).createSync(recursive: true);
    }
    if (!File(docFile).existsSync()) {
      File(docFile).createSync();
    }
    var saveBuff = GZipEncoder().encode(utf8.encode(content));
    //100万文字估计会有很大的数据，可能需要压缩一下
    if (saveBuff != null) {
      File(docFile).writeAsBytesSync(saveBuff);
    }
  }

  Future<void> lockExportAndImport() async {
    var docDir = await getDocDir();
    var af = File("$docDir/exportLock").openSync(mode: FileMode.write);
    af.lockSync();
  }

  Future<void> unlockExportAndImport() async {
    var docDir = await getDocDir();
    var af = File("$docDir/exportLock").openSync(mode: FileMode.write);
    af.unlockSync();
  }

  Future<void> deleteDoc(String? uuid) async {
    String docDir = await getDocDir();
    String docFile = "$docDir/$uuid.wennote";
    File(docFile).deleteSync();
  }
}

class JsonContent {
  String uuid;
  List content;

  JsonContent({
    required this.uuid,
    required this.content,
  });
}

class ImageUtils {
  static Future<ui.Image> loadImageByProvider(
    ImageProvider provider, {
    ImageConfiguration config = ImageConfiguration.empty,
  }) async {
    Completer<ui.Image> completer = Completer<ui.Image>(); //完成的回调
    late ImageStreamListener listener;
    ImageStream stream = provider.resolve(config); //获取图片流
    listener = ImageStreamListener((ImageInfo frame, bool sync) {
      final ui.Image image = frame.image;
      completer.complete(image); //完成
      stream.removeListener(listener); //移除监听
    });
    stream.addListener(listener); //添加监听
    return completer.future; //返回
  }
}
