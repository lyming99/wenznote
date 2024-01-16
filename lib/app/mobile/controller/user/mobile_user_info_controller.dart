import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:note/service/service_manager.dart';

class MobileUserInfoController extends ServiceManagerController {
  var signInfoController = TextEditingController();
  var nicknameController = TextEditingController();

  var sign = "".obs;

  var username = "".obs;

  var email = "".obs;

  var userType = "普通用户".obs;

  var avatar = "".obs;

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    fetchData();
  }

  Future<void> fetchData() async {
    readUserInfo();
    await serviceManager.userService.fetchUserInfo();
    readUserInfo();
    await serviceManager.userService.downloadAvatar();
    readUserInfo();
  }

  Future<void> readUserInfo() async {
    var user = serviceManager.userService.currentUser;
    sign.value = signInfoController.text = user?.sign ?? "";
    username.value = nicknameController.text =
        user?.nickname ?? user?.username ?? user?.email ?? "";
    email.value = user?.email ?? "";
    avatar.value = await serviceManager.userService.getAvatarFile();
  }

  Widget getUserIcon() {
    return serviceManager.userService.buildUserIcon(context, 100);
  }

  void logout() async {
    await serviceManager.userService.logout();
    GoRouter.of(context).pop();
    await serviceManager.restartService();
    SchedulerBinding.instance.scheduleFrameCallback((timeStamp) {
      // GoRouter.of(context).go("/mobile/today");
    });
  }

  Future<void> selectUserIconImage() async {
    var result = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (result != null) {
      var crop = await ImageCropper().cropImage(
        sourcePath: result.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressFormat: ImageCompressFormat.jpg,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: "裁剪头像",
            lockAspectRatio: true,
            initAspectRatio: CropAspectRatioPreset.square,
          ),
          IOSUiSettings(
            title: "裁剪头像",
          ),
        ],
      );
      if (crop == null) {
        return;
      }
      await serviceManager.userService.updateAvatar(crop.path);
      fetchData();
    }
  }

  void updateSign() async {
    await serviceManager.userService.updateSign(signInfoController.text);
    sign.value = signInfoController.text;
  }

  void updateNickname() async {
    await serviceManager.userService.updateNickname(nicknameController.text);
    username.value = nicknameController.text;
  }
}
