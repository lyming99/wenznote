import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef OnLayout = Function(RenderBox renderBox);

class RenderLayoutWidget extends SingleChildRenderObjectWidget {
  OnLayout? onLayout;

  RenderLayoutWidget({super.key, super.child, this.onLayout});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return MeasureSizeRenderObject(this);
  }
}

class MeasureSizeRenderObject extends RenderProxyBox {
  RenderLayoutWidget widget;

  MeasureSizeRenderObject(this.widget);

  @override
  void performLayout() {
    super.performLayout();
    widget.onLayout?.call(this);
  }
}
