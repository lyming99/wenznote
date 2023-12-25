import 'package:note/service/service_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigManager {
  ServiceManager serviceManager;

  ConfigManager(this.serviceManager);

  Future<String> readConfig(String key, String defaultValue) async {
    var pre = await SharedPreferences.getInstance();
    return pre.getString(key) ?? defaultValue;
  }

  Future<void> saveConfig(String key, String value) async {
    var pre = await SharedPreferences.getInstance();
    await pre.setString(key, value);
  }
}
