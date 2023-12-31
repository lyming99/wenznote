import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:note/model/settings/settings_po.dart';
import 'package:note/service/isar/isar_service_mixin.dart';
import 'package:note/service/service_manager.dart';

class SettingsManager with IsarServiceMixin implements ValueListenable {
  @override
  ServiceManager serviceManager;
  var listeners = <VoidCallback>[];

  SettingsManager(this.serviceManager);

  String readConfig(String key, String defaultValue) {
    var config =
        documentIsar.settingsPOs.filter().keyEqualTo(key).findFirstSync();
    return config?.value ?? defaultValue;
  }

  void saveConfig(String key, String value) {
    var config =
        documentIsar.settingsPOs.filter().keyEqualTo(key).findFirstSync();
    config ??= SettingsPO(key: key, value: value);
    config.value = value;
    documentIsar.writeTxn(() => documentIsar.settingsPOs.put(config!));
  }

  void setThemeMode(ThemeMode mode) {
    if (mode == ThemeMode.light) {
      saveConfig("themeMode", "light");
    } else if (mode == ThemeMode.dark) {
      saveConfig("themeMode", "dark");
    } else {
      saveConfig("themeMode", "system");
    }
    notifyChildrens();
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

  ValueListenable listenable() {
    return this;
  }

  @override
  get value => this;

  @override
  void addListener(VoidCallback listener) {
    listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    listeners.remove(listener);
  }

  void notifyChildrens() {
    for (var value in listeners) {
      value.call();
    }
  }
}
