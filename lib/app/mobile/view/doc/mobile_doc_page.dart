import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wenznote/app/mobile/theme/mobile_theme.dart';
import 'package:wenznote/app/mobile/view/doc/mobile_doc_page_controller.dart';
import 'package:wenznote/app/mobile/view/doc/mobile_doc_page_model.dart';
import 'package:wenznote/app/mobile/view/user/mobile_user_icon.dart';
import 'package:wenznote/app/mobile/widgets/sticky_delegate.dart';
import 'package:wenznote/app/windows/view/card/win_create_card_dialog.dart';
import 'package:wenznote/app/windows/view/doc/win_select_doc_dir_dialog.dart';
import 'package:wenznote/commons/mvc/view.dart';
import 'package:wenznote/editor/widget/drop_menu.dart';
import 'package:wenznote/editor/widget/toggle_item.dart';
import 'package:wenznote/model/note/po/doc_dir_po.dart';
import 'package:wenznote/model/note/po/doc_po.dart';
import 'package:wenznote/service/search/search_result_vo.dart';

class MobileDocPage extends MvcView<MobileDocPageController> {
  const MobileDocPage({super.key, required super.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MobileTheme.of(context).mobileBgColor,
      child: CustomScrollView(
        controller: controller.scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          buildSliverAppBar(context),
          buildPathWidget(context),
          buildContent(context),
        ],
      ),
    );
  }

  SliverAppBar buildSliverAppBar(BuildContext context) {
    const appbarHeight = 48.0;
    const searchBarHeight = 56.0;
    return SliverAppBar(
      title: Text(
        "笔记",
        style: TextStyle(color: MobileTheme.of(context).fontColor),
      ),
      leading: IconButton(
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
        icon: MobileUserIcon(),
      ),
      actions: [
        fluent.Builder(builder: (context) {
          return IconButton(
              onPressed: () {
                showCreateMenu(context);
              },
              icon: Icon(
                Icons.add,
                size: 32,
              ));
        }),
      ],
      titleSpacing: 0,
      toolbarHeight: appbarHeight,
      backgroundColor: MobileTheme.of(context).mobileBgColor,
      shadowColor: Colors.transparent,
      foregroundColor: MobileTheme.of(context).fontColor,
      systemOverlayStyle: MobileTheme.overlayStyle(context),
      floating: true,
      snap: false,
      pinned: true,
      expandedHeight: appbarHeight + searchBarHeight,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 40,
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: MobileTheme.of(context).mobileContentBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: buildSearchEdit(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSearchEdit(BuildContext context) {
    return Obx(() {
      return TextField(
        focusNode: controller.searchFocusNode,
        cursorColor: MobileTheme.of(context).cursorColor,
        controller: controller.searchController,
        onTapOutside: (point) {
          controller.searchFocusNode.unfocus();
        },
        onChanged: (text) {
          controller.searchText.value = text;
          controller.doSearch();
        },
        style: TextStyle(
          height: 1,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          prefixIconConstraints: BoxConstraints(maxWidth: 40),
          suffixIconConstraints: BoxConstraints(maxWidth: 40),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: MobileTheme.of(context).fontColor.withOpacity(0.3),
            size: 24,
          ),
          suffixIcon: controller.searchText.isEmpty
              ? null
              : GestureDetector(
                  onTap: () {
                    controller.searchController.clear();
                    controller.searchFocusNode.unfocus();
                    controller.searchText.value = "";
                    controller.doSearch();
                  },
                  child: Icon(
                    Icons.highlight_remove_outlined,
                    color: MobileTheme.of(context).fontColor.withOpacity(0.3),
                    size: 18,
                  ),
                ),
          border: InputBorder.none,
          hintText: "搜索",
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          hintMaxLines: 1,
        ),
      );
    });
  }

  Widget buildPathWidget(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: StickyDelegate(
          child: PreferredSize(
        preferredSize: Size(double.infinity, 40),
        child: Container(
          color: MobileTheme.of(context).mobileBgColor,
          padding: EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(
                  Icons.folder,
                  color: Colors.grey,
                ),
              ),
              Expanded(
                child: Builder(builder: (context) {
                  return Obx(() {
                    return Align(
                      alignment: Alignment.centerLeft,
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
                            context,
                            (item.value as DocDirPO).uuid,
                          );
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
                }),
              ),
            ],
          ),
        ),
      )),
    );
  }

  Widget buildContent(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 16,
      ),
      sliver: Obx(
        () {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (controller.isSearchList) {
                  return buildSearchItem(
                    context,
                    controller.searchList,
                    index,
                  );
                }
                return buildDocItem(context, controller.modelList, index);
              },
              childCount: controller.isSearchList
                  ? controller.searchList.length
                  : controller.modelList.length,
            ),
          );
        },
      ),
    );
  }

  Widget buildSearchItem(
    BuildContext context,
    List<SearchResultVO> searchList,
    int index,
  ) {
    return Obx(() {
      var searchModel = searchList[index];
      return InkWell(
        onTap: () {
          var docModel = searchList[index];
          controller.openSearchItem(docModel);
        },
        child: Container(
          margin: const EdgeInsets.only(
            top: 6,
            bottom: 6,
          ),
          constraints: const BoxConstraints(
            maxHeight: 300,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              color: MobileTheme.of(context).bgColor3,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  searchModel.buildEditWidget(context),
                  Container(
                    height: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: MobileTheme.of(context).bgColor3,
                      boxShadow: [
                        BoxShadow(
                          color: MobileTheme.buildColor(context,
                              darkColor: Colors.black.withOpacity(0.2),
                              lightColor: Colors.grey.withOpacity(0.2))!,
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 40,
                    color: MobileTheme.of(context).bgColor3,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Text(
                          searchModel.getTypeTitle(),
                          style: TextStyle(
                            fontSize: 12,
                            color: MobileTheme.of(context)
                                .fontColor
                                .withOpacity(0.4),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            searchModel.getTimeString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: MobileTheme.of(context)
                                  .fontColor
                                  .withOpacity(0.4),
                            ),
                          ),
                        ),
                        Builder(builder: (context) {
                          return fluent.IconButton(
                            onPressed: () {
                              //显示菜单
                              showDropMenu(
                                context,
                                menus: [
                                  DropMenu(
                                    height: 48,
                                    icon: const Icon(
                                      Icons.copy,
                                    ),
                                    text: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: const Text("复制内容"),
                                    ),
                                    onPress: (context) {
                                      Navigator.of(context).pop();
                                      controller.copySearchItem(context, index);
                                    },
                                  ),
                                  if (searchModel.doc.type != "doc")
                                    DropMenu(
                                      height: 48,
                                      icon: const Icon(
                                        Icons.drive_file_move_outline,
                                      ),
                                      text: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: const Text("存到笔记"),
                                      ),
                                      onPress: (context) {
                                        Navigator.of(context).pop();
                                        controller.moveSearchItem(
                                            context, index);
                                      },
                                    ),
                                  DropMenu(
                                    height: 48,
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.redAccent,
                                    ),
                                    text: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: const Text(
                                        "删除",
                                        style:
                                            TextStyle(color: Colors.redAccent),
                                      ),
                                    ),
                                    onPress: (context) {
                                      Navigator.of(context).pop();
                                      controller.deleteSearchItem(
                                          context, index);
                                    },
                                  ),
                                ],
                                modal: true,
                              );
                            },
                            icon: const Icon(
                              Icons.more_horiz_outlined,
                              size: 16,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget buildDocItem(
      BuildContext context, List<MobileDocModel> modelList, int index) {
    var docItem = controller.modelList[index];
    bool isFolder = docItem.isFolder;
    return Obx(() {
      var selected = controller.selectItem.value == docItem.uuid;
      return ToggleItem(
        checked: selected,
        onTapDown: (ctx) {
          controller.selectItem.value = docItem.uuid;
        },
        onTap: (ctx) {
          controller.openDocOrDirectory(ctx, docItem);
          controller.selectItem.value = docItem.uuid;
        },
        onSecondaryTap: (ctx, details) {
          controller.selectItem.value = docItem.uuid;
          showDocItemDropMenu(ctx, details.globalPosition, docItem);
        },
        onLongPress: (ctx, details) {
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
            margin: EdgeInsets.symmetric(vertical: 10),
            height: 60,
            decoration: BoxDecoration(
              color: (hover || selected || pressed)
                  ? (Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade900
                      : Colors.grey.shade200)
                  : null,
              borderRadius: BorderRadius.circular(10),
            ),
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
                Text("${docItem.name ?? "未命名笔记"}"),
              ],
            ),
          );
        },
      );
    });
  }

  void showDocItemDropMenu(
      BuildContext context, Offset globalOffset, MobileDocModel docItem) {
    HapticFeedback.selectionClick();
    showMouseDropMenu(context, globalOffset & Size(4, 4),
        modal: true,
        childrenWidth: 200,
        childrenHeight: 48,
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
          if (docItem.isDoc)
            DropMenu(
              text: Text("制作卡片"),
              onPress: (ctx) {
                hideDropMenu(ctx);
                showCreateCardDialog(
                    context, docItem.value?.name ?? "新建卡片", [docItem]);
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

  void showCreateMenu(BuildContext context) {
    var editTheme = MobileTheme.of(context);
    showDropMenu(
      context,
      childrenWidth: 140,
      childrenHeight: 48,
      margin: 10,
      offset: const Offset(0, -10),
      modal: true,
      menus: [
        DropMenu(
          text: Row(
            children: [
              Text(
                "新建笔记",
                style: TextStyle(
                  color: editTheme.fontColor,
                ),
              ),
            ],
          ),
          onPress: (ctx) {
            hideDropMenu(ctx);
            controller.createDoc(context, "");
          },
        ),
        DropMenu(
          text: Row(
            children: [
              Text(
                "新建文件夹",
                style: TextStyle(
                  color: editTheme.fontColor,
                ),
              ),
            ],
          ),
          onPress: (ctx) {
            hideDropMenu(ctx);
            showCreateDialog(context, "新建文件夹", "", false);
          },
        ),
      ],
    );
  }

  void showCreateDialog(BuildContext context, String title, String placeHolder,
      bool isCreateDoc) {
    var textController = fluent.TextEditingController(text: "");
    void doCreate() {
      if (textController.text != "") {
        if (isCreateDoc) {
          controller.createDoc(context, textController.text);
        } else {
          controller.createDirectory(context, textController.text);
        }
      }
    }

    showDialog(
        useSafeArea: true,
        context: context,
        builder: (context) {
          return fluent.ContentDialog(
            title: fluent.Text(title),
            constraints: BoxConstraints(maxWidth: 300),
            content: fluent.Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                fluent.Container(
                  margin: const EdgeInsets.only(bottom: 10, top: 10),
                  child: fluent.TextBox(
                    placeholder: placeHolder,
                    controller: textController,
                    autofocus: true,
                    onSubmitted: (e) {
                      Navigator.pop(context, '确定');
                      doCreate();
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
                    doCreate();
                  },
                  child: const Text("确定")),
            ],
          );
        });
  }

  void showRenameDialog(BuildContext context, MobileDocModel docItem) {
    var textController = fluent.TextEditingController(text: docItem.name ?? "");
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
            constraints: const BoxConstraints(
              maxWidth: 300,
            ),
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

  void showMoveDialog(BuildContext context, List<MobileDocModel> list) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      builder: (context) {
        return SelectDocDirDialog(
          title: "移动到",
          actionLabel: "移动到此处",
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height*0.8,
          filter: (path) {
            return controller.canMoveToPath(list, path);
          },
          onSelect: (dir) {
            controller.moveToDir(dir, list);
          },
        );
      },
    );
  }

  void showCreateCardDialog(
      BuildContext context, String cardName, List<MobileDocModel> list) {
    showGenerateCardDialog(
        context, cardName, list.map((e) => e.value as DocPO).toList());
  }
}
