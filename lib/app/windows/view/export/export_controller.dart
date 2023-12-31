import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:file_selector/file_selector.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:get/get.dart';
import 'package:note/commons/util/platform_util.dart';
import 'package:note/commons/util/string.dart';
import 'package:note/commons/util/wdoc/wdoc.dart';
import 'package:note/commons/widget/tree_view.dart';
import 'package:note/editor/block/element/element.dart';
import 'package:note/editor/block/image/image_element.dart';
import 'package:note/editor/crdt/doc_utils.dart';
import 'package:note/model/note/po/doc_dir_po.dart';
import 'package:note/model/note/po/doc_po.dart';
import 'package:note/service/service_manager.dart';
import 'package:oktoast/oktoast.dart';

/// 导出笔记
/// 流程1：选择导出文件
/// 流程2：选择导出类型(wdoc、markdown)、导出路径、导出文件名称
/// 流程3：导出完成
class ExportController extends GetxController {
  late ServiceManager serviceManager;
  var processNodeIndex = 0.obs;
  var treeController = SelectTreeController(rootNode: SelectTreeNode()).obs;

  var isWdoc = false.obs;

  var pathEditController = TextEditingController(text: "/output");
  var nameEditController = TextEditingController(text: "output");
  var assetsEditController = TextEditingController(text: "assets");

  var isZip = false.obs;

  bool get isMultiExport {
    var count = 0;
    treeController.value.rootNode.visitChildren((node) {
      if ((node.data?.object is DocPO) && node.data?.selected == true) {
        count++;
        if (count > 1) {
          return false;
        }
      }
      return true;
    });
    return count > 1;
  }

  @override
  void onInit() {
    super.onInit();
    serviceManager = ServiceManager.of(Get.context!);
    fetchNote();
  }

  Future<SelectTreeNode> fetchRootNode() async {
    var directories = await queryDocDirectoryList();
    var docs = await queryDocList();
    var nodes = <SelectTreeNode>[];
    nodes.addAll(directories.map((e) => SelectTreeNode(
        id: e.uuid,
        pid: e.pid,
        label: e.name ?? "未命名",
        data: SelectData(object: e))));
    nodes.addAll(docs.map((e) => SelectTreeNode(
        id: e.uuid,
        pid: e.pid,
        label: e.name ?? "未命名",
        data: SelectData(object: e))));
    var rootNode = TreeNode.buildTree(nodes);
    return rootNode;
  }

  void fetchNote() async {
    var root = await fetchRootNode();
    treeController.value = SelectTreeController(rootNode: root);
  }

  void toggleExpanded(TreeNode node) {
    treeController.update((val) {
      node.setExpand(!node.isExpand);
    });
  }

  bool get hasSelectDoc {
    bool ans = false;
    treeController.value.rootNode.visitChildren((node) {
      if (node.data?.selected == true && (node.data?.object is DocPO)) {
        ans = true;
        return false;
      }
      return true;
    });
    return ans;
  }

  void updateChecked(SelectTreeNode node, bool checked) {
    treeController.update((val) {
      treeController.value.updateChecked(node, checked);
    });
  }

  void showExportDialog(BuildContext context) async {
    var outputDir = getGeneratorFilePath("");
    try {
      Directory(outputDir).createSync(recursive: true);
    } catch (e) {
      var stat = File(outputDir).statSync();
      var mode = stat.modeString();
      if (!Directory(outputDir).existsSync() || !mode.contains("w")) {
        var isOk = await showSelectFileDialog();
        if (!isOk) {
          Get.showSnackbar(GetSnackBar(
            message: "导出异常：文件夹不存在~",
            icon: Icon(
              Icons.close,
              color: Colors.red,
              size: 32,
            ),
            dismissDirection: DismissDirection.vertical,
            duration: Duration(
              milliseconds: 3000,
            ),
          ));
          return;
        }
      }
    }

    await showDialog(
        useSafeArea: true,
        context: context,
        builder: (context) => FutureProgressDialog(
              message: const Text("正在导出..."),
              () async {
                await doExport();
              }(),
            ));
  }

  /// 1.解析出附件列表(图片、视频、附件)
  /// 2.解析出 json|markdown
  /// 3.得到文档id
  /// 4.得到文档最后编辑时间
  /// 5.重复路径文档去除
  /// 6.文件路径
  /// 7.文件路径错误矫正(特殊字符转下划线)
  Future<void> doExport() async {
    List<SelectTreeNode> selectNode = [];
    treeController.value.rootNode.visitChildren((node) {
      var data = node.data;
      if (data != null &&
          (node.data?.object is DocPO) &&
          data.calcChecked == true) {
        selectNode.add(node);
      }
      return true;
    });
    var isSingleFile = selectNode.length <= 1;
    if (isZip.value) {
      // zip文件输出
      var output = OutputFileStream(getSaveFilePath(".zip"));
      try {
        var zip = ZipEncoder();
        zip.startEncode(output);
        // zip.addFile(ArchiveFile(name, size, content));
        for (var node in selectNode) {
          await generatorNodeContent(zip, node, isSingleFile);
        }
        zip.endEncode();
      } finally {
        output.close();
      }
    } else {
      // 文件夹输出
      String assetsPath = getGeneratorFilePath(getAssetsFilePath(""));
      try {
        Directory(assetsPath).createSync(recursive: true);
        for (var node in selectNode) {
          await generatorNodeContent(null, node, isSingleFile);
        }
      } catch (e) {
        if (e is FileSystemException) {
          Future.microtask(() {
            Get.showSnackbar(GetSnackBar(
              icon: Icon(
                Icons.close,
                color: Colors.red,
                size: 32,
              ),
              message: e.osError?.message,
              dismissDirection: DismissDirection.vertical,
              duration: Duration(
                milliseconds: 3000,
              ),
            ));
          });
        }
        return;
      }
    }
    Get.back();
    showToast(
      "导出完成！",
      position: ToastPosition.bottom,
    );
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

  Future<void> generatorNodeContent(
      ZipEncoder? zipEncoder, SelectTreeNode node, bool isSingleFile) async {
    var doc = node.data?.object as DocPO;
    var uuid = doc.uuid;
    if (uuid != null) {
      String nodeFilePath = isSingleFile ? "" : "${getNodeFilePath(node)}/";
      String name = isSingleFile ? (nameEditController.text) : (doc.name ?? "");
      if (name.isEmpty) {
        name = "output";
      }
      if (isWdoc.value) {
        String wdocFile = await exportWdocFile(
            serviceManager.fileManager, serviceManager.wenFileService, doc);
        var savePath = "$nodeFilePath$name.wdoc".replaceAll("//", "/");
        if (zipEncoder != null) {
          zipEncoder
              .addFile(ArchiveFile(savePath, 0, InputFileStream(wdocFile)));
        } else {
          //写到文件夹
          createParentDirectory(getGeneratorFilePath(savePath));
          await File(wdocFile).copy(getGeneratorFilePath(savePath));
        }
      } else {
        var doc = await serviceManager.wenFileService.readDoc(uuid);
        if (doc == null) {
          return;
        }
        var docElements = yDocToWenElements(doc);
        String markdownContent = await docToMarkdown(
            docElements, getNodeAssetsPath(node, isSingleFile));
        var savePath = "$nodeFilePath$name.md".replaceAll("//", "/");
        if (zipEncoder != null) {
          zipEncoder.addFile(ArchiveFile(savePath, 0, markdownContent));
        } else {
          //写到文件夹
          createParentDirectory(getGeneratorFilePath(savePath));
          await File(getGeneratorFilePath(savePath))
              .writeAsString(markdownContent);
        }
        // 将附件压缩到附件路径
        var assetsFileList = getDocFileList(docElements);
        for (var assetsFile in assetsFileList) {
          if (assetsFile is WenImageElement) {
            var name = getAssetsFilePath(assetsFile.id);
            var imageFile =
                await serviceManager.fileManager.getImageFile(assetsFile.id);
            if (!File(imageFile).existsSync()) {
              continue;
            }
            if (zipEncoder != null) {
              zipEncoder.addFile(
                  ArchiveFile(name, 0, File(imageFile).readAsBytesSync()));
            } else {
              //写到文件夹
              createParentDirectory(getGeneratorFilePath(name));
              await File(imageFile).copy(getGeneratorFilePath(name));
            }
          }
        }
      }
    }
  }

  String getSaveFilePath(String suffix) {
    String ans = "${pathEditController.text}/${nameEditController.text}$suffix";
    return ans.replaceAll("\\", "/").replaceAll("//", "/");
  }

  String getGeneratorFilePath(String filename) {
    String ans = "${pathEditController.text}/$filename";
    return ans.replaceAll("\\", "/").replaceAll("//", "/");
  }

  String getAssetsFilePath(String name) {
    String assetsName = getAssetsName();
    return "$assetsName/$name".replaceAll("\\", "/").replaceAll("//", "/");
  }

  String getAssetsName() {
    var assetsName = assetsEditController.text;
    if (assetsName.isEmpty) {
      assetsName = "assets";
    }
    return assetsName;
  }

  String getNodeFilePath(SelectTreeNode node) {
    String ans = "";
    var parent = node.parent;
    while (parent != null) {
      var data = parent.data?.object;
      if (data is DocDirPO) {
        ans = "${data.name}/$ans";
      } else {
        break;
      }
      parent = parent.parent;
    }
    return ans;
  }

  String getNodeAssetsPath(SelectTreeNode node, bool isSingleFile) {
    String ans = getAssetsName();
    if (isSingleFile ||
        ans.startsWith("/") ||
        ans.startsWith(RegExp("[A-Za-z]:"))) {
      return ans;
    }
    var parent = node.parent;
    while (parent != null) {
      var data = parent.data?.object;
      if (data is DocDirPO) {
        ans = "../$ans";
      } else {
        break;
      }
      parent = parent.parent;
    }
    return ans;
  }

  Future<String> docToMarkdown(
      List<WenElement> blockElements, String assetsPath) async {
    assetsPath = assetsPath.trimRightChar("/");
    StringBuffer ans = StringBuffer();
    for (var element in blockElements) {
      String mdContent = element.getMarkDown(filePathBuilder: (uuid) {
        return "$assetsPath/$uuid";
      });
      ans.writeln();
      ans.writeln(mdContent);
    }
    if (ans.isNotEmpty) {
      return ans.toString().substring(1);
    }
    return "";
  }

  Future<bool> showSelectFileDialog() async {
    await showDialog(
        useSafeArea: true,
        context: Get.context!,
        builder: (context) {
          return fluent.ContentDialog(
            constraints: isMobile
                ? const BoxConstraints(maxWidth: 300)
                : fluent.kDefaultContentDialogConstraints,
            title: Text("提示"),
            content: Text("文件夹不存在，或者权限不够，请选择一个文件夹进行导出~"),
            actions: [
              fluent.FilledButton(
                child: Text("继续"),
                onPressed: () {
                  Get.back();
                },
              ),
            ],
          );
        });
    return await getSystemDirectory();
  }

  Future<bool> getSystemDirectory() async {
    var directory = await getDirectoryPath(
        initialDirectory: getGeneratorFilePath(""), confirmButtonText: "选择");
    if (directory != null) {
      pathEditController.text = directory;
      return true;
    }
    return false;
  }

  Future<List<DocDirPO>> queryDocDirectoryList() async {
    return serviceManager.docService.queryAllDocDirList();
  }

  Future<List<DocPO>> queryDocList() async {
    return serviceManager.docService.queryAllDocList();
  }
}
