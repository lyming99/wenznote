import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wenznote/app/windows/controller/doc/win_doc_list_controller.dart';
import 'package:wenznote/app/windows/controller/doc/win_doc_page_controller.dart';
import 'package:wenznote/app/windows/view/doc/win_doc_list_view.dart';
import 'package:wenznote/commons/mvc/view.dart';
import 'package:wenznote/editor/theme/theme.dart';
import 'package:wenznote/editor/widget/drop_menu.dart';
import 'package:wenznote/editor/widget/toggle_item.dart';
import 'package:wenznote/widgets/custom_navgator_observer.dart';

class WinDocPage extends MvcView<WinDocPageController> {
  const WinDocPage({super.key, required super.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        top: 32,
      ),
      child: Column(
        children: [
          buildSearch(context),
          Expanded(
            child: buildDocList(context),
          ),
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
    return Obx(
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
            showCreateMenu(context);
          },
        ),
      );
    });
  }

  void showCreateMenu(BuildContext context) {
    var editTheme = EditTheme.of(context);
    showDropMenu(
      context,
      childrenWidth: 140,
      childrenHeight: 40,
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
            showCreateDialog(context, "新建笔记", "请输入笔记名称", true);
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
            showCreateDialog(context, "新建文件夹", "请输入文件夹名称", false);
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

  Widget buildDocList(BuildContext context) {
    return Navigator(
      key: const ValueKey(1),
      initialRoute: "/",
      observers: [
        CustomNavigatorObserver(
          onPush: (route) {
            controller.onPushRoute(route);
            controller.docListController =
                controller.docListControllerMap[route?.settings.name ?? "/"];
          },
          onPop: (route) {
            controller.onPopRoute(route);
          },
        ),
      ],
      onGenerateRoute: (settings) {
        var controller = WinDocListController(
          docDirUuid: settings.name == "/" || settings.name == ""
              ? null
              : settings.name,
          docPageController: this.controller,
        );
        this.controller.docListControllerMap[settings.name ?? "/"] = controller;
        return PageRouteBuilder(
            settings: settings,
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
            pageBuilder: (context, animation, animationSecond) {
              this.controller.docListController = controller;
              return WinDocListView(controller: controller);
            });
      },
    );
  }
}
