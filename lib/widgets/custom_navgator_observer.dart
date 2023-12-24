import 'package:flutter/material.dart';

class CustomNavigatorObserver extends NavigatorObserver {
  final Function(Route?)? onPush;
  final Function(Route?)? onPop;

  CustomNavigatorObserver({
    this.onPush,
    this.onPop,
  });

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    onPush?.call(previousRoute);
    onPop?.call(previousRoute);
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    onPush?.call(route);
    onPop?.call(previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    onPush?.call(newRoute);
    onPop?.call(oldRoute);
  }
  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    onPush?.call(previousRoute);
    onPop?.call(route);
  }
}
