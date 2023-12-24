import 'package:flutter/material.dart';
import 'package:note/app/windows/theme/colors.dart';
import 'package:note/commons/widget/ignore_parent_pointer.dart';
import 'package:note/editor/edit_controller.dart';
import 'package:note/editor/theme/theme.dart';
import 'package:note/editor/widget/modal_widget.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

import 'edit_content_widget.dart';

class EditWidget extends StatefulWidget {
  EditController controller;

  EditWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<EditWidget> createState() => EditState();
}

class EditState extends State<EditWidget> {
  bool dropOver = false;

  static EditState of(BuildContext context) {
    return context.findRootAncestorStateOfType<EditState>()!;
  }

  @override
  Widget build(BuildContext context) {
    var editTheme = EditTheme.of(context);
    return ModalContainer(
      controller: widget.controller.modalController,
      child: Material(
        color: Colors.transparent,
        textStyle: TextStyle(
          fontSize: editTheme.fontSize,
          color: editTheme.fontColor,
        ),
        child: DropRegion(
          formats: Formats.standardFormats,
          hitTestBehavior: HitTestBehavior.opaque,
          onDropOver: (event) {
            widget.controller.onDragIn(event);
            if (event.session.allowedOperations.contains(DropOperation.copy)) {
              return DropOperation.copy;
            } else {
              return DropOperation.none;
            }
          },
          onDropEnter: (event) {
            setState(() {
              dropOver = true;
            });
          },
          onDropLeave: (event) {
            setState(() {
              dropOver = false;
            });
          },
          onDropEnded: (event) {
            setState(() {
              dropOver = false;
            });
          },
          onPerformDrop: (event) async {
            await widget.controller.performDragIn(event);
          },
          child: Listener(
            onPointerSignal: (event) {
              if (event is PointerDownEvent) {
                if (event.buttons == 1) {
                  widget.controller.showContextMenu(event.localPosition);
                }
                return;
              }
            },
            child: Stack(
              children: [
                widget.controller.editable
                    ? MouseRegion(
                        cursor: MaterialStateMouseCursor.textable,
                        child: buildScrollable(),
                      )
                    : buildScrollable(),
                if (dropOver)
                  Container(
                    color: Colors.black.withOpacity(0.2),
                  ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ListenableBuilder(
                    builder: (context, child) {
                      if (!widget.controller.showTextLength) {
                        return Container();
                      }
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "字数统计: ${widget.controller.textLength}",
                          style: TextStyle(
                            color: systemColor(context,"textLengthColor"),
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                    listenable: widget.controller,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildScrollable() {
    return IgnoreParentPointer(
      ignorePointer: (box, offset) {
        var extend =
            widget.controller.scrollController?.position.maxScrollExtent;
        if (extend == 0) {
          return false;
        }
        var g = box.localToGlobal(Offset(box.size.width, box.size.height));
        if (offset.dx > g.dx - 14 && offset.dx < g.dx) {
          return true;
        }
        return false;
      },
      child: Scrollable(
          physics: widget.controller.isFloatWidgetDragging
              ? const NeverScrollableScrollPhysics()
              : const BouncingScrollPhysics(),
          controller: widget.controller.scrollController,
          viewportBuilder: (context, viewportOffset) {
            return EditContentWidget(
              controller: widget.controller,
              viewportOffset: viewportOffset,
            );
          }),
    );
  }

  void updateState() {
    setState(() {});
  }
}
