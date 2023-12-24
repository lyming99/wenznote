import 'package:fluent_ui/fluent_ui.dart';

class MvcController with ChangeNotifier {
  late BuildContext context;

  /// 加载state
  @mustCallSuper
  void onInitState(BuildContext context) {
    this.context = context;
  }

  void onDispose() {}

  /// 进入后台
  void onPause() {}
}
