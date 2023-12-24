import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

class ThemeSettings with ChangeNotifier implements ValueListenable {
  static ThemeSettings? _instance;

  static ThemeSettings get instance {
    _instance ??= ThemeSettings._internal();
    return _instance!;
  }

  ThemeSettings._internal();

  @override
  get value => this;

  void setThemeMode(ThemeMode mode) {
    if (mode == ThemeMode.light) {
      saveConfig("themeMode", "light");
    } else if (mode == ThemeMode.dark) {
      saveConfig("themeMode", "dark");
    } else {
      saveConfig("themeMode", "system");
    }
    notifyListeners();
  }

  ThemeMode getThemeMode() {
    var mode = readConfig("themeMode", "light");
    switch (mode) {
      case "light":
        return ThemeMode.light;
      case "dark":
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Brightness getBrightness() {
    var mode = getThemeMode();
    switch (mode) {
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.light:
        return Brightness.light;
      default:
        return WidgetsBinding.instance.window.platformBrightness;
    }
  }

  void saveConfig(String key, String value) {}

  String readConfig(String key, String defaultValue) {
    return "";
  }
}
