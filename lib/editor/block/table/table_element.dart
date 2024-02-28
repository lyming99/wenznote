import 'dart:math';

import 'package:flutter_crdt/flutter_crdt.dart';
import 'package:wenznote/editor/block/element/element.dart';

import '../../proto/note.pb.dart';

/// table struct
class WenTableElement extends WenElement {
  List<List<WenElement>>? rows;
  Map<int, String>? alignments;

  WenTableElement({
    super.type = "table",
    this.rows,
    this.alignments,
  });

  factory WenTableElement.fromJson(Map<dynamic, dynamic> json) {
    return WenTableElement(
      alignments: (json['alignments'] as Map<dynamic, dynamic>?)
          ?.map((key, value) => MapEntry(int.parse(key), value as String)),
      rows: (json['rows'] as List<dynamic>?)
          ?.map((row) => (row as List<dynamic>).map((cell) {
                return WenElement.parseJson(cell);
              }).toList())
          .toList(),
    )..copyProperties(WenElement.fromJson(json));
  }

  @override
  Map<String, dynamic> toJson() {
    return super.toJson()
      ..addAll({
        if (alignments != null)
          "alignments":
              alignments?.map((key, value) => MapEntry("$key", value)),
        if (rows != null)
          "rows": rows
              ?.map((row) => row.map((cell) => cell.toJson()).toList())
              .toList(),
      });
  }

  @override
  String getHtml({FilePathBuilder? filePathBuilder}) {
    var ans = "";
    var rows = this.rows;
    if (rows != null) {
      ans += "<table>";
      var maxCount = rows
          .map((e) => e.length)
          .reduce((value, element) => max(value, element));
      bool first = true;
      for (var row in rows) {
        ans += "<tr>";
        for (var i = 0; i < maxCount; i++) {
          var html = "";
          if (i < row.length) {
            html = row[i].getHtml();
          }
          if (first) {
            ans += "<th>$html</th>";
          } else {
            ans += "<td>$html</td>";
          }
        }
        if (first) {
          first = false;
        }
        ans += "</tr>";
      }
    }
    return ans;
  }

  @override
  String getMarkDown({FilePathBuilder? filePathBuilder}) {
    // |
    var rows = this.rows;
    if (rows == null || rows.isEmpty) {
      return "";
    }
    var maxCount = rows
        .map((e) => e.length)
        .reduce((value, element) => max(value, element));
    if (maxCount <= 0) {
      return "";
    }
    String result = "";
    // header
    var header = rows[0];
    result += "|";
    for (int i = 0; i < maxCount; i++) {
      String itemHtml = "";
      if (header.isNotEmpty && i < header.length) {
        itemHtml = header[i].getMarkDown(filePathBuilder: filePathBuilder);
      }
      result += "$itemHtml|";
    }
    // alignment
    result += "\n|";
    for (int i = 0; i < maxCount; i++) {
      String alignmentText = "";
      var align = alignments?[i];
      if (align == "right") {
        alignmentText = "---:";
      } else if (align == "center") {
        alignmentText = ":---:";
      } else {
        alignmentText = ":---";
      }
      result += "$alignmentText|";
    }
    result += "\n";
    // rows
    for (int r = 1; r < rows.length; r++) {
      var items = rows[r];
      for (int i = 0; i < maxCount; i++) {
        String itemHtml = "";
        if (items.isNotEmpty && i < items.length) {
          itemHtml = items[i].getMarkDown(filePathBuilder: filePathBuilder);
        }
        result += "$itemHtml|";
      }
      if (r <= rows.length - 1) {
        result += "\n";
      }
    }
    return result;
  }

  @override
  String getText() {
    return rows?.map((e) => e.map((e) => e.getText()).join("\t")).join("\n") ??
        "";
  }

  @override
  NoteElement toNoteElement() {
    var ret = super.toNoteElement();
    var arr = alignments;
    if (arr != null) {
      ret.alignments.addAll(arr);
    }
    //递归转换 rows
    var rowsTemp = rows;
    if (rowsTemp != null) {
      var elements = rowsTemp
          .map((e) => e.map((e) => e.toNoteElement()).toList())
          .map((e) => NoteElement_Row(items: e))
          .toList();
      ret.rows.addAll(elements);
    }
    return ret;
  }

  @override
  YMap getYMap() {
    var alignmentsAttr = YMap();
    var arr = alignments;
    if (arr != null) {
      for (var entry in arr.entries) {
        alignmentsAttr.set(entry.key.toString(), entry.value);
      }
    }
    var result = YMap();
    result.set("type", "table");
    result.set('alignments', alignmentsAttr);
    var rowsAttr = YArray();
    var rows = this.rows;
    if (rows != null) {
      rowsAttr.insert(
          0,
          rows.map((row) {
            var arr = YArray();
            arr.insert(0, row.map((e) => e.getYMap()).toList());
            return arr;
          }).toList());
    }
    result.set('rows', rowsAttr);
    return result;
  }
}
