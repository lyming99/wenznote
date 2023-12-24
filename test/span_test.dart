import 'package:fluent_ui/fluent_ui.dart';
import 'package:note/editor/block/text/rich_text_painter.dart';
/// 1.placeholder会占居1个字符长度
void main() {
  var textSpan = TextSpan(text: "hello", children: [
    WidgetSpan(child: Text("hello")),
  ]);
  var richTextPainter = RichTextPainter(
    text: textSpan,
    textDirection: TextDirection.ltr,
    strutStyle: StrutStyle.fromTextStyle(
      textSpan.style ?? const TextStyle(),
      forceStrutHeight: false,
    ),
    textHeightBehavior: const TextHeightBehavior(
      applyHeightToLastDescent: true,
      applyHeightToFirstAscent: true,
    ),
    textScaleFactor: 1.02,
  );
  richTextPainter.setPlaceholderDimensions([
    PlaceholderDimensions(
      size: Size(3, 10),
      alignment: PlaceholderAlignment.aboveBaseline,
    ),
  ]);
  richTextPainter.layout();
  var pos = richTextPainter.getPositionForOffset(Offset(richTextPainter.width-2, 1));
  print('${pos}');
}
