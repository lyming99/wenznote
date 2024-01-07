import 'package:flutter/material.dart';

class MvcController with ChangeNotifier {
  late BuildContext context;



  @mustCallSuper
  void onInitState(BuildContext context) {
    this.context = context;
  }

  @mustCallSuper
  void onDidUpdateWidget(BuildContext context, MvcController oldController) {
    this.context = context;
  }
  void onDispose() {}

  void onPause() {}
}
