import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note/app/windows/controller/doc_list/win_doc_list_controller.dart';
import 'package:note/app/windows/controller/home/win_home_controller.dart';
import 'package:note/app/windows/model/doc_list/win_doc_list_item_vo.dart';
import 'package:note/app/windows/model/today/search_result_vo.dart';
import 'package:note/app/windows/view/card/win_create_card_dialog.dart';
import 'package:note/app/windows/view/doc_list/win_select_doc_dir_dialog.dart';
import 'package:note/app/windows/view/export/win_export_dialog.dart';
import 'package:note/editor/theme/theme.dart';
import 'package:note/editor/widget/drop_menu.dart';
import 'package:note/editor/widget/toggle_item.dart';
import 'package:note/model/note/po/doc_dir_po.dart';

class WinDocListView extends GetView<WinDocListController> {
  @override
  final WinDocListController controller;

  const WinDocListView({
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
      if (controller.searchText.isNotEmpty) {
        return buildSearchResultList(context);
      }
      return ListView.builder(
        itemCount: controller.docList.length,
        itemBuilder: (context, index) {
          return buildDocItem(context, index);
        },
        padding: const EdgeInsets.only(
          bottom: 50,
        ),
      );
    });
  }

  Widget buildDocItem(BuildContext context, int index) {
    var docItem = controller.docList[index];
    bool isFolder = docItem.isFolder;
    return Obx(() {
      var selected = controller.selectItem.value == docItem.uuid;
      return ToggleItem(
        checked: selected,
        onTap: (ctx) {
          controller.openDocOrDirectory(ctx, docItem);
          controller.selectItem.value = docItem.uuid;
        },
        onSecondaryTap: (ctx, details) {
          controller.selectItem.value = docItem.uuid;
          showDocItemDropMenu(ctx, details.globalPosition, docItem);
        },
        itemBuilder:
            (BuildContext context, bool checked, bool hover, bool pressed) {
          return Container(
            padding: EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 10,
            ),
            color: hover || selected ? Colors.grey.shade100 : null,
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

  void showDocItemDropMenu(
      BuildContext context, Offset globalOffset, WinDocListItemVO docItem) {
    showMouseDropMenu(context, globalOffset & Size(4, 4),
        childrenWidth: 150,
        menus: [
          DropMenu(
            text: Text("打开"),
            onPress: (ctx) {
              hideDropMenu(ctx);
              controller.openDocOrDirectory(context, docItem);
            },
          ),
          DropMenu(
            text: Text("重命名"),
            onPress: (ctx) {
              hideDropMenu(ctx);
              showRenameDialog(context, docItem);
            },
          ),
          DropMenu(
            text: Text("移动到"),
            onPress: (ctx) {
              hideDropMenu(ctx);
              showMoveDialog(context, [docItem]);
            },
          ),
          DropMenu(
            text: Text("制作卡片"),
            onPress: (ctx) {
              hideDropMenu(ctx);
              showCreateCardDialog(
                  context, docItem.doc?.name ?? "新建卡片", [docItem]);
            },
          ),
          DropSplit(),
          DropMenu(
            text: Text("删除"),
            onPress: (ctx) {
              hideDropMenu(ctx);
              if (docItem.isFolder) {
                controller.deleteFolder(docItem);
              } else {
                controller.deleteDoc(docItem);
              }
            },
          ),
        ]);
  }

  void showRenameDialog(BuildContext context, WinDocListItemVO docItem) {
    var textController = fluent.TextEditingController(text: "${docItem.name}");
    void doUpdate() {
      if (textController.text != "") {
        controller.updateDocItemName(context, docItem, textController.text);
      }
    }

    showDialog(
        useSafeArea: true,
        context: context,
        builder: (context) {
          return fluent.ContentDialog(
            title: fluent.Text(docItem.isFolder ? "重命名" : "重命名"),
            content: fluent.Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                fluent.Container(
                  margin: const EdgeInsets.only(bottom: 10, top: 10),
                  child: fluent.TextBox(
                    placeholder: "请输入名称",
                    controller: textController,
                    autofocus: true,
                    onSubmitted: (e) {
                      Navigator.pop(context, '确定');
                      doUpdate();
                    },
                  ),
                ),
              ],
            ),
            actions: [
              fluent.Button(
                child: const Text('取消'),
                onPressed: () {
                  Navigator.pop(context, '取消');
                  // Delete file here
                },
              ),
              fluent.FilledButton(
                  onPressed: () {
                    Navigator.pop(context, '确定');
                    doUpdate();
                  },
                  child: const Text("确定")),
            ],
          );
        });
  }

  void showMoveDialog(BuildContext context, List<WinDocListItemVO> list) {
    showDialog(
        context: context,
        builder: (context) {
          return SelectDocDirDialog(
            title: "移动到",
            actionLabel: "移动到此处",
            filter: (path) {
              return controller.canMoveToPath(list, path);
            },
            onSelect: (dir) {
              controller.moveToDir(dir, list);
            },
          );
        });
  }

  void showCreateCardDialog(
      BuildContext context, String cardName, List<WinDocListItemVO> list) {
    showGenerateCardDialog(context, cardName, list.map((e) => e.doc!).toList());
  }

  void showExportDialog(BuildContext context, List<WinDocListItemVO> list) {}

  Widget buildSearchResultList(BuildContext context) {
    // return GridView.builder(
    //   itemCount: controller.searchResultList.length,
    //   gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
    //     maxCrossAxisExtent: 500,
    //     mainAxisExtent: 200,
    //   ),
    //   itemBuilder: (context, index) {
    //     // return controller.searchResultList[index].buildEditWidget(context);
    //     return buildSearchItem(context, index);
    //   },
    // );
    return ListView.builder(
      itemBuilder: (context, index) {
        return buildSearchItem(context, index);
      },
      itemCount: controller.searchResultList.length,
    );
  }

  Widget buildSearchItem(BuildContext context, int index) {
    var searchItem = controller.searchResultList[index];
    var currentEditor = Get.find<WinHomeController>().currentNoteEditor;
    return Obx(() {
      var editor = currentEditor.value;
      var isCurrentEditor = editor?.doc.uuid == searchItem.doc.uuid;
      if (isCurrentEditor && editor != null) {
        return ListenableBuilder(
          listenable: editor,
          builder: (context, widget) {
            if (editor.docContent != null) {
              searchItem.updateContent(editor.docContent);
            }
            return buildNoteContent(context, searchItem, isCurrentEditor,
                searchItem.buildEditWidget(context));
          },
        );
      }
      return buildNoteContent(
        context,
        searchItem,
        isCurrentEditor,
        searchItem.buildEditWidget(context),
      );
    });
  }

  Widget buildNoteContent(
      BuildContext context,
      WinTodaySearchResultVO searchItem,
      bool isCurrentEditor,
      Widget editWidget) {
    return Column(
      children: [
        ToggleItem(
          onTap: (ctx) {
            controller.openDoc(context, searchItem.doc);
          },
          onSecondaryTap: (ctx, event) {
            showNoteItemContextMenu(context, searchItem, event.globalPosition);
          },
          itemBuilder:
              (BuildContext context, bool checked, bool hover, bool pressed) {
            return Container(
              height: 180,
              margin: EdgeInsets.only(
                top: 5,
                bottom: 5,
                left: 10,
                right: 10,
              ),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: EditTheme.of(context).fontColor.withOpacity(0.1),
                    blurRadius: 1,
                    spreadRadius: 1,
                  ),
                ],
                borderRadius: BorderRadius.circular(4),
                color: isCurrentEditor
                    ? Colors.white
                    : (hover
                        ? EditTheme.of(context).bgColor3.withOpacity(0.8)
                        : EditTheme.of(context).bgColor3),
              ),
              clipBehavior: Clip.antiAlias,
              child: Container(
                color: isCurrentEditor ? Colors.orange.withOpacity(0.1) : null,
                child: Column(
                  children: [
                    Expanded(child: IgnorePointer(child: editWidget)),
                    buildNoteTitleInfo(context, searchItem),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget buildNoteTitleInfo(
      BuildContext context, WinTodaySearchResultVO searchItem) {
    return Container(
      margin: EdgeInsets.only(
        left: 5,
        right: 5,
        top: 5,
        bottom: 5,
      ),
      child: Row(
        children: [
          Text(
            "${searchItem.getTypeTitle()} ",
            style: TextStyle(
              fontSize: 12,
              color: EditTheme.of(context).fontColor.withOpacity(0.4),
            ),
          ),
          Expanded(child: Container()),
          Text(
            searchItem.getTimeString(),
            style: TextStyle(
              fontSize: 12,
              color: EditTheme.of(context).fontColor.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  void showNoteItemContextMenu(BuildContext context,
      WinTodaySearchResultVO searchItem, Offset globalPosition) {
    var editTheme = EditTheme.of(context);
    var anchorRect = globalPosition & const Size(1, 1);
    showMouseDropMenu(context, anchorRect, childrenWidth: 150, menus: [
      DropMenu(
        text: Row(
          children: [
            Text(
              "打开",
              style: TextStyle(
                color: editTheme.fontColor,
              ),
            ),
          ],
        ),
        onPress: (ctx) {
          hideDropMenu(ctx);
        },
      ),
      DropMenu(
        text: Row(
          children: [
            Text(
              "复制内容",
              style: TextStyle(
                color: editTheme.fontColor,
              ),
            ),
          ],
        ),
        onPress: (ctx) {
          hideDropMenu(ctx);
          controller.copyContent(ctx, searchItem);
        },
      ),
      if (searchItem.doc.type != 'doc')
        DropMenu(
          text: Row(
            children: [
              Text(
                "存到笔记",
                style: TextStyle(
                  color: editTheme.fontColor,
                ),
              ),
            ],
          ),
          onPress: (ctx) {
            hideDropMenu(ctx);
            showMoveToDocDialog(ctx, searchItem);
          },
        ),
      DropMenu(
        text: Row(
          children: [
            Text(
              "制作卡片",
              style: TextStyle(
                color: editTheme.fontColor,
              ),
            ),
          ],
        ),
        onPress: (ctx) {
          hideDropMenu(ctx);
          showGenerateCardDialog(
              context, searchItem.doc.name ?? "新建卡片", [searchItem.doc]);
        },
      ),
      DropSplit(),
      DropMenu(
        text: Row(
          children: [
            Text(
              "删除",
              style: TextStyle(
                color: editTheme.fontColor,
              ),
            ),
          ],
        ),
        onPress: (ctx) {
          hideDropMenu(ctx);
          controller.deleteNote(searchItem);
        },
      ),
    ]);
  }

  void showMoveToDocDialog(
      BuildContext ctx, WinTodaySearchResultVO searchItem) {
    showDialog(
        context: ctx,
        builder: (context) {
          return SelectDocDirDialog(
            title: "存到",
            actionLabel: "存到这里",
            onSelect: (dir) {
              controller.moveToDocDir(searchItem, dir);
            },
          );
        });
  }
}
