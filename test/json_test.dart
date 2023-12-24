import 'dart:convert';

import 'package:note/editor/block/element/element.dart';
import 'package:rich_clipboard/rich_clipboard.dart';

void main() {
  var json =
      '[{"type":"text","level":1,"text":"2022-12-21开发计划","fontSize":30.0},{"type":"text","level":0,"text":"大纲视图","itemType":"check","checked":true},{"type":"text","level":0,"text":"滚动条","itemType":"check","checked":true},{"type":"text","level":0,"text":"编辑器底部padding","itemType":"check","checked":true,"children":[]},{"type":"text","level":0},{"type":"text","level":1,"text":"2022-12-22","fontSize":30.0,"children":[{"type":"text","level":1,"text":"开发计划","fontSize":30.0}]},{"type":"text","level":0,"text":"文件、笔记重命名","itemType":"check"},{"type":"text","level":0,"text":"工具栏悬浮","itemType":"check"},{"type":"text","level":0,"text":"文字样式修改","itemType":"check","children":[]},{"type":"text","level":0},{"newLine":true,"type":"title","level":1,"text":"2022-12-23开发计划","fontSize":30.0,"children":[]},{"type":"text","level":0,"text":"笔记多标签","itemType":"check","children":[]},{"type":"text","level":0,"text":"黑暗模式适配 ","itemType":"check","children":[{"type":"text","level":0}]},{"type":"text","level":0,"text":"文字样式美化","itemType":"check"},{"type":"text","level":0},{"newLine":true,"type":"title","level":1,"text":"2022-12-24开发计划","fontSize":30.0,"children":[]},{"type":"text","level":0,"text":"代码行号显示","itemType":"check"},{"type":"text","level":0,"text":"撤销栈优化: ","itemType":"check","children":[{"type":"text","level":0},{"newLine":true,"type":"p","level":0,"text":"block加入uuid"}]},{"type":"text","level":0,"text":"拼音输入适配","itemType":"check","children":[]},{"type":"text","level":0},{"newLine":true,"type":"title","level":1,"text":"2022-12-25开发计划","fontSize":30.0,"children":[]},{"type":"text","level":0,"text":"右键菜单实现与美化","itemType":"check"},{"type":"text","level":0,"text":"复制粘贴功能完善","itemType":"check"},{"type":"text","level":0,"text":"拖动功能完善","itemType":"check","children":[]},{"type":"text","level":0,"text":"引用","itemType":"check"},{"type":"text","level":0},{"newLine":true,"type":"title","level":1,"text":"2022-12-26开发计划","fontSize":30.0,"children":[]},{"type":"text","level":0,"text":"折叠","itemType":"check","children":[]},{"type":"text","level":0,"text":"缩进","itemType":"check"},{"type":"text","level":0,"text":"公式","itemType":"check","children":[]},{"type":"text","level":0,"text":"行内代码","itemType":"check"},{"type":"text","level":0},{"newLine":true,"type":"title","level":1,"text":"2022-12-27开发计划","fontSize":30.0,"children":[]},{"type":"text","level":0,"text":"视频","itemType":"check","checked":false,"children":[]},{"type":"text","level":0,"text":"动图","itemType":"check","checked":false},{"type":"text","level":0},{"newLine":true,"type":"title","level":1,"text":"2022-12-28开发计划","fontSize":30.0},{"type":"text","level":0,"text":"设置界面","itemType":"check","children":[]},{"type":"text","level":0,"text":"菜单","itemType":"check","children":[]},{"type":"text","level":0,"text":"表格","itemType":"check"},{"type":"text","level":0}]';

  var jsonArr = jsonDecode(json);
  if (jsonArr is List) {
    String html = "<!DOCTYPE html>\n"
        "<html>\n<head>\n"
        "<meta charset=\"utf-8\"></meta></head><body>";

    for (var json in List.of(jsonArr)) {
      var element = WenElement.parseJson(json);
      html += element.getHtml();
    }
    html += "</body></html>";
    print('$html');
    RichClipboard.setData(RichClipboardData(html: html, text: ""));
  }
}
