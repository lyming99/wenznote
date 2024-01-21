import 'package:flutter/material.dart';
import 'package:note/commons/mvc/controller.dart';

typedef MvcBuilder<T> = Widget Function(T controller);

class MvcView<T extends MvcController> extends StatefulWidget {
  final T controller;
  final MvcBuilder<T>? builder;

  const MvcView({
    super.key,
    required this.controller,
    this.builder,
  });

  Widget build(BuildContext context) {
    return builder?.call(controller) ?? Container();
  }

  @override
  State<MvcView> createState() => _MvcViewState();
}

class _MvcViewState extends State<MvcView> with AutomaticKeepAliveClientMixin{
  @override
  void initState() {
    super.initState();
    widget.controller.onInitState(context);
    widget.controller.addListener(onChanged);
  }

  void onChanged() {
    if (context.mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(onChanged);
    widget.controller.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.controller.context = context;
    return widget.build(context);
  }

  @override
  void didUpdateWidget(covariant MvcView<MvcController> oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.controller.onDidUpdateWidget(context, oldWidget.controller);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  bool get wantKeepAlive => true;
}
