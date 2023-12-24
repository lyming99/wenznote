import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

class PopupStack extends Stack {
  PopupStack({
    super.key,
    super.alignment,
    super.textDirection,
    super.fit,
    super.clipBehavior,
    super.children,
  });

  @override
  RenderStack createRenderObject(BuildContext context) {
    return PopupRenderStack(
      alignment: alignment,
      textDirection: textDirection ?? Directionality.maybeOf(context),
      fit: fit,
      clipBehavior: clipBehavior,
    );
  }
}

class PopupRenderStack extends RenderStack {
  PopupRenderStack({
    super.children,
    super.alignment,
    super.textDirection,
    super.fit,
    super.clipBehavior,
  });

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! StackParentData) {
      child.parentData = PopupStackParentData();
    }
  }

  @override
  void performLayout() {
    super.performLayout();
    RenderBox? child = firstChild;
    while (child != null) {
      final StackParentData childParentData =
          child.parentData! as StackParentData;
      if (childParentData is PopupStackParentData) {
        var anchorRect = childParentData.anchorRect;
        var popupAlignment = childParentData.popupAlignment;
        var overflowAlignment = childParentData.overflowAlignment;
        var verticalAlignment = childParentData.verticalAlignment;
        if (anchorRect != null) {
          if (popupAlignment != null) {
            Offset offset;
            if (overflowAlignment != null) {
              var aOffset = popupAlignment.alignRect(
                  anchorRect, child.size, verticalAlignment);
              var bOffset = overflowAlignment.alignRect(
                  anchorRect, child.size, verticalAlignment);
              int aScore = 0;
              int bScore = 0;
              if (aOffset.dx < 0 ||
                  aOffset.dx + child.size.width > size.width) {
                aScore += 1;
              }
              if (aOffset.dy < 0 ||
                  aOffset.dy + child.size.height > size.height) {
                aScore += 1;
              }
              if (bOffset.dx < 0 ||
                  bOffset.dx + child.size.width > size.width) {
                bScore += 1;
              }
              if (bOffset.dy < 0 ||
                  bOffset.dy + child.size.height > size.height) {
                bScore += 1;
              }
              if (aScore <= bScore) {
                offset = aOffset;
              } else {
                offset = bOffset;
              }
            } else {
              offset = popupAlignment.alignRect(
                  anchorRect, child.size, verticalAlignment);
            }
            var dx = offset.dx;
            var dy = offset.dy;
            if (childParentData.keepVision == true &&
                (Rect.fromLTWH(0, 0, size.width, size.height)
                    .overlaps(anchorRect))) {
              if (dx > size.width - child.size.width) {
                dx = size.width - child.size.width;
              }
              if (dx < 0) {
                dx = 0;
              }
              if (dy > size.height - child.size.height) {
                dy = size.height - child.size.height;
              }
              if (dy < 0) {
                dy = 0;
              }
            }
            childParentData.offset = Offset(dx, dy);
          }
        } else {
          var offset = childParentData.offset;
          var dx = offset.dx;
          var dy = offset.dy;
          if (childParentData.keepVision == true) {
            if (dx > size.width - child.size.width) {
              dx = size.width - child.size.width;
            }
            if (dx < 0) {
              dx = 0;
            }
            if (dy > size.height - child.size.height) {
              dy = size.height - child.size.height;
            }
            if (dy < 0) {
              dy = 0;
            }
          }
          childParentData.offset = Offset(dx, dy);
        }
      }
      assert(child.parentData == childParentData);
      child = childParentData.nextSibling;
    }
  }
}

class PopupStackParentData extends StackParentData {
  Rect? anchorRect;
  Alignment? popupAlignment;

  //越界后使用的对齐方式
  Alignment? overflowAlignment;

  bool? keepVision;

  VerticalAlignment? verticalAlignment;
}

enum VerticalAlignment {
  top,
  center,
  bottom,
}

extension AlignRect on Alignment {
  Offset alignRect(
      Rect anchor, Size itemSize, VerticalAlignment? verticalAlignment) {
    var center = anchor.center;
    if (this == Alignment.topLeft) {
      return Offset(anchor.left, anchor.top - itemSize.height);
    } else if (this == Alignment.topCenter) {
      return Offset(
          center.dx - itemSize.width / 2, anchor.top - itemSize.height);
    } else if (this == Alignment.topRight) {
      return Offset(
          anchor.right - itemSize.width, anchor.top - itemSize.height);
    } else if (this == Alignment.centerLeft) {
      if (verticalAlignment == VerticalAlignment.top) {
        return Offset(anchor.left - itemSize.width, anchor.top);
      } else if (verticalAlignment == VerticalAlignment.bottom) {
        return Offset(
            anchor.left - itemSize.width, anchor.bottom - itemSize.height);
      }
      return Offset(
          anchor.left - itemSize.width, center.dy - itemSize.height / 2);
    } else if (this == Alignment.centerRight) {
      if (verticalAlignment == VerticalAlignment.top) {
        return Offset(anchor.right, anchor.top);
      } else if (verticalAlignment == VerticalAlignment.bottom) {
        return Offset(anchor.right, anchor.bottom - itemSize.height);
      }
      return Offset(anchor.right, center.dy - itemSize.height / 2);
    } else if (this == Alignment.bottomLeft) {
      return Offset(anchor.left, anchor.bottom);
    } else if (this == Alignment.bottomCenter) {
      return Offset(center.dx - itemSize.width / 2, anchor.bottom);
    } else if (this == Alignment.bottomRight) {
      return Offset(anchor.right - itemSize.width, anchor.bottom);
    }
    return Offset(center.dx, center.dy);
  }
}

class PopupPositionWidget extends Positioned {
  int layerIndex;

  /// 锚点
  Rect? anchorRect;
  Alignment? popupAlignment;

  //越界后使用的对齐方式
  Alignment? overflowAlignment;
  bool? keepVision;
  VerticalAlignment? verticalAlignment;

  PopupPositionWidget({
    super.key,
    required super.child,
    this.layerIndex = 0,
    super.left,
    super.top,
    super.right,
    super.bottom,
    super.width,
    super.height,
    this.anchorRect,
    this.popupAlignment,
    this.overflowAlignment,
    this.keepVision,
    this.verticalAlignment,
  });

  @override
  void applyParentData(RenderObject renderObject) {
    super.applyParentData(renderObject);
    assert(renderObject.parentData is StackParentData);
    final StackParentData parentData =
        renderObject.parentData! as StackParentData;
    bool needsLayout = false;
    if (parentData is PopupStackParentData) {
      if (parentData.overflowAlignment != overflowAlignment) {
        parentData.overflowAlignment = overflowAlignment;
        needsLayout = true;
      }
      if (parentData.popupAlignment != popupAlignment) {
        parentData.popupAlignment = popupAlignment;
        needsLayout = true;
      }
      if (parentData.verticalAlignment != verticalAlignment) {
        parentData.verticalAlignment = verticalAlignment;
        needsLayout = true;
      }
      if (parentData.anchorRect != anchorRect) {
        parentData.anchorRect = anchorRect;
        needsLayout = true;
      }
      if (parentData.keepVision != keepVision) {
        parentData.keepVision = keepVision;
        needsLayout = true;
      }
      if (needsLayout) {
        var targetParent = renderObject.parent;
        if (targetParent is RenderObject) {
          targetParent.markNeedsLayout();
        }
      }
    }
  }
}
