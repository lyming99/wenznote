import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note/app/windows/controller/home/win_home_controller.dart';
import 'package:note/commons/widget/split_pane.dart';
import 'package:note/editor/theme/theme.dart';
import 'package:note/editor/widget/toggle_item.dart';
import 'package:note/editor/widget/window_button.dart';
import 'package:window_manager/window_manager.dart';

import 'settings_controller.dart';

class WinSettingsWidget extends GetView<WinSettingsController> {
  const WinSettingsWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          buildTitlePane(context),
          Expanded(child: buildContentPane(context)),
        ],
      ),
    );
  }

  Widget buildTitlePane(BuildContext context) {
    return Container(
      height: 30,
      // color: Colors.white,
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
        color: EditTheme.of(context).lineColor,
      ))),
      child: Stack(
        children: [
          DragToMoveArea(
            child: Container(),
          ),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Builder(builder: (context) {
                      return WindowUserButton(
                        onPressed: () {
                          Get.find<WinHomeController>().closeTab("settings");
                        },
                        icon: const Icon(Icons.arrow_back),
                      );
                    }),
                    Expanded(
                        child: DragToMoveArea(
                      child: Text(
                        "设置",
                        style: TextStyle(
                          color: EditTheme.of(context).fontColor,
                          fontFamily: "MiSans",
                          fontSize: 16,
                        ),
                      ),
                    )),
                  ],
                ),
              ),
              // const WindowButtons(),
            ],
          )
        ],
      ),
    );
  }

  Widget buildContentPane(BuildContext context) {
    return SplitPane(
      one: buildNavPane(context),
      two: buildSettingsPane(context),
      primaryMinSize: 100,
      primarySize: 200,
      subMinSize: 100,
    );
  }

  Widget buildSearchBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: fluent.TextBox(
        controller: controller.searchController,
        placeholder: "",
        autofocus: true,
        prefix: fluent.Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            child: const Icon(
              Icons.search,
              size: 16,
              color: Colors.grey,
            )),
        prefixMode: fluent.OverlayVisibilityMode.always,
        padding: const EdgeInsets.symmetric(
          vertical: 0,
          horizontal: 0,
        ),
        style: const TextStyle(fontFamily: "MiSans", fontSize: 14),
        placeholderStyle: const TextStyle(fontSize: 14, fontFamily: "MiSans"),
        suffix: Obx(
          () => Row(mainAxisSize: MainAxisSize.min, children: [
            if (controller.searchText.isNotEmpty)
              GestureDetector(
                child: MouseRegion(
                  cursor: MaterialStateMouseCursor.clickable,
                  child: fluent.Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 6),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                      )),
                ),
                onTap: () {
                  controller.searchController.clear();
                },
              ),
          ]),
        ),
      ),
    );
  }

  Widget buildNavPane(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border(
              right: BorderSide(
        color: EditTheme.of(context).lineColor,
      ))),
      child: Column(
        children: [
          buildSearchBox(context),
          Expanded(
              child: Obx(
            () => ListView.builder(
              padding: EdgeInsets.only(),
              itemCount: controller.searchGroups.length,
              itemBuilder: (context, index) {
                return Obx(() {
                  var group = controller.searchGroups[index];
                  var checked = index == controller.selectIndex.value &&
                      controller.searchController.text.isEmpty;
                  return ToggleItem(
                    checked: checked,
                    onTap: (ctx) {
                      controller.selectIndex.value = index;
                    },
                    itemBuilder: (BuildContext context, bool checked,
                        bool hover, bool pressed) {
                      return Container(
                        decoration: BoxDecoration(
                          color: checked
                              ? EditTheme.of(context).treeItemSelectColor
                              : (hover
                                  ? EditTheme.of(context).treeItemHoverColor
                                  : null),
                        ),
                        child: ListTile(
                          leading: group.icon,
                          title: Text(group.name),
                        ),
                      );
                    },
                  );
                });
              },
            ),
          )),
        ],
      ),
    );
  }

  Widget buildEmptyPane(BuildContext context) {
    return const Center(
      child: Text("配置项为空~"),
    );
  }

  Widget buildSettingsPane(BuildContext context) {
    return Obx(() {
      var groups = controller.searchGroups;
      var index = controller.selectIndex;
      if (index >= groups.length) {
        return buildEmptyPane(context);
      }
      String groupName = groups[index.value].name;
      var searchKey = controller.searchController.text;
      var settingItems = groups[index.value]
          .settingItems
          .where((element) => element.containsKey(searchKey))
          .toList();
      return Builder(builder: (context) {
        if (settingItems.isEmpty) {
          return buildEmptyPane(context);
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          itemBuilder: (context, index) {
            return settingItems[index].buildPane(context, searchKey);
          },
          itemCount: settingItems.length,
        );
      });
    });
  }
}
