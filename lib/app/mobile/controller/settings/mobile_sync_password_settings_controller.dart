import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:rich_clipboard/rich_clipboard.dart';
import 'package:wenznote/commons/mvc/controller.dart';
import 'package:wenznote/service/crypt/crypt_service.dart';
import 'package:wenznote/service/service_manager.dart';

class MobileSyncPasswordSettingsController extends ServiceManagerController {
  var pwdInput1Controller = TextEditingController();
  var pwdInput2Controller = TextEditingController();

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);

    fetchData();
  }

  Future<void> fetchData() async {}

  @override
  void onDidUpdateWidget(BuildContext context, MvcController oldController) {
    super.onDidUpdateWidget(context, oldController);
    if (oldController is MobileSyncPasswordSettingsController) {}
  }

  bool get hasPwd => serviceManager.cryptService.hasPassword();

  int? get pwdVersion =>
      serviceManager.cryptService.getCurrentPassword()?.version;

  String? get pwd => serviceManager.cryptService.getCurrentPassword()?.password;

  String? get pwdSha256 =>
      serviceManager.cryptService.getCurrentPassword()?.sha256;

  void copyPwd() {
    RichClipboard.setData(RichClipboardData( text: pwd??""));
    showToast("复制成功！");
  }

  String generateRandomPwd() {
    return serviceManager.cryptService.generateRandomPassword();
  }

  String generatePwd(String password) {
    return serviceManager.cryptService.generatePassword(password);
  }

  Future<bool> changePwd(String pwd) async{
    var ret = serviceManager.cryptService.changeServerPassword(pwd);
    await serviceManager.recordSyncService.reUploadDbData();
    return ret;
  }
}
