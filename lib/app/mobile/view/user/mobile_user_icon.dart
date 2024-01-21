import 'package:flutter/material.dart';
import 'package:wenznote/service/service_manager.dart';

class MobileUserIcon extends StatefulWidget {
  final double size;

  const MobileUserIcon({
    Key? key,
    this.size = 32,
  }) : super(key: key);

  @override
  State<MobileUserIcon> createState() => _MobileUserIconState();
}

class _MobileUserIconState extends State<MobileUserIcon> {
  @override
  void initState() {
    super.initState();
    ServiceManager.of(context).userService.addListener(onUserInfoChanged);
  }

  @override
  void dispose() {
    try {
      ServiceManager.of(context).userService.removeListener(onUserInfoChanged);
    } catch (e) {
      print(e);
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MobileUserIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    ServiceManager.of(context).userService.removeListener(onUserInfoChanged);
    ServiceManager.of(context).userService.addListener(onUserInfoChanged);
  }

  @override
  Widget build(BuildContext context) {
    return ServiceManager.of(context)
        .userService
        .buildUserIcon(context, widget.size);
  }

  void onUserInfoChanged() {
    try {
      setState(() {});
    } catch (e) {
    }
  }
}
