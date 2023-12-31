import 'package:flutter/material.dart';
import 'package:note/commons/widget/expand_node_icon.dart';
import 'package:note/commons/widget/tree_view.dart';
import 'package:note/editor/block/block.dart';
import 'package:note/editor/block/text/text.dart';
import 'package:note/editor/theme/theme.dart';

import 'outline_controller.dart';

class OutlineTree extends StatefulWidget {
  double iconSize;
  double indentWidth;
  double itemHeight;
  OutlineController controller;

  OutlineTree({
    Key? key,
    required this.controller,
    this.iconSize = 24,
    this.indentWidth = 24,
    this.itemHeight = 32,
  }) : super(key: key);

  @override
  State<OutlineTree> createState() => _OutlineTreeState();
}

class _OutlineTreeState extends State<OutlineTree> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(onChanged);
  }

  void onChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.removeListener(onChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: TreeView<TextBlock>(
        nodeBuilder: (context, node) {
          return Builder(builder: (context) {
            return buildNode(context, node);
          });
        },
        controller: widget.controller.treeController,
      ),
    );
  }

  Widget buildNode(BuildContext context, TreeNode<TextBlock> node) {
    var controller = widget.controller.treeController;
    var expanded = node.isExpand;
    bool isFolder = !node.isLeaf;
    var isSelect = widget.controller.isSelect(node);
    var isHover = widget.controller.isHover(node);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onHover: (event) {
        widget.controller.hover(node);
      },
      onExit: (event) {
        widget.controller.exit(node);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanDown: (event) {
          if (widget.controller.isSelect(node)) {
            controller.toggleExpanded(node);
          }
          widget.controller.select(node);
          //跳转
          var editController = widget.controller.editController;
          if (editController != null) {
            var block = node.data as WenBlock;
            editController.gotoPosition(block.blockIndex, 0);
          }
        },
        child: Container(
          height: widget.itemHeight,
          color: isSelect
              ? EditTheme.of(context).treeItemSelectColor
              : (isHover ? EditTheme.of(context).treeItemHoverColor : null),
          child: Row(
            children: [
              SizedBox(
                width: node.depth * widget.indentWidth,
              ),
              Expanded(
                  child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Row(
                  children: [
                    if (isFolder)
                      Container(
                        width: widget.iconSize,
                        alignment: Alignment.center,
                        child: CustomExpandIcon(
                          size: 16,
                          key: ValueKey(node.id),
                          isExpanded: expanded,
                        ),
                      ),
                    Container(
                      padding: EdgeInsets.all(2),
                      margin: EdgeInsets.only(right: 2),
                      child: Text(
                        "H${node.data!.level}",
                        style: TextStyle(
                          color: EditTheme.of(context).fontColor2,
                        ),
                      ),
                    ),
                    Text(
                      node.label ?? "",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(fontFamily: "MiSans"),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
