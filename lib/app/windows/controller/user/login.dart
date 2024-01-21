import 'package:fluent_ui/fluent_ui.dart';
import 'package:note/commons/mvc/controller.dart';
import 'package:note/service/service_manager.dart';
import 'package:note/service/user/user_service.dart';

class WinLoginController extends MvcController {
  var usernameController = TextEditingController(text: "44185539@qq.com");
  var passwordController = TextEditingController(text: "999888777");
  late UserService userService;

  Future<bool> doLogin() async {
    return await userService.login(
        email: usernameController.text, password: passwordController.text);
  }

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    userService = ServiceManager.of(context).userService;
  }
}
