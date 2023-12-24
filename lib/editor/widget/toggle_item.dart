import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';

typedef CheckItemBuilder = Widget Function(
    BuildContext context, bool checked, bool hover, bool pressed);
typedef VoidCallback = void Function(BuildContext context);
typedef EventCallback = void Function(
    BuildContext context, TapDownDetails details);

class ToggleItem extends StatefulWidget {
  bool checked;
  CheckItemBuilder itemBuilder;
  ValueChanged<bool?>? onChanged;
  VoidCallback? onTap;
  EventCallback? onSecondaryTap;
  VoidCallback? onHoverEnter;
  VoidCallback? onHoverExit;
  MouseCursor cursor;

  ToggleItem({
    Key? key,
    this.checked = false,
    required this.itemBuilder,
    this.onChanged,
    this.onTap,
    this.onHoverEnter,
    this.onHoverExit,
    this.onSecondaryTap,
    this.cursor = MaterialStateMouseCursor.clickable,
  }) : super(key: key);

  @override
  State<ToggleItem> createState() => _ToggleItemState();
}

class _ToggleItemState extends State<ToggleItem> {
  var flyoutController = fluent.FlyoutController();
  bool checked = false;
  bool hover = false;
  bool pressed = false;

  @override
  void initState() {
    super.initState();
    checked = widget.checked;
  }

  @override
  void didUpdateWidget(covariant ToggleItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    checked = widget.checked;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (d) {
        setState(() {
          pressed = true;
        });
      },
      onTapCancel: () {
        setState(() {
          pressed = false;
        });
      },
      onTapUp: (e) {
        setState(() {
          pressed = false;
        });
      },
      onTap: () {
        checked = !checked;
        widget.onChanged?.call(checked);
        widget.onTap?.call(context);
        setState(() {});
      },
      onSecondaryTapDown: (details) {
        widget.onSecondaryTap?.call(context, details);
      },
      child: MouseRegion(
          cursor: widget.cursor,
          onEnter: (e) {
            if(hover==true){
              return;
            }
            setState(() {
              hover = true;
              widget.onHoverEnter?.call(context);
            });
          },
          onExit: (e) {
            if(hover==false){
              return;
            }
            setState(() {
              hover = false;
              widget.onHoverExit?.call(context);
            });
          },
          child: fluent.FlyoutTarget(
              controller: flyoutController,
              child:
                  widget.itemBuilder.call(context, checked, hover, pressed))),
    );
  }
}
