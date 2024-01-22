import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:wenznote/commons/mvc/view.dart';
import 'package:wenznote/commons/widget/expand_node_icon.dart';
import 'package:wenznote/commons/widget/tree_view.dart';
import 'package:wenznote/editor/theme/theme.dart';
import 'package:wenznote/editor/widget/toggle_item.dart';
import 'package:wenznote/editor/widget/window_button.dart';
import 'package:wenznote/model/note/po/doc_po.dart';
import 'package:window_manager/window_manager.dart';

import 'export_controller.dart';

class ExportWidget extends MvcView<ExportController> {
  const ExportWidget({super.key, required super.controller});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          buildTitleBar(context),
          Expanded(child: buildContent(context)),
          buildBottomBar(context),
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
                          context.pop();
                        },
                        icon: const Icon(Icons.arrow_back),
                      );
                    }),
                    Expanded(
                        child: DragToMoveArea(
                      child: Obx(
                        () => Text(
                          controller.processNodeIndex.value == 0
                              ? "导出笔记"
                              : "导出笔记",
                          style: TextStyle(
                            color: EditTheme.of(context).fontColor,
                            // fontFamily: "MiSans",
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
    return Obx(
      () => IndexedStack(
        index: controller.processNodeIndex.value,
        children: [
          buildNode1Widget(context),
          buildNode2Widget(context),
        ],
      ),
    );
  }

  /// 返回一个选择文件树
  Widget buildNode1Widget(BuildContext context) {
    return Obx(
      () => SelectTreeView(
        padding: const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 8,
        ),
        controller: controller.treeController.value,
        nodeBuilder: (ctx, node) {
          return buildDocNodeItem(context, node);
        },
      ),
    );
  }

  Widget buildDocNodeItem(BuildContext context, SelectTreeNode node) {
    bool isFolder = node.data?.object is! DocPO;
    return ToggleItem(itemBuilder:
        (BuildContext context, bool checked, bool hover, bool pressed) {
      return Container(
        height: node.height,
        color: hover ? EditTheme.of(context).treeItemHoverColor : null,
        child: Row(
          children: [
            SizedBox(
              width: node.depth * 26,
            ),
            Expanded(
                child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (node.isMostTopLevel) const SizedBox(width: 4, height: 4),
                  if (isFolder)
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        controller.toggleExpanded(node);
                      },
                      child: Container(
                        width: 20,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(right: 2),
                        child: CustomExpandIcon(
                          isExpanded: node.isExpand,
                        ),
                      ),
                    ),
                  fluent.Checkbox(
                    key: fluent.ValueKey(node.id),
                    checked: node.data?.calcChecked,
                    onChanged: (v) {
                      controller.updateChecked(node, v ?? false);
                    },
                  ),
                  if (!isFolder)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: const Icon(
                        fluent.FluentIcons.text_document_edit,
                        size: 16,
                      ),
                    ),
                  Expanded(
                      child: GestureDetector(
                    onTap: () {
                      if (node.isLeaf) {
                        var checked = node.data?.calcChecked == true;
                        controller.updateChecked(node, !checked);
                      } else {
                        controller.toggleExpanded(node);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 4,
                      ),
                      child: Text(
                        "${node.label}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )),
                ],
              ),
            )),
          ],
        ),
      );
    });
  }

  /// 返回一个form：
  Widget buildNode2Widget(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          // 导出类型
          Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text("导出类型: "),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: fluent.RadioButton(
                    checked: controller.isWdoc.value,
                    content: Text("wdoc"),
                    onChanged: (v) {
                      controller.isWdoc.value = v;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: fluent.RadioButton(
                    checked: !controller.isWdoc.value,
                    content: const Text("markdown"),
                    onChanged: (v) {
                      controller.isWdoc.value = !v;
                    },
                  ),
                )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("是否压缩: "),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: fluent.RadioButton(
                    checked: controller.isZip.value,
                    content: const Text("是"),
                    onChanged: (v) {
                      controller.isZip.value = v;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: fluent.RadioButton(
                    checked: !controller.isZip.value,
                    content: const Text("否"),
                    onChanged: (v) {
                      controller.isZip.value = !v;
                    },
                  ),
                )
              ],
            ),
          ),
          // 导出路径
          Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("导出路径: "),
                ),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      fluent.TextBox(
                        controller: controller.pathEditController,
                        placeholder: "d:/output",
                        padding: EdgeInsets.only(right: 40),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: fluent.IconButton(
                          icon: Icon(fluent.FluentIcons.more),
                          onPressed: () {
                            controller.getSystemDirectory();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 文件名称
          if (controller.isZip.value || !controller.isMultiExport)
            Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("文件名称: "),
                  ),
                  Expanded(
                    child: fluent.TextBox(
                      controller: controller.nameEditController,
                      placeholder: "output",
                    ),
                  ),
                  if (controller.isZip.value)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(".zip"),
                    ),
                  if (!controller.isZip.value && controller.isWdoc.value)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(".wdoc"),
                    ),
                  if (!controller.isZip.value && !controller.isWdoc.value)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(".md"),
                    ),
                ],
              ),
            ),

          // 图片资源路径
          if (controller.isWdoc.value == false)
            Container(
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("附件路径: "),
                  ),
                  Expanded(
                    child: fluent.TextBox(
                      controller: controller.assetsEditController,
                      placeholder: "assets/, 相对路径",
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget buildBottomBar(BuildContext context) {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (controller.processNodeIndex.value == 1)
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
              child: fluent.Button(
                child: Text("上一步"),
                onPressed: () {
                  controller.processNodeIndex.value = 0;
                },
              ),
            ),
          if (controller.processNodeIndex.value == 0)
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
              child: fluent.FilledButton(
                child: Text("下一步"),
                onPressed: controller.hasSelectDoc
                    ? () {
                        controller.processNodeIndex.value = 1;
                      }
                    : null,
              ),
            ),
          if (controller.processNodeIndex.value == 1)
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
              child: fluent.FilledButton(
                child: Text("导  出"),
                onPressed: () {
                  controller.showExportDialog(context);
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
            child: fluent.Button(
              style: fluent.ButtonStyle(),
              child: Text("取  消"),
              onPressed: () {
                context.pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
