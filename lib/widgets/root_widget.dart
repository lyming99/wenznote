import 'package:flutter/material.dart';
import 'package:wenznote/service/service_manager.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

class ServiceManagerWidget extends StatefulWidget {
  final WidgetBuilder builder;

  const ServiceManagerWidget({super.key, required this.builder});

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
    serviceManager.onInitState(context);
    serviceManager.addListener(onServiceChanged);
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

  @override
  Widget build(BuildContext context) {
    serviceManager.context=context;
    if (!serviceManager.isStart) {
      return const  Center(
        child: RefreshProgressIndicator(),
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
