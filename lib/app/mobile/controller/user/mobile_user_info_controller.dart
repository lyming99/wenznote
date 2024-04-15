import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_cropping/image_cropping.dart' as cropping;
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:wenznote/service/service_manager.dart';
import 'package:wenznote/widgets/root_widget.dart';

// Import package

class MobileUserInfoController extends ServiceManagerController {
  var signInfoController = TextEditingController();
  var nicknameController = TextEditingController();
  var ckeyEditController = TextEditingController();
  var sign = "".obs;

  var username = "".obs;

  var email = "".obs;

  var userType = "普通用户".obs;

  var avatar = "".obs;

  var vipLimitTime = "已到期".obs;

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
    vipLimitTime.value = serviceManager.userService.getVipInfo();
  }

  Widget getUserIcon() {
    return serviceManager.userService.buildUserIcon(context, 100);
  }

  void logout() async {
    await serviceManager.userService.logout();
    SchedulerBinding.instance.scheduleFrameCallback((timeStamp) {
      ServiceManagerWidgetState.of(context).restart();
    });
  }

  Future<String?> pickImage() async {
    var result = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (result != null) {
      return result.path;
    }
    return null;
  }

  Future<String?> cropImage(String path) async {
    if (Platform.isWindows) {
      final croppedBytes = await cropping.ImageCropping.cropImage(
        context: context,
        imageBytes: await File(path).readAsBytes(),
        onImageStartLoading: () {},
        onImageEndLoading: () {},
        onImageDoneListener: (data) {},
        visibleOtherAspectRatios: false,
        squareBorderWidth: 2,
        selectedImageRatio:
            const cropping.CropAspectRatio(ratioX: 1, ratioY: 1),
        squareCircleColor: Colors.black,
        defaultTextColor: Colors.orange,
        selectedTextColor: Colors.black,
        colorForWhiteSpace: Colors.grey,
        encodingQuality: 80,
        outputImageFormat: cropping.OutputImageFormat.jpg,
        workerPath: 'crop_worker.js',
      );
      if (croppedBytes == null) {
        return null;
      }
      var dir = await serviceManager.fileManager.getDownloadDir();
      var saveFile = File("$dir/${const Uuid().v1()}.jpg");
      await saveFile.writeAsBytes(croppedBytes);
      return saveFile.path;
    }
    var crop = await ImageCropper().cropImage(
      sourcePath: path,
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
    return crop?.path;
  }

  Future<void> selectUserIconImage() async {
    var path = await pickImage();
    if (path != null) {
      String? cropPath = await cropImage(path);
      if (cropPath == null) {
        return;
      }
      await serviceManager.userService.updateAvatar(cropPath);
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

  Future<bool> recharge() async {
    try {
      return await serviceManager.userService
          .cKeyRecharge(ckeyEditController.text);
    } finally {
      vipLimitTime.value = serviceManager.userService.getVipInfo();
    }
  }
}
