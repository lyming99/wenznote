import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import '../../mouse/mouse.dart';
import '../../theme/theme.dart';

class CustomScrollBar extends StatefulWidget {
  Axis direction;
  Function(ScrollBarInfo info)? calcSize;
  Function(ScrollBarInfo info)? toPageUp;
  Function(ScrollBarInfo info)? toPageDown;
  Function(ScrollBarInfo info, double delta)? scroll;

  CustomScrollBar({
    Key? key,
    this.direction = Axis.vertical,
    this.calcSize,
    this.toPageUp,
    this.toPageDown,
    this.scroll,
  }) : super(key: key);

  @override
  State<CustomScrollBar> createState() => _CustomScrollBarState();
}

class ScrollBarInfo {
  bool hoverScrollBar = false;
  double minScrollBarSize = 50;
  double scrollBarWidth = 6.0;
  double scrollBarSize = 0.0;
  double scrollBarOffset = 0;
  bool scrollDragStart = false;
  bool downScrollBar = false;

  void resetSize() {
    minScrollBarSize = 50;
    scrollBarWidth = 6.0;
    scrollBarSize = 0.0;
  }

  void calcScrollBarSize(
      double contentHeight, double viewHeight, double scrollOffset) {
    if (contentHeight - 0.2 <= viewHeight) {
      scrollBarSize = 0;
    } else {
      scrollBarSize = viewHeight / contentHeight * viewHeight;
      scrollBarOffset = scrollOffset / contentHeight * viewHeight;
      if (scrollBarSize < minScrollBarSize) {
        scrollBarSize = minScrollBarSize;
        scrollBarOffset = (scrollOffset) *
            (viewHeight - scrollBarSize) /
            (contentHeight - viewHeight);
      }
    }
  }
}

class _CustomScrollBarState extends State<CustomScrollBar> {
  ScrollBarInfo scrollBarInfo = ScrollBarInfo();

  @override
  Widget build(BuildContext context) {
    widget.calcSize?.call(scrollBarInfo);
    return MouseRegion(
      cursor: MaterialStateMouseCursor.clickable,
      onExit: (event) {
        setState(() {
          scrollBarInfo.hoverScrollBar = false;
        });
      },
      onEnter: (event) {
        setState(() {
          scrollBarInfo.hoverScrollBar = true;
        });
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanDown: (event) {
          var pos = event.localPosition.dx;
          var barSize = scrollBarInfo.scrollBarSize;
          if (widget.direction == Axis.vertical) {
            pos = event.localPosition.dy;
          }
          if (pos < scrollBarInfo.scrollBarOffset) {
            setState(() {
              widget.toPageUp?.call(scrollBarInfo);
            });
          } else if (pos > scrollBarInfo.scrollBarOffset + barSize) {
            setState(() {
              widget.toPageDown?.call(scrollBarInfo);
            });
          } else {
            scrollBarInfo.scrollDragStart = true;
          }
        },
        onPanUpdate: (event) {
          if (scrollBarInfo.scrollDragStart) {
            var pos = event.delta.dx;
            if (widget.direction == Axis.vertical) {
              pos = event.delta.dy;
            }
            setState(() {
              widget.scroll?.call(scrollBarInfo, pos);
            });
          }
        },
        onPanEnd: (event) {
          scrollBarInfo.scrollDragStart = false;
        },
        child: Container(
          width: widget.direction == Axis.vertical
              ? scrollBarInfo.scrollBarWidth
              : double.infinity,
          height: widget.direction == Axis.vertical
              ? double.infinity
              : scrollBarInfo.scrollBarWidth,
          color:
              (scrollBarInfo.hoverScrollBar || scrollBarInfo.downScrollBar) &&
                      (scrollBarInfo.scrollBarSize != 0)
                  ? EditTheme.of(context).scrollBarHoverBgColor
                  : null,
          child: Stack(
            children: [
              Positioned(
                top: widget.direction == Axis.vertical
                    ? scrollBarInfo.scrollBarOffset
                    : null,
                left: widget.direction == Axis.horizontal
                    ? scrollBarInfo.scrollBarOffset
                    : null,
                child: MouseEventListenerWidget(
                  behavior: HitTestBehavior.deferToChild,
                  eventListener: (event, entry) {
                    if (event is PointerDownEvent) {
                      setState(() {
                        scrollBarInfo.downScrollBar = true;
                      });
                    } else if (event is PointerUpEvent) {
                      setState(() {
                        scrollBarInfo.downScrollBar = false;
                      });
                    }
                  },
                  child: Container(
                    color: (scrollBarInfo.hoverScrollBar ||
                            scrollBarInfo.downScrollBar)
                        ? EditTheme.of(context).scrollBarHoverColor
                        : EditTheme.of(context).scrollBarDefaultColor,
                    width: widget.direction == Axis.vertical
                        ? scrollBarInfo.scrollBarWidth
                        : scrollBarInfo.scrollBarSize,
                    height: widget.direction == Axis.vertical
                        ? scrollBarInfo.scrollBarSize
                        : scrollBarInfo.scrollBarWidth,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant CustomScrollBar oldWidget) {
    super.didUpdateWidget(oldWidget);
  }
}
