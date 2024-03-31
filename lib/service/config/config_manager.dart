import 'package:fluent_ui/fluent_ui.dart';
import 'package:hive/hive.dart';
import 'package:wenznote/service/service_manager.dart';

class ConfigManager with ChangeNotifier{
  ServiceManager serviceManager;

  ConfigManager(this.serviceManager);

  Future<String> readConfig(String key, String defaultValue) async {
    var box = await Hive.openBox("settings");
    return box.get(key,defaultValue: defaultValue);
  }

  Future<void> saveConfig(String key, String value) async {
    try {
      var box = await Hive.openBox("settings");
      return box.put(key, value);
    } finally {
      notifyListeners();
    }
  }
}
