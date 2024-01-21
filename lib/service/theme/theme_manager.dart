import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wenznote/service/service_manager.dart';

class ThemeManager {
  ServiceManager serviceManager;

  ThemeManager(this.serviceManager);

  var themeMode = ThemeMode.system.obs;

  Future<void> readConfig() async {
    var mode = await serviceManager.configManager
        .readConfig("system.brightness", "system");
    if (mode == "system") {
      themeMode.value = ThemeMode.system;
    }
    if (mode == "dark") {
      themeMode.value = ThemeMode.dark;
    }
    if (mode == "light") {
      themeMode.value = ThemeMode.light;
    }
  }

  Brightness getBrightness() {
    var mode = themeMode.value;
    switch (mode) {
      case ThemeMode.dark:
        return Brightness.dark;
      default:
        return Brightness.light;
    }
  }
}
