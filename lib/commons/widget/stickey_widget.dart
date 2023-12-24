import 'package:flutter/material.dart';

class StickyWidgetDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  StickyWidgetDelegate({
    required this.child,
    required this.height,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return PreferredSize(
      preferredSize: Size(double.infinity, height),
      child: child,
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
