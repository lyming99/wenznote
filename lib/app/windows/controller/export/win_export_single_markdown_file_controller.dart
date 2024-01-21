import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:get/get.dart';
import 'package:wenznote/commons/util/string.dart';
import 'package:wenznote/commons/util/wdoc/wdoc.dart';
import 'package:wenznote/editor/block/element/element.dart';
import 'package:wenznote/editor/block/image/image_element.dart';
import 'package:wenznote/editor/crdt/doc_utils.dart';
import 'package:wenznote/model/note/po/doc_po.dart';
import 'package:wenznote/service/service_manager.dart';

class WinExportSingleMarkdownFileController extends GetxController {
  DocPO doc;
  var pathController = TextEditingController();
  late ServiceManager serviceManager;

  WinExportSingleMarkdownFileController({
    required this.doc,
  });

  void export(BuildContext context) {
    var sm = ServiceManager.of(context);
    showDialog(
        useSafeArea: true,
        context: context,
        builder: (context) => FutureProgressDialog(
              message: const Text("正在导出..."),
              () async {
                await doExport(sm);
              }(),
            ));
  }

  String getParentPath(String path) {
    path = path.replaceAll("\\", "/").replaceAll("//", "/");
    var parent = "";
    if (path.contains("/")) {
      var index = path.lastIndexOf("/");
      parent = path.substring(0, index + 1);
    }
    return parent;
  }

  void createParentDirectory(String path) {
    path = path.replaceAll("\\", "/").replaceAll("//", "/");
    var parent = "";
    if (path.contains("/")) {
      var index = path.lastIndexOf("/");
      parent = path.substring(0, index + 1);
    }
    var dir = Directory(parent);
    if (dir.existsSync()) {
      return;
    }
    dir.createSync(recursive: true);
  }

  Future<void> doExport(ServiceManager serviceManager) async {
    var textPath = pathController.text.trim();
    if (!textPath.endsWith(".md")) {
      return;
    }
    var docContent = await serviceManager.editService.readDoc(doc.uuid);
    if (docContent == null) {
      return;
    }
    textPath = textPath.replaceAll("\\", "/").replaceAll("//", "/");
    createParentDirectory(textPath);
    var elements = yDocToWenElements(docContent);
    var markContent =
        await docToMarkdown(elements, "${getParentPath(textPath)}/assets");
    var file = File(textPath);
    file.writeAsStringSync(markContent);
    // 将附件压缩到附件路径
    var assetsFileList = getDocFileList(elements);
    for (var assetsFile in assetsFileList) {
      if (assetsFile is WenImageElement) {
        var name = getAssetsFilePath(assetsFile.id);
        var imageFile =
            await serviceManager.fileManager.getImageFile(assetsFile.id);
        if (imageFile == null) {
          continue;
        }
        if (!File(imageFile).existsSync()) {
          continue;
        }
        //写到文件夹
        createParentDirectory(name);
        await File(imageFile).copy(name);
      }
    }
  }

  String getAssetsFilePath(String name) {
    String assetsName = getAssetsName();
    return "$assetsName/$name".replaceAll("\\", "/").replaceAll("//", "/");
  }

  Future<String> docToMarkdown(
      List<WenElement> blockElements, String assetsPath) async {
    assetsPath = assetsPath.trimRightChar("/");
    StringBuffer ans = StringBuffer();
    for (var element in blockElements) {
      String mdContent = element.getMarkDown(filePathBuilder: (uuid) {
        return "$assetsPath/$uuid".replaceAll("\\", "/").replaceAll("//", "/");
      });
      ans.writeln();
      ans.writeln(mdContent);
    }
    if (ans.isNotEmpty) {
      return ans.toString().substring(1);
    }
    return "";
  }

  void selectFile(BuildContext context) async {
    var text = await getSavePath(
      acceptedTypeGroups: [
        XTypeGroup(
          extensions: [
            ".md",
          ],
        ),
      ],
      suggestedName: doc.name,
    );
    if (text != null) {
      if (!text.endsWith(".md")) {
        text = "$text.md";
      }
      pathController.text = text;
    }
  }

  String getAssetsName() {
    var textPath = pathController.text.trim();
    textPath = textPath.replaceAll("\\", "/").replaceAll("//", "/");
    return "${getParentPath(textPath).trimRightChar("/")}/assets";
  }
}
