import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'settings_item.dart';

class SettingsController extends GetxController {
  List<SettingsItem> items = [];
  List<SettingsGroup> allGroups = [
    SettingsGroup(
      name: "外观",
      icon: const Icon(
        Icons.color_lens_outlined,
      ),
      settingItems: [
        ThemeSettingsItem(),
        WindowSettingsItem(),
      ],
    ),
    SettingsGroup(
      name: "通用",
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
