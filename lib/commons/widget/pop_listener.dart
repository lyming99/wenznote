import 'package:flutter/material.dart';

// 从上一个界面返回
class DidPopNextListener extends StatefulWidget {
  final VoidCallback? onPopNext;
  final Widget child;

  const DidPopNextListener({
    Key? key,
    required this.child,
    this.onPopNext,
  }) : super(key: key);

  @override
  State<DidPopNextListener> createState() => _DidPopNextListenerState();
}

class _DidPopNextListenerState extends State<DidPopNextListener>
    with RouteAware {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void didPopNext() {
    super.didPopNext();
    widget.onPopNext?.call();
  }

  @override
  void dispose() {
    super.dispose();
    RouterListener.routeObserver.unsubscribe(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var router = ModalRoute.of(context);
    RouterListener.routeObserver.subscribe(this, router!);
  }
}

class RouterListener {
  static final RouteObserver routeObserver = RouteObserver();
}
