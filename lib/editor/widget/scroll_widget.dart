import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef ScrollBuilder = Widget Function(
    BuildContext context, ViewportOffset viewportOffset);

class CustomSingleChildScrollView extends StatelessWidget {
  final ScrollBuilder builder;
  final VoidCallback? onScrollChanged;
  final ScrollController? scrollController;
  final ScrollPhysics? scrollPhysics;

  const CustomSingleChildScrollView({
    Key? key,
    required this.builder,
    this.onScrollChanged,
    this.scrollController,
    this.scrollPhysics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scrollable(
      excludeFromSemantics: true,
      physics: scrollPhysics,
      controller: scrollController,
      viewportBuilder: (context, offset) {
        return _CustomScrollChild(
          offset: offset,
          offsetListener: onScrollChanged,
          builder: builder,
        );
      },
    );
  }
}

class _CustomScrollChild extends StatefulWidget {
  ScrollBuilder builder;
  ViewportOffset offset;
  VoidCallback? offsetListener;

  _CustomScrollChild({
    Key? key,
    required this.builder,
    required this.offset,
    required this.offsetListener,
  }) : super(key: key);

  @override
  State<_CustomScrollChild> createState() => _CustomScrollChildState();
}

class _CustomScrollChildState extends State<_CustomScrollChild> {
  @override
  void initState() {
    super.initState();
    widget.offset.addListener(onOffsetChanged);
  }

  @override
  void dispose() {
    widget.offset.removeListener(onOffsetChanged);
    super.dispose();
  }

  void onOffsetChanged() {
    setState(() {
      widget.offsetListener?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder.call(context, widget.offset);
  }

  @override
  void didUpdateWidget(covariant _CustomScrollChild oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.offset.removeListener(onOffsetChanged);
    widget.offset.addListener(onOffsetChanged);
  }
}
