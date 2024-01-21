import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:wenznote/commons/widget/tree_view.dart';
import 'package:wenznote/model/note/po/doc_po.dart';
import 'package:wenznote/service/service_manager.dart';


class MoveController extends ServiceManagerController {
  var treeController = SelectTreeController(rootNode: SelectTreeNode()).obs;

  List<String>? currentIds;

  MoveController({
    this.currentIds,
  });

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    fetchNote();
  }

  Future<SelectTreeNode> fetchRootNode() async {
    var directories = await serviceManager.docService.queryDirList(null);
    var nodes = <SelectTreeNode>[];
    nodes.addAll(directories
        .where((element) => currentIds?.contains(element.uuid) == false)
        .map((e) => SelectTreeNode(
            id: e.uuid,
            pid: e.pid,
            label: e.title ?? "未命名",
            data: SelectData(object: e))));
    var root = TreeNode.buildTree(nodes);
    var ans = TreeNode(children: [root], label: "根路径");
    ans.initTree();
    selectNode.value = root;
    return ans;
  }

  void fetchNote() async {
    var root = await fetchRootNode();
    treeController.value = SelectTreeController(rootNode: root);
  }

  void toggleExpanded(TreeNode node) {
    treeController.update((val) {
      node.setExpand(!node.isExpand);
    });
    treeController.refresh();
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
    treeController.refresh();
  }

  var selectNode = Rxn<TreeNode?>();

  bool isSelect(TreeNode<SelectData> node) {
    return selectNode.value == node;
  }
}
