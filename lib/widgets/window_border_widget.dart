import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../commons/service/device_utils.dart';

class WindowBorderWidget extends StatefulWidget {
  final Widget child;
  final Brightness brightness;

  const WindowBorderWidget({
    Key? key,
    required this.brightness,
    required this.child,
  }) : super(key: key);

  @override
  State<WindowBorderWidget> createState() => _WindowBorderWidgetsState();
}

class _WindowBorderWidgetsState extends State<WindowBorderWidget>
    with WindowListener {
  bool isFullScreen = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    super.dispose();
    windowManager.removeListener(this);
  }

  @override
  void onWindowEnterFullScreen() {
    super.onWindowEnterFullScreen();
    setState(() {
      isFullScreen = true;
    });
  }

  @override
  void onWindowLeaveFullScreen() {
    super.onWindowLeaveFullScreen();
    setState(() {
      isFullScreen = false;
    });
  }

  @override
  void onWindowRestore() {
    super.onWindowRestore();
    setState(() {
      isFullScreen = false;
    });
  }

  @override
  void onWindowMaximize() {
    super.onWindowMaximize();
    setState(() {
      isFullScreen = true;
    });
  }

  @override
  void onWindowUnmaximize() {
    super.onWindowUnmaximize();
    setState(() {
      isFullScreen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isFullScreen || !isCustomWindowBorder()) {
      return DragToResizeArea(
        resizeEdgeSize: 2,
        child: widget.child,
      );
    } else {
      return DragToResizeArea(
        resizeEdgeMargin: EdgeInsets.all(2),
        resizeEdgeSize: 6,
        child: Container(
          margin: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: widget.brightness == Brightness.dark
                ? Colors.black
                : Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 2,
                // blurStyle: BlurStyle.outer,
                color: widget.brightness == Brightness.dark
                    ? Color.fromARGB(150, 0, 0, 0)
                    : Color.fromARGB(150, 0, 0, 0),
              ),
            ],
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          width: double.infinity,
          height: double.infinity,
          child: widget.child,
        ),
      );
    }
  }
}
