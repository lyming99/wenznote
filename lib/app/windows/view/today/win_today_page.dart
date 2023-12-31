import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note/app/windows/controller/home/win_home_controller.dart';
import 'package:note/app/windows/model/today/search_result_vo.dart';
import 'package:note/app/windows/view/card/win_create_card_dialog.dart';
import 'package:note/app/windows/view/doc_list/win_select_doc_dir_dialog.dart';
import 'package:note/editor/theme/theme.dart';
import 'package:note/editor/widget/drop_menu.dart';
import 'package:note/editor/widget/toggle_item.dart';
import 'package:note/model/note/enum/note_type.dart';
import 'package:note/widgets/ticker_widget.dart';

import '../../controller/today/win_today_controller.dart';

class WinTodayPage extends GetView<WinTodayController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 30),
      child: Column(
        children: [
          buildSearch(context),
          buildFilterBar(context),
          Expanded(child: buildNoteList(context)),
        ],
      ),
    );
  }

  Widget buildSearch(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: 10,
        left: 10,
        right: 10,
      ),
      child: Row(
        children: [
          Expanded(child: buildSearchEdit(context)),
          buildAddButton(context),
        ],
      ),
    );
  }

  Widget buildSearchEdit(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Obx(
        () => fluent.TextBox(
          placeholder: "搜索",
          controller: controller.searchController,
          onChanged: (v) {
            controller.searchContent.value = v;
          },
          prefix: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Icon(Icons.search),
          ),
          suffix: controller.searchContent.value.isEmpty
              ? null
              : ToggleItem(
                  onTap: (ctx) {
                    controller.searchController.clear();
                    controller.searchContent.value = "";
                  },
                  itemBuilder: (BuildContext context, bool checked, bool hover,
                      bool pressed) {
                    return Container(
                      color: hover ? Colors.grey.withOpacity(0.1) : null,
                      child: Icon(Icons.close),
                    );
                  },
                ),
        ),
      ),
    );
  }

  buildAddButton(BuildContext context) {
    return Builder(builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: fluent.IconButton(
          icon: const Icon(
            Icons.add,
            size: 22,
          ),
          onPressed: () {
            // 创建笔记按钮
            controller.createNote();
          },
        ),
      );
    });
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

  Widget buildFilterBar(BuildContext context) {
    return Container(
      height: 24,
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: SingleTickerWidget(builder: (context) {
        var tabController = controller.createTabController(context);
        controller.tabBarController = tabController;
        return Material(
          color: Colors.transparent,
          child: Align(
            alignment: Alignment.topLeft,
            child: TabBar(
              controller: controller.tabBarController,
              labelColor: Colors.black87,
              labelPadding: EdgeInsets.symmetric(horizontal: 10),
              isScrollable: true,
              onTap: (index) {
                switch (index) {
                  case 0:
                    controller.noteType.value = [
                      NoteType.note,
                      NoteType.doc,
                      NoteType.dayNote,
                    ];
                    break;
                  case 1:
                    controller.noteType.value = [
                      NoteType.note,
                    ];
                    break;
                  case 2:
                    controller.noteType.value = [
                      NoteType.doc,
                    ];
                    break;
                  case 3:
                    controller.noteType.value = [
                      NoteType.open,
                    ];
                    break;
                }
              },
              tabs: [
                Tab(
                  text: "全部",
                ),
                Tab(
                  text: "便签",
                ),
                Tab(
                  text: "笔记",
                ),
                Tab(
                  text: "已打开",
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  buildNoteList(BuildContext context) {
    return Obx(
      () => ListView.builder(
        padding: EdgeInsets.only(
          top: 5,
          bottom: 5,
        ),
        itemCount: controller.searchResultList.length,
        itemBuilder: (context, index) {
          return buildNoteItem(context, index);
        },
      ),
    );
  }

  buildNoteItem(BuildContext context, int index) {
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
      return buildNoteContent(context, searchItem, isCurrentEditor,
          searchItem.buildEditWidget(context));
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
            controller.openDoc(searchItem.doc);
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
            searchItem.getTimeString(controller.orderProperty.value),
            style: TextStyle(
              fontSize: 12,
              color: EditTheme.of(context).fontColor.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
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
