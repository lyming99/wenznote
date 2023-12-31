import 'dart:collection';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:note/commons/widget/tree_view.dart';
import 'package:note/editor/block/block_manager.dart';
import 'package:note/editor/block/text/text.dart';
import 'package:note/editor/edit_controller.dart';

class OutlineController with ChangeNotifier {
  late TreeController<TextBlock> treeController;
  EditController? editController;
  String? hoverNode;
  String? selectNode;

  OutlineController() {
    treeController = TreeController(
      rootNode: TreeNode(id: "root"),
    );
  }

  void updateTree(BuildContext context, EditController? editController) {
    this.editController = editController;
    BlockManager? blockManager = editController?.blockManager;
    if (blockManager == null) {
      return;
    }
    var expandSet = treeController.rootNode.expandSet;
    var blocks = blockManager.blocks;
    var titleBlocks = blocks
        .whereType<TextBlock>()
        .where((element) => element.level > 0)
        .toList();
    Queue<TreeNode<TextBlock>> titleQueue = Queue();
    var root = TreeNode<TextBlock>();
    for (var title in titleBlocks) {
      var element = title.textElement;
      var treeNode = TreeNode(
        id: title.hashCode.toString(),
        label: element.getText(),
        data: title,
      );
      treeNode.isExpand = expandSet.contains(treeNode.id);
      bool hasParent = false;
      while (titleQueue.isNotEmpty) {
        var last = titleQueue.last;
        var lastElement = last.data as TextBlock;
        if (lastElement.element.level < element.level) {
          last.addChild(treeNode);
          hasParent = true;
          break;
        } else {
          titleQueue.removeLast();
        }
      }
      titleQueue.addLast(treeNode);
      if (!hasParent) {
        root.addChild(treeNode);
      }
    }
    root.initTree();
    treeController.reset(root);
  }

  bool isSelect(TreeNode node) {
    return node.id == selectNode;
  }

  bool isHover(TreeNode node) {
    return node.id == hoverNode;
  }

  void hover(TreeNode node) {
    hoverNode = node.id;
    notifyListeners();
  }

  void exit(TreeNode node) {
    if (hoverNode == node.id) {
      hoverNode = null;
    }
    notifyListeners();
  }

  void select(TreeNode node) {
    selectNode = node.id;
    notifyListeners();
  }
}
