import 'package:wenznote/editor/crdt/YsTree.dart';

import 'YsCursor.dart';

class YsSelection {
  YsCursor? start;
  YsCursor? end;

  YsSelection copyWith({YsCursor? start, YsCursor? end, YsTree? tree}) {
    var res = YsSelection();
    res.start = start ?? this.start?.copyWith(tree: tree);
    res.end = end ?? this.end?.copyWith(tree: tree);
    return res;
  }
}
