import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:note/commons/mvc/controller.dart';
import 'package:note/service/service_manager.dart';
import 'package:note/service/user/user_service.dart';

class WinSignController extends MvcController {
  var usernameController = TextEditingController();
  var codeController = TextEditingController();
  var password1Controller = TextEditingController();
  var password2Controller = TextEditingController();
  late UserService userService;

  var sendEnable = true.obs;

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    userService = ServiceManager.of(context).userService;
  }

  Future<bool> doSign() async {
    return userService.sign(
        usernameController.text, codeController.text, password1Controller.text);
  }

  Future<bool> sendCode() async {
    return userService.sendSignCode(usernameController.text);
  }
}
