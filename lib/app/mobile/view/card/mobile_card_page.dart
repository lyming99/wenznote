import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:wenznote/app/mobile/theme/mobile_theme.dart';
import 'package:wenznote/app/mobile/view/card/mobile_card_page_model.dart';
import 'package:wenznote/app/mobile/widgets/sticky_delegate.dart';
import 'package:wenznote/commons/mvc/view.dart';
import 'package:wenznote/editor/widget/drop_menu.dart';
import 'package:wenznote/editor/widget/toggle_item.dart';

import '../user/mobile_user_icon.dart';
import 'mobile_card_page_controller.dart';

class MobileCardPage extends MvcView<MobileCardPageController> {
  const MobileCardPage({super.key, required super.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MobileTheme.of(context).mobileBgColor,
      child: CustomScrollView(
        controller: controller.scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          buildSliverAppBar(context),
          buildFilterWidget(context),
          buildContent(context),
        ],
      ),
    );
  }

  SliverAppBar buildSliverAppBar(BuildContext context) {
    const appbarHeight = 48.0;
    const searchBarHeight = 56.0;
    return SliverAppBar(
      surfaceTintColor: Colors.transparent,
      title: Text(
        "卡片",
        style: TextStyle(color: MobileTheme.of(context).fontColor,fontSize: 18),
      ),
      leading: IconButton(
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
        icon: MobileUserIcon(),
      ),
      actions: [
        IconButton(
            onPressed: () {
              showCreateCardDialog(context);
            },
            icon: Icon(
              Icons.add,
              size: 32,
            )),
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
    return Obx(
      () => TextField(
        cursorColor: MobileTheme.of(context).cursorColor,
        controller: controller.searchController,
        focusNode: controller.searchFocusNode,
        onTapOutside: (point) {
          controller.searchFocusNode.unfocus();
        },
        onChanged: (text) {
          controller.searchText.value = text;
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
                    controller.searchText.value = "";
                    controller.searchController.clear();
                    controller.searchFocusNode.unfocus();
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
      ),
    );
  }

  Widget buildFilterWidget(BuildContext context) {
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
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: fluent.BreadcrumbBar(
                      items: [
                        fluent.BreadcrumbItem(
                          label: Container(
                            constraints: BoxConstraints(maxWidth: 100),
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              "我的卡片",
                              maxLines: 1,
                              style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          value: "我的卡片",
                        ),
                      ],
                      onItemPressed: (item) {},
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
                                  },
                                ),
                            ]);
                          },
                        );
                      },
                    ),
                  );
                }),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    controller.fetchData();
                  },
                  child: Container(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.refresh_outlined)),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }

  SliverPadding buildContent(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 16,
      ),
      sliver: Obx(
        () {
          var modelList = controller.modelList;
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return buildCardItem(
                  context,
                  modelList,
                  index,
                );
              },
              childCount: modelList.length,
            ),
          );
        },
      ),
    );
  }

  Widget buildCardItem(
    BuildContext context,
    List<MobileCardModel> modelList,
    int index,
  ) {
    return Obx(() {
      var cardSetItem = modelList[index];
      var color = cardSetItem.color.withOpacity(0.8);
      if (Theme.of(context).brightness == Brightness.dark) {
        var trans = 0.5;
        var blue = (color.blue * trans).toInt();
        var red = (color.red * trans).toInt();
        var green = (color.green * trans).toInt();
        color = Color.fromARGB(color.alpha, red, green, blue);
      }
      return ToggleItem(
        onTap: (context) {
          controller.openCardSet(context, cardSetItem);
        },
        onSecondaryTap: (context, event) {
          showCardSetItemMenu(context, event.globalPosition, cardSetItem);
        },
        onLongPress: (context, event) {
          showCardSetItemMenu(context, event.globalPosition, cardSetItem);
        },
        itemBuilder:
            (BuildContext context, bool checked, bool hover, bool pressed) {
          return Container(
            height: 240,
            margin: EdgeInsets.symmetric(
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: hover ? color.withOpacity(1) : color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "${cardSetItem.title}",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: "微软雅黑",
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text(
                          "今日学习",
                          style: TextStyle(
                            fontFamily: "微软雅黑",
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Text(
                          "${cardSetItem.todayStudyCount}",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontFamily: "微软雅黑",
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          "/${cardSetItem.todayStudyQueueCount}",
                          style: TextStyle(
                            fontFamily: "微软雅黑",
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          "待复习",
                          style: TextStyle(
                            fontFamily: "微软雅黑",
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Text(
                          "${cardSetItem.reviewCount}",
                          style: TextStyle(
                            color: Colors.green,
                            fontFamily: "微软雅黑",
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  void showCreateCardDialog(BuildContext context) {
    showCreateDialog(context, "创建卡片集", "请输入卡片集合名称");
  }

  void showCreateDialog(
      BuildContext context, String title, String placeHolder) {
    var textController = fluent.TextEditingController(text: "");
    void doCreate() {
      var name = textController.text.trim();
      if (name.isEmpty) {
        return;
      }
      controller.createCardSet(name);
    }

    showDialog(
        useSafeArea: true,
        context: context,
        builder: (context) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: fluent.ContentDialog(
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
            ),
          );
        });
  }

  void showCardSetItemMenu(BuildContext context, Offset globalPosition,
      MobileCardModel cardSetItem) {
    HapticFeedback.selectionClick();
    showMouseDropMenu(
      context,
      globalPosition & const Size(4, 4),
      childrenHeight: 48,
      menus: [
        DropMenu(
          text: Text("打开"),
          onPress: (ctx) {
            hideDropMenu(ctx);
            controller.openCardSet(context, cardSetItem);
          },
        ),
        DropMenu(
          text: Text("重命名"),
          onPress: (ctx) {
            hideDropMenu(ctx);
            showRenameCardSetDialog(context, cardSetItem);
          },
        ),
        DropMenu(
          text: Text("删除"),
          onPress: (ctx) {
            hideDropMenu(ctx);
            controller.deleteCardSet(cardSetItem);
          },
        ),
      ],
    );
  }

  void showRenameCardSetDialog(
      BuildContext context, MobileCardModel cardSetItem) {
    var textController =
        fluent.TextEditingController(text: "${cardSetItem.title}");
    void doUpdate() {
      var trim = textController.text.trim();
      if (trim.isNotEmpty) {
        controller.renameCardSet(cardSetItem, trim);
      }
    }

    showDialog(
        useSafeArea: true,
        context: context,
        builder: (context) {
          return fluent.Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: fluent.ContentDialog(
              title: Text("重命名"),
              constraints: BoxConstraints(maxWidth: 300),
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
            ),
          );
        });
  }
}
