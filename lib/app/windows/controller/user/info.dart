import 'package:fluent_ui/fluent_ui.dart';
import 'package:wenznote/commons/mvc/controller.dart';
import 'package:wenznote/service/service_manager.dart';
import 'package:wenznote/service/user/user_service.dart';

class WinUserInfoController extends MvcController {
  var usernameController = TextEditingController();
  var passwordController = TextEditingController();
  late UserService userService;

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    userService = ServiceManager.of(context).userService;
  }

  String getUserName() {
    return userService.currentUser?.email ?? "";
  }

  void logout(BuildContext context) async {
    await userService.logout();
  }
}
