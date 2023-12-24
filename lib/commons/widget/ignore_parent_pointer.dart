import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class IgnoreParentPointer extends SingleChildRenderObjectWidget {
  final bool Function(IgnoreParentMousePointerRender render, Offset position)?
      ignorePointer;

  const IgnoreParentPointer({
    super.key,
    super.child,
    this.ignorePointer,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return IgnoreParentMousePointerRender(parentPointer: this);
  }
}

class IgnoreParentMousePointerRender extends RenderProxyBoxWithHitTestBehavior {
  IgnoreParentPointer parentPointer;

  IgnoreParentMousePointerRender({
    required this.parentPointer,
  });

  bool ignorePointer(Offset position) {
    bool? ignore = parentPointer.ignorePointer?.call(this, position);
    if (ignore == false) {
      return false;
    }
    return true;
  }
}

class IgnoreParentMousePointerContainer extends SingleChildRenderObjectWidget {
  const IgnoreParentMousePointerContainer({
    super.key,
    super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return IgnoreParentMousePointerContainerRender();
  }
}

class IgnoreParentMousePointerContainerRender
    extends RenderProxyBoxWithHitTestBehavior {
  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    try {
      return super.hitTest(result, position: position);
    } finally {
      var list = result.path as List<HitTestEntry>;
      int i = list.indexWhere(
          (element) => element.target is IgnoreParentMousePointerRender);
      if (i != -1) {
        var item = list[i].target as IgnoreParentMousePointerRender;
        var ignore = item.ignorePointer(position);
        if (ignore) {
          list.removeRange(i, list.length - i);
        }
      }
    }
  }
}
