import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note/app/windows/controller/export/win_export_single_markdown_file_controller.dart';
import 'package:note/editor/widget/toggle_item.dart';
import 'package:note/model/note/po/doc_po.dart';

class WinExportSingleMarkdownFileDialog
    extends GetView<WinExportSingleMarkdownFileController> {
  const WinExportSingleMarkdownFileDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return fluent.ContentDialog(
      title: Text("导出Markdown"),
      content: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 5,
              ),
              Text("导出路径:"),
              SizedBox(
                width: 5,
              ),
              Expanded(
                child: fluent.TextBox(
                  placeholder: "/output/output.md",
                  controller: controller.pathController,
                  suffix: ToggleItem(
                    onTap: (ctx) {
                      controller.selectFile(context);
                    },
                    itemBuilder: (BuildContext context, bool checked,
                        bool hover, bool pressed) {
                      return Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                        child: Icon(
                          fluent.FluentIcons.more,
                          color: hover
                              ? Colors.grey.shade600
                              : Colors.grey.shade500,
                          size: 16,
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(
                width: 5,
              ),
            ],
          ),
        ],
        mainAxisSize: MainAxisSize.min,
      ),
      actions: [
        fluent.OutlinedButton(
          onPressed: () {
            Get.back();
          },
          child: Text("取消"),
        ),
        fluent.FilledButton(
          onPressed: () {
            Get.back();
            controller.export(context);
          },
          child: Text("导出"),
        ),
      ],
    );
  }
}

void showExportSingleMarkdownFileDialog(BuildContext context, DocPO doc) {
  showDialog(
      context: context,
      builder: (context) {
        return GetBuilder(
            init: WinExportSingleMarkdownFileController(doc: doc),
            builder: (c) {
              return const WinExportSingleMarkdownFileDialog();
            });
      });
}
