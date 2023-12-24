import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note/app/windows/controller/card/win_card_set_controller.dart';
import 'package:note/app/windows/model/card/win_card_set_item_vo.dart';
import 'package:note/editor/widget/drop_menu.dart';
import 'package:note/editor/widget/toggle_item.dart';

class WinCardSetPage extends GetView<WinCardSetController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 30),
      child: Column(
        children: [
          buildSearch(context),
          Expanded(child: buildContent(context)),
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

  Widget buildAddButton(BuildContext context) {
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
            showCreateDialog(context, "创建卡片集", "");
          },
        ),
      );
    });
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
          return fluent.ContentDialog(
            title: fluent.Text(title),
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

  Widget buildContent(BuildContext context) {
    return buildCardSetList(context);
  }

  Widget buildCardSetList(BuildContext context) {
    return Obx(() {
      return ListView.builder(
        padding: EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 10,
        ),
        itemCount: controller.cardSetList.length,
        itemBuilder: (context, index) {
          return buildCardSetItem(context, controller.cardSetList[index]);
        },
      );
    });
  }

  Widget buildCardSetItem(BuildContext context, WinCardSetItemVO cardSetItem) {
    var color = cardSetItem.color.withOpacity(0.8);
    return ToggleItem(
      onTap: (context) {
        controller.openCardSet(context, cardSetItem);
      },
      onSecondaryTap: (context, event) {
        showCardSetItemMenu(context, event.globalPosition, cardSetItem);
      },
      itemBuilder:
          (BuildContext context, bool checked, bool hover, bool pressed) {
        return Container(
          height: 150,
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
  }

  void showCardSetItemMenu(BuildContext context, Offset globalPosition,
      WinCardSetItemVO cardSetItem) {
    showMouseDropMenu(context, globalPosition & const Size(4, 4), menus: [
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
      DropSplit(),
      DropMenu(
        text: Text("删除"),
        onPress: (ctx) {
          hideDropMenu(ctx);
          controller.deleteCardSet(cardSetItem);
        },
      ),
    ]);
  }

  void showRenameCardSetDialog(
      BuildContext context, WinCardSetItemVO cardSetItem) {
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
          return fluent.ContentDialog(
            title: Text("重命名"),
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
}
