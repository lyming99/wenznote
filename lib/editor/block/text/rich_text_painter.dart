import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class RichTextPainter extends TextPainter {
  RichTextPainter({
    super.text,
    super.textAlign,
    super.textDirection = TextDirection.ltr,
    super.textScaleFactor,
    super.maxLines,
    super.ellipsis,
    super.locale,
    super.strutStyle,
    super.textWidthBasis,
    super.textHeightBehavior,

  });
}

class RichPainter extends CustomPainter {
  RichTextPainter painter;

  RichPainter({
    required this.painter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    painter.paint(canvas, Offset.zero);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
