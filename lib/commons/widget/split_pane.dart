import 'dart:math';

import 'package:flutter/material.dart';

enum PaneIndex { one, two }

enum SizeMode {
  scale,
  size,
}

///SplitPane有2种分割方式
///1.按比例分割：线的比例
///2.按固定大小分割
class SplitPane extends StatefulWidget {
  Axis direction;
  Widget one;
  Widget two;
  double scale;
  double primarySize;
  PaneIndex primaryIndex;
  PaneIndex? onlyShowIndex;
  SizeMode sizeMode;
  Color splitColor;
  double splitWidth;

  //最小宽度:若小于此宽度，直接隐藏
  double primaryMinSize;
  double subMinSize;

  SplitPane({
    Key? key,
    this.direction = Axis.horizontal,
    this.sizeMode = SizeMode.size,
    this.primaryIndex = PaneIndex.one,
    required this.one,
    required this.two,
    this.scale = 0.5,
    this.primarySize = 200,
    this.primaryMinSize = 10,
    this.subMinSize = 10,
    this.splitWidth = 8,
    this.splitColor = Colors.transparent,
    this.onlyShowIndex,
  }) : super(key: key);

  @override
  State<SplitPane> createState() => _SplitPaneState();
}

class _SplitPaneState extends State<SplitPane> {
  late double size;
  late double scale;

  @override
  void initState() {
    super.initState();
    size = widget.primarySize;
    scale = widget.scale;
  }

  @override
  Widget build(BuildContext context) {
    return widget.onlyShowIndex != null
        ? (widget.onlyShowIndex == PaneIndex.one
            ? SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: widget.one,
              )
            : SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: widget.two,
              ))
        : LayoutBuilder(builder: (context, constrains) {
            calcSize(constrains.maxWidth, constrains.maxHeight);
            var width = size;
            var height = size;
            if (widget.sizeMode == SizeMode.scale) {
              width = constrains.maxWidth * scale;
              height = constrains.maxHeight * scale;
            }
            return Stack(
              children: [
                if (widget.direction == Axis.horizontal)
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.primaryIndex == PaneIndex.one
                        ? [
                            SizedBox(
                              width: width,
                              height: double.infinity,
                              child: widget.one,
                            ),
                            Expanded(
                              child: widget.two,
                            ),
                          ]
                        : [
                            Expanded(
                              child: widget.one,
                            ),
                            SizedBox(
                              width: width,
                              height: double.infinity,
                              child: widget.two,
                            ),
                          ],
                  ),
                if (widget.direction == Axis.vertical)
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    children: widget.primaryIndex == PaneIndex.one
                        ? [
                            SizedBox(
                              width: double.infinity,
                              height: height,
                              child: widget.one,
                            ),
                            Expanded(
                              child: widget.two,
                            ),
                          ]
                        : [
                            Expanded(
                              child: widget.one,
                            ),
                            SizedBox(
                              width: double.infinity,
                              height: height,
                              child: widget.two,
                            ),
                          ],
                  ),
                Positioned(
                    top: widget.direction == Axis.vertical
                        ? ((widget.primaryIndex == PaneIndex.one
                                ? height
                                : constrains.maxHeight - height) -
                            widget.splitWidth / 2)
                        : null,
                    left: widget.direction == Axis.horizontal
                        ? (widget.primaryIndex == PaneIndex.one
                                ? width
                                : constrains.maxWidth - width) -
                            widget.splitWidth / 2
                        : null,
                    width: widget.direction == Axis.vertical
                        ? constrains.maxWidth
                        : ((size >= constrains.maxWidth - widget.splitWidth / 2)
                            ? 0
                            : widget.splitWidth),
                    height: widget.direction == Axis.horizontal
                        ? constrains.maxWidth
                        : (size >= constrains.maxHeight - widget.splitWidth / 2
                            ? 0
                            : widget.splitWidth),
                    child: MouseRegion(
                      cursor: widget.direction == Axis.vertical
                          ? SystemMouseCursors.resizeRow
                          : SystemMouseCursors.resizeColumn,
                      child: GestureDetector(
                        onPanDown: (event) {
                          isPanDown = true;
                          onPanDown(event);
                        },
                        onPanUpdate: (event) {
                          onPanUpdate(event);
                        },
                        onPanEnd: (event) {
                          setState(() {
                            isPanDown = false;
                          });
                        },
                        onPanCancel: () {
                          setState(() {
                            isPanDown = false;
                          });
                        },
                        child: Container(
                          color: widget.splitColor,
                        ),
                      ),
                    )),
                if (isPanDown)
                  Container(
                    child: MouseRegion(
                      cursor: widget.direction == Axis.vertical
                          ? SystemMouseCursors.resizeRow
                          : SystemMouseCursors.resizeColumn,
                    ),
                  )
              ],
            );
          });
  }

  Offset panDownOffset = Offset.zero;
  double panDownSize = 0;
  double panDownScale = 0;
  bool isPanDown = false;

  void onPanDown(DragDownDetails details) {
    panDownOffset = details.localPosition;
    panDownSize = size;
    panDownScale = scale;
  }

  void calcSize(double width, double height) {
    bool update = false;
    if (size < widget.primaryMinSize) {
      size = widget.primaryMinSize;
      update = true;
    }
    if (widget.direction == Axis.vertical) {
      var maxHeight = max(height - widget.subMinSize, height / 2);
      if (size > maxHeight) {
        size = maxHeight;
        update = true;
      }
    } else {
      var maxWidth = max(width - widget.subMinSize, width / 2);
      if (size > maxWidth) {
        size = maxWidth;
        update = true;
      }
    }
    if (update) {
      WidgetsBinding.instance.scheduleFrameCallback((timeStamp) {
        setState(() {});
      });
    }
  }

  @override
  void didUpdateWidget(covariant SplitPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    var sizeBox = context.findRenderObject() as RenderBox;
    calcSize(sizeBox.size.width, sizeBox.size.height);
  }

  void onPanUpdate(DragUpdateDetails details) {
    var sizeBox = context.findRenderObject() as RenderBox;
    setState(() {
      var d = details.localPosition - panDownOffset;
      if (widget.primaryIndex == PaneIndex.two) {
        d *= -1;
      }
      if (widget.sizeMode == SizeMode.size) {
        if (widget.direction == Axis.vertical) {
          size = panDownSize + d.dy;
          if (size > sizeBox.size.height - widget.subMinSize) {
            size = sizeBox.size.height - widget.subMinSize;
          }
        } else {
          size = panDownSize + d.dx;
          if (size > sizeBox.size.width - widget.subMinSize) {
            size = sizeBox.size.width - widget.subMinSize;
          }
        }
        calcSize(sizeBox.size.width, sizeBox.size.height);
      } else {
        if (widget.direction == Axis.vertical) {
          scale = panDownScale + (d.dy / sizeBox.size.height);
        } else {
          scale = panDownScale + (d.dx / sizeBox.size.width);
        }
      }
    });
  }
}
