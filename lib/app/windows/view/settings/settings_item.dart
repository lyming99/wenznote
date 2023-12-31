import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:note/service/service_manager.dart';

import 'settings_controller.dart';

abstract class WinSettingsItem {
  String title;
  List<String> searchKeys;

  WinSettingsItem({
    required this.title,
    required this.searchKeys,
  });

  Widget buildPane(BuildContext context, String searchKey);

  bool containsKey(String searchKey) {
    if (searchKey.isEmpty) {
      return true;
    }
    return searchKeys.any((element) => element.contains(searchKey));
  }

  WinSettingsController get controller => Get.find();
}

class SettingsGroup {
  String name;
  Widget icon;
  List<WinSettingsItem> settingItems;

  SettingsGroup({
    required this.name,
    required this.icon,
    required this.settingItems,
  });

  bool containsKey(String searchKey) {
    if (searchKey.isEmpty) {
      return true;
    }
    if (name.contains(searchKey)) {
      return true;
    }
    return settingItems.any((element) => element.containsKey(searchKey));
  }
}

class ThemeSettingsItem extends WinSettingsItem {
  ThemeSettingsItem({
    super.title = "主题",
    super.searchKeys = const ["主题", "外观", "颜色", "浅色模式", "深色模式", "跟随系统"],
  });

  @override
  Widget buildPane(BuildContext context, String searchKey) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 20, left: 10, top: 10),
          child: const Text(
            "主题",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(
            bottom: 20,
            left: 10,
          ),
          child: buildDarkModeCheckBox(context),
        ),
      ],
    );
  }

  Widget buildDarkModeCheckBox(BuildContext context) {
    var settingsManager = ServiceManager.of(context).settingsManager;
    return ValueListenableBuilder<dynamic>(
        valueListenable: settingsManager.listenable(),
        builder: (context, box, widget) {
          var themeMode = settingsManager.getThemeMode();
          return Row(
            children: [
              Checkbox(
                  checked: themeMode == ThemeMode.light,
                  content: const Text("浅色模式"),
                  onChanged: (value) {
                    if (value == true) {
                      settingsManager.setThemeMode(ThemeMode.light);
                    }
                  }),
              const SizedBox(
                width: 10,
              ),
              Checkbox(
                  checked: ThemeMode.dark == themeMode,
                  content: const Text("深色模式(未适配)"),
                  onChanged: (value) {
                    if (value == true) {
                      settingsManager.setThemeMode(ThemeMode.dark);
                    }
                  }),
              const SizedBox(
                width: 10,
              ),
              Checkbox(
                  checked: ThemeMode.system == themeMode,
                  content: const Text("跟随系统"),
                  onChanged: (value) {
                    if (value == true) {
                      settingsManager.setThemeMode(ThemeMode.system);
                    }
                  }),
            ],
          );
        });
  }
}

class WindowSettingsItem extends WinSettingsItem {
  WindowSettingsItem({
    super.title = "标签",
    super.searchKeys = const [
      "单标签模式",
      "多标签模式",
    ],
  });

  @override
  Widget buildPane(BuildContext context, String searchKey) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 20, left: 10, top: 10),
          child: const Text(
            "标签",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(
            bottom: 20,
            left: 10,
          ),
          child: buildDarkModeCheckBox(context),
        ),
      ],
    );
  }

  Widget buildDarkModeCheckBox(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          checked: false,
          content: const Text("单标签模式"),
          onChanged: (value) {},
        ),
        const SizedBox(
          width: 10,
        ),
        Checkbox(
          checked: false,
          content: const Text("多标签模式"),
          onChanged: (value) {},
        ),
      ],
    );
  }
}
