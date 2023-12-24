import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SystemThemeListener extends StatefulWidget {
  Widget child;

  SystemThemeListener({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<SystemThemeListener> createState() => _SystemThemeListenerState();
}

class _SystemThemeListenerState extends State<SystemThemeListener>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    Hive.box("settings").put("systemDarkMode",
        WidgetsBinding.instance.window.platformBrightness == Brightness.dark);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
