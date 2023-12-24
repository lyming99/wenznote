import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

typedef MouseEventListener = Function(PointerEvent event, HitTestEntry? entry);

class MouseEventListenerWidget extends SingleChildRenderObjectWidget {
  HitTestBehavior? behavior;
  MouseEventListener? eventListener;

  MouseEventListenerWidget({
    this.behavior,
    this.eventListener,
    Key? key,
    Widget? child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _MyRenderMouseRegion(
      behavior: behavior,
      listener: eventListener,
      onEnter: (event) => eventListener?.call(event, null),
      onExit: (event) => eventListener?.call(event, null),
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderObject renderObject) {
    super.updateRenderObject(context, renderObject);
    if (renderObject is _MyRenderMouseRegion) {
      renderObject.listener = eventListener;
    }
  }
}

class _MyRenderMouseRegion extends RenderProxyBoxWithHitTestBehavior
    implements MouseTrackerAnnotation {
  MouseEventListener? listener;

  _MyRenderMouseRegion({
    behavior = HitTestBehavior.deferToChild,
    MouseCursor cursor = MouseCursor.defer,
    bool validForMouseTracker = true,
    this.onEnter,
    this.onExit,
    this.listener,
  })  : _cursor = cursor,
        _validForMouseTracker = validForMouseTracker,
        super(
          behavior: behavior,
        );

  @override
  MouseCursor get cursor => _cursor;
  MouseCursor _cursor;

  set cursor(MouseCursor value) {
    if (_cursor != value) {
      _cursor = value;
      markNeedsPaint();
    }
  }

  @override
  PointerEnterEventListener? onEnter;

  @override
  PointerExitEventListener? onExit;

  @override
  bool get validForMouseTracker => _validForMouseTracker;
  bool _validForMouseTracker;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _validForMouseTracker = true;
  }

  @override
  void detach() {
    _validForMouseTracker = false;
    super.detach();
  }

  HitTestResult? result;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    this.result = result;
    return super.hitTest(result, position: position);
  }

  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    listener?.call(event, entry);
  }
}
