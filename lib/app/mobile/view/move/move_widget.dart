import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wenznote/commons/mvc/view.dart';
import 'package:wenznote/commons/widget/expand_node_icon.dart';
import 'package:wenznote/commons/widget/tree_view.dart';
import 'package:wenznote/editor/theme/theme.dart';
import 'package:wenznote/editor/widget/toggle_item.dart';
import 'package:wenznote/editor/widget/window_button.dart';
import 'package:window_manager/window_manager.dart';

import 'move_controller.dart';

class MoveWidget extends MvcView<MoveController> {
  const MoveWidget({
    super.key,
    required super.controller,
    super.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          buildTitleBar(context),
          Expanded(child: buildContent(context)),
        ],
      ),
    );
  }

  Widget buildTitleBar(BuildContext context) {
    return Container(
      height: 48,
      padding: EdgeInsets.symmetric(horizontal: 10),
      // color: Colors.white,
      decoration: BoxDecoration(
          color: EditTheme.of(context).bgColor,
          border: Border(
              bottom: BorderSide(
            color: EditTheme.of(context).lineColor,
          ))),
      child: Row(
        children: [
          Builder(builder: (context) {
            return WindowUserButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(
                Icons.close,
                size: 24,
              ),
            );
          }),
          Expanded(
              child: DragToMoveArea(
            child: fluent.Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "请选择文件夹",
                style: TextStyle(
                  color: EditTheme.of(context).fontColor,
                  fontFamily: "MiSans",
                  fontSize: 16,
                ),
              ),
            ),
          )),
          Builder(builder: (context) {
            return WindowUserButton(
              onPressed: () {
                Get.back(result: {"pid": controller.selectNode.value?.id});
              },
              icon: const Icon(
                Icons.check,
                size: 24,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    return Obx(
      () => SelectTreeView(
        controller: controller.treeController.value,
        nodeBuilder: (ctx, node) {
          print('build...');
          return buildDocNodeItem(context, node);
        },
      ),
    );
  }

  Widget buildDocNodeItem(BuildContext context, SelectTreeNode node) {
    return ToggleItem(
      onTap: (ctx) {
        controller.selectNode.value = node;
      },
      itemBuilder:
          (BuildContext context, bool checked, bool hover, bool pressed) {
        return Obx(
          () {
            bool isFolder = !node.isLeaf;
            var selectNode = controller.selectNode.value;
            return Container(
              height: 48,
              padding: EdgeInsets.symmetric(
                horizontal: 10,
              ),
              color: node == selectNode || hover || pressed
                  ? EditTheme.of(context).fontColor.withOpacity(0.1)
                  : null,
              child: Row(
                children: [
                  SizedBox(
                    width: node.depth * 24,
                  ),
                  Expanded(
                      child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (isFolder)
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              controller.toggleExpanded(node);
                            },
                            child: Container(
                              width: 24,
                              alignment: Alignment.center,
                              child: CustomExpandIcon(
                                isExpanded: node.isExpand,
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.folder,
                            size: 24,
                          ),
                        ),
                        Expanded(
                            child: GestureDetector(
                          onTap: () {
                            if (controller.isSelect(node)) {
                              controller.toggleExpanded(node);
                            } else {
                              controller.selectNode.value = node;
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 4,
                            ),
                            child: Text(
                              "${node.label ?? "根路径"}",
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
          },
        );
      },
    );
  }

  Widget buildBottomBar(BuildContext context) {
    return fluent.FilledButton(
      style: fluent.ButtonStyle(),
      child: Text("确定"),
      onPressed: () {
        Get.back();
      },
    );
  }
}
