import 'dart:collection';
import 'package:collection/collection.dart';

class ChangeStack {
  List content;
  int? limit;
  final Queue<Change> _history = Queue();
  final Queue<Change> _previous = Queue();

  ChangeStack({
    this.limit,
    required this.content,
  });

  HashMap<String, String> getPreviousUuidMap(List content) {
    var ret = HashMap<String, String>();
    for (var i = 1; i < content.length; i++) {
      if (content[i]["uuid"] != null) {
        ret[content[i]["uuid"]] = content[i - 1]["uuid"];
      }
    }
    return ret;
  }

  Map toItemMap(List content) {
    var map = {};
    for (var item in content) {
      if (item["uuid"] != null) {
        map[item["uuid"]] = item;
      }
    }
    return map;
  }

  List subMid(List list, int startLen, int endLen) {
    int startIndex = startLen;
    int endIndex = list.length - endLen;
    if (endIndex < startIndex) {
      endIndex = startIndex;
    }
    if (startIndex >= list.length) {
      return [];
    }
    return list.sublist(startIndex, endIndex);
  }

  Change? record(List content, {Map<String, dynamic>? attributes}) {
    var oldContent = this.content;
    var newContent = content;
    int preLen = 0;
    for (var i = 0; i < oldContent.length && i < newContent.length; i++) {
      preLen = i + 1;
      if (!const MapEquality().equals(oldContent[i], newContent[i])) {
        preLen = i;
        break;
      }
    }
    var endLen = 0;
    for (var i = 1; i <= oldContent.length && i <= newContent.length; i++) {
      var oldIndex = oldContent.length - i;
      var newIndex = newContent.length - i;
      if (newIndex < 0 || oldIndex < 0) {
        break;
      }
      if(i>=oldContent.length||newIndex>=newContent.length){
        break;
      }
      endLen = i;
      if (!const MapEquality().equals(oldContent[i], newContent[newIndex])) {
        endLen = i - 1;
        break;
      }
    }
    var oldItem =  subMid(oldContent, preLen, endLen);
    var newItem = subMid(newContent, preLen, endLen);
    var replacement =
        Replacement(index: preLen, oldItem: oldItem, newItem: newItem);

    this.content = content;
    var change = UpdateChange(replacement: replacement, attributes: attributes);
    _history.addLast(change);
    _previous.clear();
    if (limit != null) {
      if (_previous.length > limit!) {
        _previous.removeFirst();
      }
    }
    return change;
  }

  Change? undo() {
    if (!canUndo) {
      return null;
    }
    var change = _history.removeLast();
    _previous.addFirst(change);
    content = change.undo(content);
    return change;
  }

  Change? redo() {
    if (!canRedo) {
      return null;
    }
    var change = _previous.removeFirst();
    _history.addLast(change);
    content = change.redo(content);
    return change;
  }

  bool get canUndo => _history.isNotEmpty;

  bool get canRedo => _previous.isNotEmpty;

  void reset(List content) {
    this.content = content;
    _previous.clear();
    _history.clear();
  }
}

abstract class Change {
  Map<String, dynamic>? attributes;

  Change({required this.attributes});

  List undo(List content);

  List redo(List content);
}

class UpdateChange extends Change {
  Replacement replacement;

  UpdateChange({
    required this.replacement,
    required super.attributes,
  });

  @override
  List redo(List content) {
    var index = replacement.index;
    content.replaceRange(index, index + replacement.oldItem.length,
        <Map>[...replacement.newItem]);
    return content;
  }

  @override
  List undo(List content) {
    var index = replacement.index;
    content.replaceRange(index, index + replacement.newItem.length,
        <Map>[...replacement.oldItem]);
    return content;
  }
}

class Replacement {
  int index;
  List oldItem;
  List newItem;

  Replacement({
    required this.index,
    required this.oldItem,
    required this.newItem,
  });
}
