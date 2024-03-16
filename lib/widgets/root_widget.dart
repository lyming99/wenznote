import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:wenznote/service/service_manager.dart';

class ServiceManagerWidget extends StatefulWidget {
  final WidgetBuilder builder;
  final GoRouter router;

  const ServiceManagerWidget({
    super.key,
    required this.builder,
    required this.router,
  });

  @override
  State<ServiceManagerWidget> createState() => ServiceManagerWidgetState();
}

class ServiceManagerWidgetState extends State<ServiceManagerWidget> {
  ServiceManager serviceManager = ServiceManager();

  static ServiceManagerWidgetState of(BuildContext context) {
    return context.findAncestorStateOfType<ServiceManagerWidgetState>()!;
  }

  @override
  void initState() {
    super.initState();
    serviceManager.addListener(onServiceChanged);
    serviceManager.init();
    serviceManager.startService();
  }

  void onServiceChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    serviceManager.removeListener(onServiceChanged);
    serviceManager.stopService();
  }

  void restart() async {
    var router = widget.router;
    while (router.canPop()) {
      router.pop();
    }
    serviceManager.removeListener(onServiceChanged);
    await serviceManager.stopService();
    setState(() {});
    await 300.milliseconds.delay();
    setState(() {
      serviceManager = ServiceManager();
      serviceManager.addListener(onServiceChanged);
      serviceManager.init();
      serviceManager.startService().then((value) {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!serviceManager.isStart) {
      return const Material(
        child: Center(
          child: RefreshProgressIndicator(),
        ),
      );
    }
    return Builder(builder: (context) {
      return widget.builder.call(context);
    });
  }

  @override
  void didUpdateWidget(covariant ServiceManagerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void changeUser(String userId) {
    print('on user changed:$userId');
  }
}
