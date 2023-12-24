import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note/editor/theme/theme.dart';
import 'package:note/editor/widget/window_button.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:window_manager/window_manager.dart';

import 'import_controller.dart';


class ImportWidget extends GetView<ImportController> {
  const ImportWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          buildTitleBar(context),
          Expanded(child: buildContent(context)),
          buildBottom(context),
        ],
      ),
    );
  }

  Widget buildTitleBar(BuildContext context) {
    return Container(
      height: 32,
      // color: Colors.white,
      decoration: BoxDecoration(
          color: EditTheme.of(context).bgColor,
          border: Border(
              bottom: BorderSide(
            color: EditTheme.of(context).lineColor,
          ))),
      child: Stack(
        children: [
          DragToMoveArea(
            child: Container(),
          ),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Builder(builder: (context) {
                      return WindowUserButton(
                        onPressed: () {
                          Get.back();
                        },
                        icon: const Icon(Icons.arrow_back),
                      );
                    }),
                    Expanded(
                        child: DragToMoveArea(
                      child: Obx(
                        () => Text(
                          controller.processNodeIndex.value == 0
                              ? "导入笔记"
                              : "导入笔记",
                          style: TextStyle(
                            color: EditTheme.of(context).fontColor,
                            fontFamily: "MiSans",
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )),
                  ],
                ),
              ),
              // const WindowButtons(),
            ],
          )
        ],
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    return Obx(() {
      return IndexedStack(
        index: controller.processNodeIndex.value,
        sizing: StackFit.expand,
        children: [
          buildProcessNode1(context),
          buildProcessNode2(context),
        ],
      );
    });
  }

  Widget buildBottom(BuildContext context) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 5,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            fluent.Padding(
              padding: const EdgeInsets.all(5.0),
              child: fluent.FilledButton(
                onPressed: controller.importPaths.isEmpty
                    ? null
                    : () {
                        controller.showImportDialog(context);
                      },
                child: const Text("导入"),
              ),
            ),
            fluent.Padding(
              padding: const EdgeInsets.all(5.0),
              child: fluent.Button(
                child: const Text("取消"),
                onPressed: () {
                  Get.back();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProcessNode1(BuildContext context) {
    return Obx(() {
      var isEmpty = controller.importPaths.isEmpty;
      return DropRegion(
        hitTestBehavior: HitTestBehavior.opaque,
        formats: const [Formats.fileUri],
        onDropOver: (DropOverEvent event) async {
          return DropOperation.copy;
        },
        onPerformDrop: (PerformDropEvent event) async {
          for (var item in event.session.items) {
            item.dataReader?.getValue(Formats.fileUri, (value) {
              if (value is Uri) {
                var path = value.toFilePath();
                var stat = File(path).statSync();
                if (stat.type == FileSystemEntityType.file) {
                  if (!controller.canImportFile(path)) {
                    return;
                  }
                }
                if (!controller.importPaths.contains(path)) {
                  controller.importPaths.add(path);
                }
              }
            });
          }
        },
        onDropEnter: (event) {
          controller.isDropEnter.value = true;
        },
        onDropLeave: (event) {
          controller.isDropEnter.value = false;
        },
        child: Container(
          color: controller.isDropEnter.isTrue
              ? EditTheme.of(context).dropColor
              : null,
          child: isEmpty
              ? Container(
                  margin: EdgeInsets.all(10),
                  child: Center(
                    child: DottedBorder(
                      dashPattern: [10, 5],
                      radius: Radius.circular(10),
                      strokeCap: StrokeCap.butt,
                      borderType: BorderType.RRect,
                      color: EditTheme.of(context).borderColor,
                      child: Container(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              fluent.Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Icon(
                                  fluent.FluentIcons.bulk_upload,
                                  size: 64,
                                  color: EditTheme.of(context).fontColor2,
                                ),
                              ),
                              Text(
                                "请将笔记文件或者文件夹拖入此处~",
                                style: TextStyle(
                                  color: EditTheme.of(context).fontColor2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : buildPathListView(context),
        ),
      );
    });
  }

  Widget buildProcessNode2(BuildContext context) {
    return Container();
  }

  Widget buildPathListView(BuildContext context) {
    return ListView.builder(
      itemCount: controller.importPaths.length,
      itemBuilder: (context, index) {
        var item = controller.importPaths[index];
        return FileTextWidget(
          isFirst: index == 0,
          path: item,
          onDelete: () {
            controller.importPaths.removeAt(index);
          },
        );
      },
    );
  }
}

class FileTextWidget extends StatefulWidget {
  final String path;
  final bool isFirst;

  final Function? onDelete;

  const FileTextWidget({
    Key? key,
    required this.path,
    required this.isFirst,
    this.onDelete,
  }) : super(key: key);

  @override
  State<FileTextWidget> createState() => _FileTextWidgetState();
}

class _FileTextWidgetState extends State<FileTextWidget> {
  bool isDir = false;

  @override
  void initState() {
    super.initState();
    getFileType();
  }

  void getFileType() async {
    var type = File(widget.path).statSync().type;
    if (type == FileSystemEntityType.directory) {
      setState(() {
        isDir = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: EditTheme.of(context).borderColor,
          ),
          top: (widget.isFirst)
              ? BorderSide(
                  color: EditTheme.of(context).borderColor,
                )
              : BorderSide.none,
        ),
      ),
      child: Row(
        children: [
          if (!isDir) Icon(fluent.FluentIcons.text_document_edit),
          if (isDir) Icon(fluent.FluentIcons.folder),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Text(
                widget.path,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          fluent.IconButton(
            icon: const Icon(fluent.FluentIcons.delete),
            onPressed: () {
              widget.onDelete?.call();
            },
          )
        ],
      ),
    );
  }
}
