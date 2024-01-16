import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note/service/service_manager.dart';

class MobileSettingsController extends ServiceManagerController {
  var brightness = "system".obs;
  var fontSize = "medium".obs;

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
    if (fontSize.value == "medium") {
      return "中";
    }
    if (fontSize.value == "minimal") {
      return "小";
    }
    if (fontSize.value == "maximal") {
      return "大";
    }
    return "中";
  }

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    brightness.listen((text) async{
      await serviceManager.configManager.saveConfig("system.brightness", text);
      await serviceManager.themeManager.readConfig();
    });
    fontSize.listen((text) async{
      await serviceManager.configManager.saveConfig("system.fontSize", text);
    });
    fetchData();
  }

  Future<void> fetchData() async {
    brightness.value = await serviceManager.configManager
        .readConfig("system.brightness", "system");
    fontSize.value = await serviceManager.configManager
        .readConfig("system.fontSize", "medium");
  }
}
