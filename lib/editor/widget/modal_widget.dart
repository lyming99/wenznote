import 'dart:async';

import 'package:flutter/widgets.dart';

class ModalController with ChangeNotifier {
  WidgetBuilder? modal;
  Completer? _completer;

  static ModalController? of(BuildContext context) {
    var container = context.findAncestorWidgetOfExactType<ModalContainer>();
    return container?.controller;
  }

  static ModalController? find(BuildContext context, String name) {
    ModalController? controller;
    context.visitAncestorElements((element) {
      var widget = element.widget;
      if (widget is ModalContainer) {
        if (widget.name == name) {
          controller = widget.controller;
          return false;
        }
      }
      return true;
    });
    return controller;
  }

  Future<T> showModal<T extends Object?>(WidgetBuilder? modal) {
    if (_completer != null) {
      pop();
    }
    this.modal = modal;
    notifyListeners();
    _completer = Completer();
    return _completer?.future as Future<T>;
  }

  void pop({Object? result}) {
    modal=null;
    notifyListeners();
    _completer?.complete(result);
    _completer = null;
  }
}

class ModalContainer extends StatefulWidget {
  ModalController controller;
  Widget child;
  String name;

  ModalContainer({
    Key? key,
    required this.controller,
    required this.child,
    this.name = "modalContainer",
  }) : super(key: key);

  @override
  State<ModalContainer> createState() => _ModalContainerState();
}

class _ModalContainerState extends State<ModalContainer> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(notifyListener);
  }

  void notifyListener() {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.removeListener(notifyListener);
  }

  @override
  Widget build(BuildContext context) {
    var modal = widget.controller.modal?.call(context);
    return Stack(
      children: [
        widget.child,
        if (modal != null) modal,
      ],
    );
  }
  @override
  void didUpdateWidget(covariant ModalContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
  }
}
