import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'settings_item.dart';

class WinSettingsController extends GetxController {
  List<WinSettingsItem> items = [];
  List<SettingsGroup> allGroups = [
    SettingsGroup(
      name: "外观",
      icon: const Icon(
        Icons.color_lens_outlined,
      ),
      settingItems: [
        ThemeSettingsItem(),
      ],
    ),
    SettingsGroup(
      name: "快捷键",
      icon: const Icon(
        Icons.keyboard_command_key,
      ),
      settingItems: [],
    ),
    SettingsGroup(
      name: "账号安全",
      icon: const Icon(
        Icons.safety_check_outlined,
      ),
      settingItems: [],
    ),
    SettingsGroup(
      name: "其它",
      icon: const Icon(
        Icons.settings,
      ),
      settingItems: [],
    ),
  ];
  var searchGroups = <SettingsGroup>[].obs;
  var searchController = TextEditingController();
  var selectIndex = 0.obs;
  var searchText = "".obs;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchText.value = searchController.text;
      selectIndex.value = 0;
      searchGroups.value = allGroups
          .where((element) => element.containsKey(searchController.text))
          .toList();
    });
    searchGroups.value = allGroups;
  }
}
