import 'package:hive/hive.dart';
import 'package:note/service/service_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigManager {
  ServiceManager serviceManager;

  ConfigManager(this.serviceManager);

  Future<String> readConfig(String key, String defaultValue) async {
    var box = await Hive.openBox("settings");
    return box.get(key,defaultValue: defaultValue);
  }

  Future<void> saveConfig(String key, String value) async {
    var box = await Hive.openBox("settings");
    return box.put(key, value);
  }
}
