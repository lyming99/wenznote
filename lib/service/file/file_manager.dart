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
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:wenznote/commons/util/file_utils.dart';
import 'package:wenznote/commons/util/log_util.dart';
import 'package:wenznote/model/file/file_po.dart';
import 'package:wenznote/service/service_manager.dart';

import '../../commons/util/image.dart';

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

  Future<FilePO?> writeImage(
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
      return writeImageFile(file.path);
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
      return writeImageFile(file.path);
    }
    return null;
  }

  Future<FilePO?> writeImageFile(String filepath) async {
    var id = createUuid();
    var filename = getFileName(filepath);
    var savePath = await getFilePath(
      id,
      filename,
      download: false,
    );
    File(filepath).copySync(savePath);
    return serviceManager.fileSyncService.createAndUploadFile(
      uuid: id,
      name: filename,
      path: filepath,
      type: "image",
      size: File(filepath).lengthSync(),
    );
  }

  Future<String?> getImageFile(String? id, [bool fetch = true]) async {
    String imageFile = await getOldImageFile(id);
    if (File(imageFile).existsSync()) {
      var fileItem = await writeImageFile(imageFile);
      if (fileItem == null) {
        return null;
      }
      return getFilePath(fileItem.uuid, fileItem.name);
    }
    if (!fetch) {
      return null;
    }
    var file = await serviceManager.fileSyncService.getFile(id);
    if (file == null) {
      return null;
    }
    return getFilePath(id, file.name);
  }

  Future<String> getOldImageFile(String? id) async {
    var imageDir = await getImageDir();
    const types = [
      ".png",
      ".gif",
      ".jpg",
      ".jpeg",
      ".webp",
      "",
    ];
    var imageFile = "$imageDir/$id";
    for (var item in types) {
      if (File("$imageDir/$id$item").existsSync()) {
        imageFile = "$imageDir/$id$item";
        break;
      }
    }
    return imageFile;
  }

  Future<FilePO?> downloadImageFile(String file) async {
    if (File(file).existsSync()) {
      return writeImageFile(file);
    } else if (file.startsWith("http")) {
      var downloadDir = await getDownloadDir();
      if (!Directory(downloadDir).existsSync()) {
        Directory(downloadDir).createSync(recursive: true);
      }
      var saveFile = "$downloadDir/${getFileName(file)}";
      var get = await Dio().get(file,
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
          ));
      if (get.statusCode == 200) {
        File(saveFile).writeAsBytesSync(get.data);
        return writeImageFile(saveFile);
      }
    }
    return null;
  }

  Future<String> _getRootDir() async {
    if (Platform.isWindows) {
      return getExePath();
    }
    return (await getApplicationDocumentsDirectory()).path;
  }

  /// 获取软件数据存储路径，这个路径可以配置
  Future<String> getSaveDir() async {
    var defaultRootDir = await _getRootDir();
    var configFile = "$defaultRootDir/config.json";
    if (File(configFile).existsSync()) {
      var configContent = await File(configFile).readAsString();
      if (configContent.isNotEmpty) {
        var rootDir = jsonDecode(configContent)['rootDir'] as String?;
        if (rootDir != null && rootDir.isNotEmpty) {
          return rootDir;
        }
      }
    }
    if (Platform.isWindows) {
      return "$defaultRootDir/local";
    }
    return defaultRootDir;
  }

  /// 设置软件数据存储路径
  Future<void> setSaveDir(String path) async {
    // 将rootDir中的文件全部转移过去
    if (!Directory(path).existsSync()) {
      return;
    }
    // 写入配置
    var currentRootDir = await getSaveDir();
    await copyDirectory(Directory(currentRootDir), Directory(path));
    var defaultRootDir = await _getRootDir();
    if (!Directory(defaultRootDir).existsSync()) {
      Directory(defaultRootDir).createSync(recursive: true);
    }
    var configFile = "$defaultRootDir/config.json";
    Map configMap = {};
    if (File(configFile).existsSync()) {
      var configContent = await File(configFile).readAsString();
      if (configContent.isNotEmpty) {
        configMap = jsonDecode(configContent) as Map;
      }
    }
    configMap['rootDir'] = path;
    var saveConfig = jsonEncode(configMap);
    File(configFile).writeAsStringSync(saveConfig);
  }

  String getExePath() {
    var exe = Platform.executable.replaceAll("\\", "/").replaceAll("\\\\", "/");
    int i = exe.lastIndexOf("/");
    if (i == -1) {
      return ".";
    }
    return exe.substring(0, i);
  }

  Future<String> getDocDir() async {
    var dir = await getSaveDir();
    return "$dir/${serviceManager.userService.userPath}notes";
  }

  Future<String> getImageDir() async {
    var dir = await getSaveDir();
    return "$dir/${serviceManager.userService.userPath}images";
  }

  Future<String> getAssetsDir() async {
    var dir = await getSaveDir();
    return "$dir/${serviceManager.userService.userPath}assets";
  }

  Future<String> getDownloadDir() async {
    var dir = await getSaveDir();
    return "$dir/${serviceManager.userService.userPath}download";
  }

  Future<String> getConfigDir() async {
    var dir = await getSaveDir();
    return "$dir/${serviceManager.userService.userPath}config";
  }

  Future<List<FileSystemEntity>> get docFileList async {
    var docDir = await getDocDir();
    return Directory(docDir).listSync();
  }

  Future<List<FileSystemEntity>> get imageFileList async {
    var dir = await getImageDir();
    return Directory(dir).listSync();
  }

  Future<String> getAndCreateSaveDir() async {
    var docDir = await getSaveDir();
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

  Future<String> getFilePath(
    String? dataId,
    String? name, {
    bool download = true,
  }) async {
    var assetsDir = await getAssetsDir();
    var fileDir = "$assetsDir/$dataId";
    if (!Directory(fileDir).existsSync()) {
      Directory(fileDir).createSync(recursive: true);
    }
    var file = "$fileDir/$name";
    if (download && !File(file).existsSync()) {
      await serviceManager.fileSyncService.downloadFile(dataId, file);
    }
    return file;
  }

  Future<String> getNoteDir() async {
    return getDocDir();
  }

  Future<String> getNoteFilePath(String docId) async {
    var noteDir = await getNoteDir();
    if (!await Directory(noteDir).exists()) {
      await Directory(noteDir).create(recursive: true);
    }
    return "$noteDir/$docId.wnote";
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
