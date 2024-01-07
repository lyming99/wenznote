import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:note/commons/util/string.dart';
import 'package:note/editor/block/element/element.dart';
import 'package:note/editor/block/image/image_element.dart';
import 'package:note/editor/block/table/table_element.dart';
import 'package:note/editor/crdt/doc_utils.dart';
import 'package:note/model/note/po/doc_po.dart';
import 'package:note/service/edit/doc_edit_service.dart';
import 'package:note/service/file/file_manager.dart';

class WdocInfo {
  String path;
  DocPO? info;
  String? content;
  List<WenElement>? fileList;

  WdocInfo({
    required this.path,
  });

  Future<void> readInfo() async {
    var zipInputStream = InputFileStream(path!);
    try {
      var archive = ZipDecoder().decodeBuffer(zipInputStream);
      for (var file in archive.files) {
        var name = file.name.trimChar(".\\/");
        if (name == "docInfo") {
          // 读取到信息：记录信息A
          var list = file.content;
          var json = jsonDecode(utf8.decode(list));
          if (json is Map<String, dynamic>) {
            info = DocPO.fromMap(json);
          }
        } else if (name == "docContent") {
          var list = file.content as Uint8List;
          var content = utf8.decode(list);
          this.content = content;
          var elements = jsonStrToElements(content);
          fileList = getDocFileList(elements);
        } else {
          if (content != null && info != null) {
            break;
          }
        }
      }
    } finally {
      zipInputStream.close();
    }
  }

  Future<void> unzipAssetsFileToSystem(FileManager fileManager) async {
    var file = path;
    var fileList = this.fileList;
    if (fileList == null || file == null) {
      return;
    }
    var fileMap = <String, WenElement>{};
    for (var file in fileList) {
      if (file is WenImageElement) {
        fileMap[file.id] = file;
      }
    }
    var zipInputStream = InputFileStream(file);
    try {
      var archive = ZipDecoder().decodeBuffer(zipInputStream);
      for (var zipFile in archive.files) {
        var name = zipFile.name.trimChar(".\\/");
        if (name.startsWith("assets")) {
          // 读取到附件：根据信息A和内容将附件写入到系统
          if (zipFile.isFile) {
            String id = name.substring("assets/".length);
            var fileItem = fileMap[id];
            if (fileItem == null) {
              continue;
            }
            await saveZipAssetFileToSystem(fileManager, fileItem, zipFile);
          }
        }
      }
    } finally {
      zipInputStream.close();
    }
  }

  Future<void> saveZipAssetFileToSystem(
      FileManager fileManager, WenElement fileItem, ArchiveFile zipFile) async {
    String? path;
    if (fileItem is WenImageElement) {
      path = await fileManager.getImageFile(fileItem.id);
    }
    if (path == null) {
      return;
    }
    var output = OutputFileStream(path);
    try {
      zipFile.decompress(output);
    } finally {
      output.close();
    }
  }
}

/// 读取wdoc文件
/// docInfo
/// docContent
/// assets/
Future<WdocInfo> readWdocFile(FileManager fileManager, String file) async {
  var info = WdocInfo(path: file);
  await info.readInfo();
  await info.unzipAssetsFileToSystem(fileManager);
  return info;
}

/// 生成wdoc文件
/// docInfo
/// docContent
/// assets/
Future<String> exportWdocFile(
    FileManager fileManager, DocEditService wenFileService, DocPO doc) async {
  var docDir = await fileManager.getDocDir();
  var wdocFile = "$docDir/${doc.uuid}.wdoc".replaceAll("//", "/");
  ZipEncoder zipEncoder = ZipEncoder();
  var output = OutputFileStream(wdocFile);
  try {
    zipEncoder.startEncode(output);
    //写入doc info
    zipEncoder.addFile(
        ArchiveFile("docInfo", 0, utf8.encode(jsonEncode(doc.toMap()))));
    //写入doc content
    var content = await wenFileService.readDoc(doc.uuid!);
    var elements = yDocToWenElements(content);
    var json = jsonEncode(elements.map((e) => e.toJson()).toList());
    zipEncoder.addFile(ArchiveFile("docContent", 0, utf8.encode(json)));
    //写入doc assets
    var fileList = getDocFileList(elements);
    for (var file in fileList) {
      if (file is WenImageElement) {
        var imageFile = await fileManager.getImageFile(file.id);
        if (imageFile == null) {
          continue;
        }
        if (!File(imageFile).existsSync()) {
          continue;
        }
        zipEncoder.addFile(
            ArchiveFile("assets/${file.id}", 0, InputFileStream(imageFile)));
      }
    }
    zipEncoder.endEncode();
  } finally {
    await output.close();
  }
  return wdocFile;
}

Future<List<WenElement>> readDocElements(
    FileManager fileManager, String uuid) async {
  var json = await fileManager.readDocFileContent(uuid);
  return json.map((e) => WenElement.parseJson(e)).toList();
}

List<WenElement> jsonStrToElements(String json) {
  var list = jsonDecode(json) as List;
  return list.map((e) => WenElement.parseJson(e)).toList();
}

List<WenElement> jsonListToElements(List list) {
  return list.map((e) => WenElement.parseJson(e)).toList();
}

Future<String> readDocJsonContent(FileManager fileManager, String uuid) async {
  var list = await fileManager.readDocFileContent(uuid);
  return jsonEncode(list);
}

List<WenElement> getDocFileList(List<WenElement> docContent) {
  Set<String> fileSet = <String>{};
  var ans = <WenElement>[];
  for (var element in docContent) {
    if (element is WenImageElement) {
      if (fileSet.contains(element.id)) {
        continue;
      }
      fileSet.add(element.id);
      ans.add(element);
    } else if (element is WenTableElement) {
      var rows = element.rows;
      if (rows != null) {
        for (var row in rows) {
          for (var cell in row) {
            if (cell is WenImageElement) {
              if (fileSet.contains(cell.id)) {
                continue;
              }
              fileSet.add(cell.id);
              ans.add(cell);
            }
          }
        }
      }
    }
  }
  return ans;
}

Future<List<ImageFile>> getImageFileList(
    FileManager fileManager, List<WenElement> elements) async {
  List<ImageFile> result = [];
  var assetsFileList = getDocFileList(elements);
  for (var assetsFile in assetsFileList) {
    if (assetsFile is WenImageElement) {
      var path = await fileManager.getImageFile(assetsFile.id);
      if (path == null) {
        continue;
      }
      result.add(ImageFile(uuid: assetsFile.id, path: path));
    }
  }
  return result;
}

class ImageFile {
  String uuid;
  String path;

  ImageFile({
    required this.uuid,
    required this.path,
  });
}
