import 'dart:collection';

import 'package:flutter/widgets.dart';

typedef TreeNodeVisitor<T> = bool Function(TreeNode<T> node);
typedef NodeBuilder<T> = Widget Function(
    BuildContext context, TreeNode<T> node);

class TreeNode<T> {
  String? id;
  String? pid;
  String? label;
  T? data;
  bool isExpand = false;
  List<TreeNode<T>>? children;
  double height = 30;
  int depth = 0;
  TreeNode<T>? root;
  TreeNode<T>? parent;

  TreeNode({
    this.id,
    this.pid,
    this.label,
    this.data,
    this.height = 30,
    this.isExpand = false,
    this.children,
  });

  bool get isMostTopLevel => depth == 0;

  void initTree({
    int depth = -1,
    TreeNode<T>? parent,
    TreeNode<T>? root,
  }) {
    this.depth = depth;
    this.parent = parent;
    if (root == null) {
      this.root = this;
    } else {
      this.root = root;
    }
    if (depth < 3) {
      isExpand = true;
    }
    if (children != null) {
      for (var child in children!) {
        child.initTree(
          depth: depth + 1,
          root: this.root,
          parent: this,
        );
      }
    }
  }

  void addChild(TreeNode<T> child) {
    children ??= [];
    children!.add(child);
  }

  void addChildren(Iterable<TreeNode<T>> children) {
    this.children ??= [];
    this.children!.addAll(children);
  }

  void getVisibleNodes(List<TreeNode<T>> ans) {
    if (children != null) {
      for (var child in children!) {
        ans.add(child);
        if (child.isExpand) {
          child.getVisibleNodes(ans);
        }
      }
    }
  }

  void visitChildren(TreeNodeVisitor<T> visitor) {
    if (children != null) {
      for (var child in children!) {
        if (!visitor.call(child)) {
          break;
        }
        child.visitChildren(visitor);
      }
    }
  }

  Set<String> get expandSet {
    var ans = <String>{};
    visitChildren((node) {
      var id = node.id;
      if (id != null && node.isExpand) {
        ans.add(id);
      }
      return true;
    });
    return ans;
  }

  TreeNode<T>? findChild(String id) {
    TreeNode<T>? result;
    visitChildren((node) {
      if (node.id == id) {
        result = node;
        return false;
      }
      return true;
    });
    return result;
  }

  void setExpand(bool expand) {
    this.isExpand = expand;
    if (expand) {
      // 如果展开，则需要将祖先节点都展开
      var parent = this.parent;
      while (parent != null) {
        parent.isExpand = true;
        parent = parent.parent;
      }
    } else {
      // 如果关闭，则需要将子节点都关闭
      visitChildren((node) {
        node.isExpand = expand;
        return true;
      });
    }
  }

  static TreeNode<T> buildTree<T>(List<TreeNode<T>> nodes) {
    var nodeMap = HashMap<String, TreeNode<T>>();
    for (var node in nodes) {
      var id = node.id;
      if (id != null) {
        nodeMap[id] = node;
      }
    }
    TreeNode<T> root = TreeNode();
    for (var node in nodes) {
      var id = node.id;
      if (id == null) {
        continue;
      }
      var pid = node.pid;
      if (pid == null) {
        root.addChild(node);
      } else {
        nodeMap[pid]?.addChild(node);
      }
    }
    root.initTree();
    return root;
  }

  // 是否包含后代
  bool hasDescendant(TreeNode<dynamic> data) {
    TreeNode? parent = data;
    while (parent != null) {
      if (parent.id == this.id) {
        return true;
      }
      parent = parent.parent;
    }
    return false;
  }

  bool get isLeaf => children == null || children?.isEmpty == true;
}

class TreeController<T> with ChangeNotifier {
  TreeNode<T> rootNode;
  String? selectNode;
  String? hoverNode;
  ScrollController? scrollController;
  ScrollPhysics? scrollPhysics;

  TreeController({
    required this.rootNode,
    this.scrollController,
    this.scrollPhysics,
  }) {
    scrollController ??= ScrollController();
  }

  List<TreeNode<T>> get visibleNodes {
    List<TreeNode<T>> ans = [];
    rootNode.getVisibleNodes(ans);
    return ans;
  }

  void reset(TreeNode<T> rootNode) {
    this.rootNode = rootNode;
    notifyListeners();
  }

  void update() {
    notifyListeners();
  }

  TreeNode<T>? find(String id) {
    return rootNode.findChild(id);
  }

  void jumpToNode(TreeNode<T> node) {
    if (scrollController == null) {
      return;
    }
    if (node.parent != null && node.parent!.isExpand == false) {
      node.parent!.setExpand(true);
      notifyListeners();
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        jumpToNode(node);
      });
      return;
    }

    int index = 0;
    int findIndex = -1;
    var nodes = visibleNodes;
    double offset = 0;
    for (var item in nodes) {
      if (item.id == node.id) {
        findIndex = index;
        break;
      }
      index++;
      offset += item.height;
    }
    if (findIndex != -1) {
      var scrollOffset = scrollController!.offset;
      var visionHeight = scrollController!.position.viewportDimension;
      if (offset - scrollOffset < 0) {
        scrollController?.jumpTo(offset);
      }
      if (offset + nodes[findIndex].height - scrollOffset > visionHeight) {
        scrollController
            ?.jumpTo(offset + visionHeight - nodes[findIndex].height);
      }
    }
  }

  void toggleExpanded(TreeNode node) {
    node.setExpand(!node.isExpand);
    update();
  }
}

class TreeView<T> extends StatefulWidget {
  TreeController<T> controller;
  NodeBuilder<T> nodeBuilder;
  EdgeInsets padding;

  TreeView({
    Key? key,
    required this.controller,
    required this.nodeBuilder,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  @override
  State<TreeView<T>> createState() => _TreeViewState<T>();
}

class _TreeViewState<T> extends State<TreeView<T>> {
  @override
  Widget build(BuildContext context) {
    var nodeBuilder = widget.nodeBuilder;
    var nodes = widget.controller.visibleNodes;
    return ListView.builder(
      padding: widget.padding,
      controller: widget.controller.scrollController,
      physics: widget.controller.scrollPhysics,
      itemCount: nodes.length,
      itemBuilder: (context, index) {
        return nodeBuilder.call(
          context,
          nodes[index],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(onValueChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(onValueChanged);
    super.dispose();
  }

  void onValueChanged() {
    if (super.mounted) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(covariant TreeView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
  }
}

class SelectData {
  bool selected = false;
  int leafCount = 0;
  int leafCheckCount = 0;
  Object object;

  SelectData({
    required this.object,
  });

  bool? get calcChecked {
    return selected ? (leafCount != leafCheckCount ? null : true) : false;
  }
}

typedef SelectTreeNode = TreeNode<SelectData>;
typedef SelectTreeView = TreeView<SelectData>;
typedef SelectTreeController = TreeController<SelectData>;

extension SelectExtension on SelectTreeController {
  void calcLeafCount(SelectTreeNode node) {
    var children = node.children;
    if (children != null && children.isNotEmpty) {
      var leafCount = 0;
      var leafCheckCount = 0;
      for (var child in children) {
        calcLeafCount(child);
        leafCount += (child.data?.leafCount ?? 0);
        leafCheckCount += (child.data?.leafCheckCount ?? 0);
      }
      node.data?.leafCount = leafCount;
      node.data?.leafCheckCount = leafCheckCount;
    } else {
      node.data?.leafCount = 1;
      if (node.data?.selected == true) {
        node.data?.leafCheckCount = 1;
      } else {
        node.data?.leafCheckCount = 0;
      }
    }
  }

  void updateChecked(SelectTreeNode node, bool checked) {
    node.data?.selected = checked;
    node.visitChildren((node) {
      node.data?.selected = checked;
      return true;
    });
    calcLeafCount(rootNode);
    rootNode.visitChildren((node) {
      node.data?.selected = (node.data?.leafCheckCount ?? 0) > 0;
      return true;
    });
    notifyListeners();
  }
}
