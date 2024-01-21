import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note/app/windows/controller/doc/win_select_doc_dir_list_controller.dart';
import 'package:note/editor/theme/theme.dart';
import 'package:note/editor/widget/drop_menu.dart';
import 'package:note/editor/widget/toggle_item.dart';
import 'package:note/model/note/po/doc_dir_po.dart';

class WinSelectDocDirListView extends GetView<WinSelectDocDirListController> {
  @override
  final WinSelectDocDirListController controller;

  const WinSelectDocDirListView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: EditTheme.of(context).bgColor2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(
                    Icons.folder,
                    color: Colors.grey,
                  ),
                ),
                Expanded(child: buildPath(context)),
              ],
            ),
          ),
          Expanded(child: buildDocList(context)),
        ],
      ),
    );
  }

  Widget buildPath(BuildContext context) {
    return Obx(() {
      return Align(
        alignment: Alignment.topLeft,
        child: fluent.BreadcrumbBar(
          items: [
            for (var item in controller.pathList)
              fluent.BreadcrumbItem(
                label: Container(
                  constraints: BoxConstraints(maxWidth: 100),
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    item.name ?? "null",
                    maxLines: 1,
                    style: TextStyle(
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                value: item,
              ),
          ],
          onItemPressed: (item) {
            controller.openDirectory(
                context, (item.value as DocDirPO).uuid, true);
          },
          overflowButtonBuilder: (ctx, fly) {
            return ToggleItem(
              itemBuilder: (ctx, checked, hovered, pressed) {
                return Container(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    fluent.FluentIcons.more,
                    size: 14.0,
                  ),
                );
              },
              onTap: (ctx) {
                fluent.BreadcrumbBarState? state =
                    ctx.findAncestorStateOfType();
                if (state == null) {
                  return;
                }
                var indexes = state.overflowedIndexes;
                var items = state.widget.items;
                var overflowItems = <fluent.BreadcrumbItem>[];
                for (var value in indexes) {
                  var item = items[value];
                  overflowItems.add(item);
                }
                showDropMenu(ctx, modal: false, menus: [
                  for (var item in overflowItems)
                    DropMenu(
                      text: item.label,
                      icon: Icon(
                        Icons.folder,
                        color: Colors.grey,
                      ),
                      onPress: (ctx) {
                        hideDropMenu(ctx);
                        controller.openDirectory(
                          context,
                          (item.value as DocDirPO).uuid,
                          true,
                        );
                      },
                    ),
                ]);
              },
            );
          },
        ),
      );
    });
  }

  Widget buildDocList(BuildContext context) {
    return Obx(() {
      return ListView.builder(
        itemCount: controller.docList.length,
        itemBuilder: (context, index) {
          return buildDocItem(context, index);
        },
      );
    });
  }

  Widget buildDocItem(BuildContext context, int index) {
    var docItem = controller.docList[index];
    bool isFolder = docItem.isFolder;
    return Obx(() {
      var selected = controller.selectItem.value?.uuid == docItem.uuid;
      return ToggleItem(
        checked: selected,
        onTap: (ctx) {
          controller.openDocOrDirectory(ctx, docItem);
          controller.selectItem.value = docItem;
        },
        itemBuilder:
            (BuildContext context, bool checked, bool hover, bool pressed) {
          return Container(
            padding: EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 10,
            ),
            color: hover ? Colors.grey.shade100 : null,
            child: Row(
              children: [
                Icon(
                  isFolder ? Icons.folder : fluent.FluentIcons.edit_note,
                  size: 32,
                  color: isFolder ? Colors.orange : Colors.grey,
                ),
                SizedBox(
                  width: 10,
                ),
                Text("${docItem.name}"),
              ],
            ),
          );
        },
      );
    });
  }
}
