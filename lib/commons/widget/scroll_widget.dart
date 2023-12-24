import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/gestures/events.dart';
import 'package:flutter/widgets.dart';

///实现一个滚动视图，支持双向滚动
///滚动冲突解决
class CustomScrollWidget extends StatefulWidget {
  CustomScrollController controller;
  CustomScrollBuilder builder;

  CustomScrollWidget({
    Key? key,
    required this.controller,
    required this.builder,
  }) : super(key: key);

  @override
  State<CustomScrollWidget> createState() => _CustomScrollWidgetState();
}

class _CustomScrollWidgetState extends State<CustomScrollWidget> {
  @override
  void initState() {
    super.initState();
    widget.controller.onInitState(context);
    widget.controller.addListener(onScrollPropertyChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(onScrollPropertyChanged);
    widget.controller.onDispose();
    super.dispose();
  }

  void onScrollPropertyChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: widget.controller.onPointerSignal,
      onPointerDown: widget.controller.onPointerDown,
      onPointerUp: widget.controller.onPointerUp,
      onPointerCancel: widget.controller.onPointerCancel,
      onPointerMove: widget.controller.onPointerMove,
      onPointerHover: widget.controller.onPointerHover,
      onPointerPanZoomStart: widget.controller.onPointerPanZoomStart,
      onPointerPanZoomUpdate: widget.controller.onPointerPanZoomUpdate,
      onPointerPanZoomEnd: widget.controller.onPointerPanZoomEnd,
      child: LayoutBuilder(builder: (context, constraints) {
        return widget.builder.call(
            context,
            constraints,
            Offset(
              widget.controller.horizontalOffset,
              widget.controller.verticalOffset,
            ));
      }),
    );
  }
}

class CustomScrollController extends ChangeNotifier {
  double horizontalOffset = 0.0;
  double verticalOffset = 0.0;
  double contentWidth = 0.0;
  double contentHeight = 0.0;
  CustomScrollController? parent;
  List<CustomScrollController> children = [];

  void onPointerSignal(PointerSignalEvent event) {
    if (kDebugMode) {
      print("custom scroll onPointerSignal event: $event");
    }
  }

  void onPointerDown(PointerDownEvent event) {
    if (kDebugMode) {
      print("custom scroll onPointerDown event: $event");
    }
  }

  void onPointerUp(PointerUpEvent event) {
    if (kDebugMode) {
      print("custom scroll onPointerUp event: $event");
    }
  }

  void onPointerCancel(PointerCancelEvent event) {
    if (kDebugMode) {
      print("custom scroll onPointerCancel event: $event");
    }
  }

  void onPointerMove(PointerMoveEvent event) {
    if (kDebugMode) {
      print("custom scroll onPointerMove event: $event");
    }
  }

  void onPointerHover(PointerHoverEvent event) {
    if (kDebugMode) {
      // print("custom scroll onPointerHover event: $event");
    }
  }

  void onPointerPanZoomStart(PointerPanZoomStartEvent event) {
    if (kDebugMode) {
      print("custom scroll onPointerPanZoomStart event: $event");
    }
  }

  void onPointerPanZoomUpdate(PointerPanZoomUpdateEvent event) {
    if (kDebugMode) {
      print("custom scroll onPointerPanZoomUpdate event: $event");
    }
  }

  void onPointerPanZoomEnd(PointerPanZoomEndEvent event) {
    if (kDebugMode) {
      print("custom scroll onPointerPanZoomEnd event: $event");
    }
  }

  void onInitState(BuildContext context) {
    var parentWidget =
        context.findAncestorWidgetOfExactType<CustomScrollWidget>();
    if (parentWidget != null) {
      parentWidget.controller.children.add(this);
    }
  }

  void onDispose() {
    parent?.children.remove(this);
  }
}

typedef CustomScrollBuilder = Widget Function(
    BuildContext context, Constraints constraints, Offset scrollOffset);
