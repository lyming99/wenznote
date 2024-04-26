import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wenznote/commons/mvc/controller.dart';
import 'package:wenznote/service/service_manager.dart';

const kMinimal = "minimal";
const kMedium = "medium";
const kMaximal = "maximal";

class MobileSettingsController extends ServiceManagerController {
  var brightness = "system".obs;
  var fontSize = "medium".obs;
  var savePath = "".obs;
  var savePathEditController = TextEditingController();

  String get brightnessString {
    if (brightness.value == "dark") {
      return "夜间模式";
    }
    if (brightness.value == "light") {
      return "日间模式";
    }
    return "跟随系统";
  }

  String get fontSizeString {
    if (fontSize.value == kMedium) {
      return "中";
    }
    if (fontSize.value == kMinimal) {
      return "小";
    }
    if (fontSize.value == kMaximal) {
      return "大";
    }
    return "中";
  }

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    brightness.listen((text) async {
      await serviceManager.configManager.saveConfig("system.brightness", text);
      await serviceManager.themeManager.readConfig();
    });
    fontSize.listen((text) async {
      await serviceManager.configManager.saveConfig("system.fontSize", text);
    });
    fetchData();
  }

  Future<void> fetchData() async {
    brightness.value = await serviceManager.configManager
        .readConfig("system.brightness", "system");
    fontSize.value = await serviceManager.configManager
        .readConfig("system.fontSize", "medium");
    var rootPath = await serviceManager.fileManager.getSaveDir();
    var path = File(rootPath).absolute.path;
    savePath.value = path;
  }

  @override
  void onDidUpdateWidget(BuildContext context, MvcController oldController) {
    super.onDidUpdateWidget(context, oldController);
    if (oldController is MobileSettingsController) {
      brightness = oldController.brightness;
      fontSize = oldController.fontSize;
      savePath = oldController.savePath;
      savePathEditController = oldController.savePathEditController;
    }
  }

  Future<void> changeSavePath(String path) async{
    await serviceManager.fileManager.setSaveDir(path);
    savePath.value = path;
  }
}
