import 'package:date_format/date_format.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';
import 'package:wenznote/app/mobile/controller/settings/mobile_settings_controller.dart';
import 'package:wenznote/app/windows/outline/outline_controller.dart';
import 'package:wenznote/app/windows/outline/outline_tree.dart';
import 'package:wenznote/app/windows/theme/colors.dart';
import 'package:wenznote/app/windows/view/card/win_create_card_dialog.dart';
import 'package:wenznote/app/windows/view/doc/win_select_doc_dir_dialog.dart';
import 'package:wenznote/app/windows/widgets/win_edit_tab.dart';
import 'package:wenznote/app/windows/widgets/win_tab_view.dart';
import 'package:wenznote/commons/mvc/view.dart';
import 'package:wenznote/commons/util/log_util.dart';
import 'package:wenznote/commons/widget/split_pane.dart';
import 'package:wenznote/editor/crdt/YsEditController.dart';
import 'package:wenznote/editor/crdt/YsTree.dart';
import 'package:wenznote/editor/edit_widget.dart';
import 'package:wenznote/editor/theme/theme.dart';
import 'package:wenznote/editor/widget/drop_menu.dart';
import 'package:wenznote/editor/widget/toggle_item.dart';
import 'package:wenznote/model/note/enum/note_order_type.dart';
import 'package:wenznote/model/note/enum/note_type.dart';
import 'package:wenznote/model/note/po/doc_dir_po.dart';
import 'package:wenznote/model/note/po/doc_po.dart';
import 'package:window_manager/window_manager.dart';
import 'package:ydart/ydart.dart';

class WinNoteEditTabController extends WinEditTabController {
  bool isCreateMode;
  DocPO doc;
  var title = "".obs;
  String firstCreatTitle = "";
  Function(YDoc content)? onUpdate;
  late YsEditController editController;

  YsTree? ysTree;

  var outlineController = OutlineController();
  var showOutline = false.obs;
  var editScale = 1.0;

  WinNoteEditTabController({
    required super.homeController,
    required this.doc,
    this.isCreateMode = false,
    this.onUpdate,
  }) {
    editController = YsEditController(
      copyService: homeController.serviceManager.copyService,
      fileManager: homeController.serviceManager.fileManager,
      initFocus: false,
      padding: const EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: 100,
      ),
      scrollController: ScrollController(),
      maxEditWidth: 1000,
    );
    editController.addListener(() {
      SchedulerBinding.instance.scheduleFrameCallback((timeStamp) {
        outlineController.updateTree(
            editController.viewContext, editController);
      });
    });
  }

  @override
  String get tabId => "doc-${doc.uuid}";

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    homeController.serviceManager.editService
        .addOpenedDocEditor(doc.uuid ?? "");
    homeController.serviceManager.configManager.addListener(onConfigChanged);
    fetchData();
  }

  @override
  void onDispose() {
    homeController.serviceManager.configManager.removeListener(onConfigChanged);
    homeController.serviceManager.editService
        .removeOpendDocEditor(doc.uuid ?? "");
    ysTree?.dispose();
  }

  void onConfigChanged() {
    readEditScale();
  }

  Future<void> fetchData() async {
    title.value = getDocTitle();
    await readEditScale();
    await readDoc();
  }

  Future<void> readEditScale() async {
    var fontSize = await homeController.serviceManager.configManager
        .readConfig("system.fontSize", kMedium);
    switch (fontSize) {
      case kMinimal:
        editScale = 1.4;
        break;
      case kMedium:
        editScale = 1.2;
        break;
      case kMaximal:
        editScale = 1.0;
        break;
    }
    notifyListeners();
  }

  Future<void> readDoc() async {
    var doc =
        await homeController.serviceManager.editService.readDoc(this.doc.uuid);
    if (doc != null) {
      editController.viewContext = context;
      ysTree = YsTree(
        context: context,
        editController: editController,
        yDoc: doc,
      );
      ysTree!.init();
      doc.updateV2['update'] = ((data, origin, transaction) {
        if (transaction.local != true) {
          return;
        }
        var editService = homeController.serviceManager.editService;
        onContentChanged(doc);
        var deltaData = data;
        editService.writeDoc(this.doc.uuid, doc);
        homeController.serviceManager.p2pService
            .sendDocEditMessage(this.doc.uuid ?? "", deltaData);
      });

      editController.waitLayout(() {
        editController.requestFocus();
      });
    }
  }

  void onContentChanged(YDoc content) async {
    onUpdate?.call(content);
  }

  String getDocTitle() {
    if (doc.type == NoteType.doc.name) {
      var name = doc.name;
      if (name == null || name.isEmpty) {
        return "无标题";
      }
      return name;
    }
    if (doc.type == NoteType.dayNote.name) {
      return "日记";
    }
    if (doc.type == NoteType.note.name) {
      return "便签";
    }
    return "";
  }

  void copyContent(BuildContext ctx) async {
    await homeController.serviceManager.copyService
        .copyWenElements(ctx, editController.blockManager.getWenElements());
    showToast(
      "复制成功",
      position: ToastPosition.bottom,
    );
  }

  void copyText(BuildContext ctx) async {
    await homeController.serviceManager.copyService.copyWenElements(
        ctx, editController.blockManager.getWenElements(), true);
    showToast(
      "复制成功",
      position: ToastPosition.bottom,
    );
  }

  void copyHtml(BuildContext ctx) {}

  void copyMarkdown(BuildContext ctx) async {
    await homeController.serviceManager.copyService
        .copyMarkdownContent(doc.uuid ?? "");
    showToast(
      "复制成功",
      position: ToastPosition.bottom,
    );
  }

  void deleteNote(BuildContext ctx) async {
    homeController.closeDoc(doc);

    await homeController.serviceManager.docService.deleteDoc(doc);
    await homeController.serviceManager.editService.deleteDocFile(doc.uuid!);
  }

  Future<void> moveToDocDir(DocDirPO dir) async {
    doc.name = getTitleString();
    doc.type = 'doc';
    doc.pid = dir.uuid;
    doc.updateTime = DateTime.now().millisecondsSinceEpoch;
    await homeController.serviceManager.docService.updateDoc(doc);
  }

  String getTitleString() {
    var content = editController.ysTree?.yDoc;
    if (content != null) {
      var blocks = content.getArray("blocks");
      for (var block in blocks.enumerateList()) {
        if (block is! YMap) {
          continue;
        }
        var type = block.get("level") ?? 0;
        if (type == 0) {
          continue;
        }
        var text = block.get("text");
        if (text is! YText) {
          continue;
        }
        var title = text.toString().trim();
        if (title.isEmpty) {
          continue;
        }
        return title;
      }
    }
    return "${getTypeTitle()} ${getTimeString(OrderProperty.updateTime)}";
  }

  String getTypeTitle() {
    switch (doc.type ?? "note") {
      case "note":
        return "便签";
      case "doc":
        return "笔记";
      case "dayNote":
        return "日记";
      default:
        return "便签";
    }
  }

  String getTimeString(OrderProperty value) {
    DateTime dateTime;
    if (value == OrderProperty.createTime) {
      var time = doc.createTime ?? 0;
      dateTime = DateTime.fromMillisecondsSinceEpoch(time);
    } else {
      var time = doc.updateTime ?? 0;
      dateTime = DateTime.fromMillisecondsSinceEpoch(time);
    }
    return formatDate(
        dateTime, [yyyy, "-", mm, "-", dd, " ", HH, ":", nn, ":", ss]);
  }

  void onRename(String text) {
    isCreateMode = false;
    title.value = text;
  }

  void syncNow(BuildContext ctx) async {
    printLog("手动同步笔记：${doc.uuid},${doc.name}");
    var serviceManager = homeController.serviceManager;
    await serviceManager.docSnapshotService.downloadDocFile(doc.uuid ?? "");
    await serviceManager.uploadTaskService.uploadDoc(doc.uuid ?? "", 0);
  }

  Future<String> getDocPath() async {
    var serviceManager = homeController.serviceManager;
    return serviceManager.fileManager.getNoteFilePath(doc.uuid ?? "");
  }
}

class WinNoteEditTab extends MvcView<WinNoteEditTabController> with Focusable {
  YDoc? docContent;
  var updateTime = 0.obs;

  WinNoteEditTab({super.key, required super.controller});

  @override
  WinNoteEditTabController get controller => super.controller!;

  DocPO get doc => controller.doc;

  @override
  void focus() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.editController.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildNav(context),
        Expanded(
          child: GestureDetector(
            onSecondaryTapDown: (event) {
              controller.editController.showContextMenu(event.localPosition);
            },
            child: Obx(() {
              var showOutline = controller.showOutline.value;
              var editWidget = _EditContent(
                controller: controller,
              );
              return Stack(
                children: [
                  LayoutBuilder(builder: (context, cons) {
                    if (cons.maxWidth >= 600 && showOutline) {
                      return SplitPane(
                        one: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: fluent.FluentTheme.of(context)
                                    .resources
                                    .cardStrokeColorDefaultSolid
                                    .withOpacity(0.1),
                              ),
                            ),
                          ),
                          child: editWidget,
                        ),
                        two: Container(
                          color: fluent.FluentTheme.of(context)
                              .resources
                              .solidBackgroundFillColorQuarternary,
                          child: OutlineTree(
                            controller: controller.outlineController,
                            itemHeight: 32,
                            iconSize: 32,
                            indentWidth: 24,
                          ),
                        ),
                        primaryIndex: PaneIndex.two,
                        primaryMinSize: 100,
                        subMinSize: 300,
                        primarySize: 240,
                      );
                    }
                    return editWidget;
                  }),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ListenableBuilder(
                      builder: (context, child) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8,
                          ),
                          child: Text(
                            "字数统计: ${controller.editController.textLength}",
                            style: TextStyle(
                              color: systemColor(context, "textLengthColor"),
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                      listenable: controller.editController,
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget buildNav(BuildContext context) {
    var theme = fluent.FluentTheme.of(context);
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: theme.resources.solidBackgroundFillColorTertiary,
        border: Border(
          bottom: BorderSide(
            color: fluent.FluentTheme.of(context)
                .resources
                .cardStrokeColorDefaultSolid
                .withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
              child: Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: DragToMoveArea(
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Obx(
                      () => Text(
                        "${controller.title.value}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )),

          if (kDebugMode)
            ToggleItem(
              itemBuilder: (BuildContext context, bool checked, bool hover,
                  bool pressed) {
                return Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Icon(
                    Icons.info_outline,
                    size: 22,
                    color: hover
                        ? theme.resources.textFillColorSecondary
                        : theme.resources.textFillColorSecondary
                            .withOpacity(0.8),
                  ),
                );
              },
              onTap: (ctx) {
                hideDropMenu(ctx);
                showDocId(ctx);
              },
            ),
          ToggleItem(
            itemBuilder:
                (BuildContext context, bool checked, bool hover, bool pressed) {
              return Container(
                padding: const EdgeInsets.all(10.0),
                child: Icon(
                  Icons.list_alt_outlined,
                  size: 22,
                  color: hover
                      ? theme.resources.textFillColorSecondary
                      : theme.resources.textFillColorSecondary.withOpacity(0.8),
                ),
              );
            },
            onTap: (ctx) {
              controller.showOutline.value = !controller.showOutline.isTrue;
            },
          ),
          // actio
          SizedBox(
            width: 4,
          ),
          // actions
          ToggleItem(
            itemBuilder:
                (BuildContext context, bool checked, bool hover, bool pressed) {
              return Container(
                padding: const EdgeInsets.all(10.0),
                child: Icon(
                  Icons.more_horiz_outlined,
                  size: 22,
                  color: hover
                      ? theme.resources.textFillColorSecondary
                      : theme.resources.textFillColorSecondary.withOpacity(0.8),
                ),
              );
            },
            onTap: (ctx) {
              showNoteItemContextMenu(ctx);
            },
          ),
          SizedBox(
            width: 4,
          ),
        ],
      ),
    );
  }

  void showNoteItemContextMenu(BuildContext context) {
    var editTheme = EditTheme.of(context);
    showDropMenu(context, childrenWidth: 150, menus: [
      DropMenu(
        text: Row(
          children: [
            Text(
              "立即同步",
              style: TextStyle(
                color: editTheme.fontColor,
              ),
            ),
          ],
        ),
        onPress: (ctx) {
          hideDropMenu(ctx);
          controller.syncNow(ctx);
        },
      ),
      DropMenu(
          text: Row(
            children: [
              Text(
                "复制全文",
                style: TextStyle(
                  color: editTheme.fontColor,
                ),
              ),
            ],
          ),
          onPress: (ctx) {
            hideDropMenu(ctx);
            controller.copyContent(ctx);
          },
          children: [
            DropMenu(
              text: Row(
                children: [
                  Text(
                    "复制富文本",
                    style: TextStyle(
                      color: editTheme.fontColor,
                    ),
                  ),
                ],
              ),
              onPress: (ctx) {
                hideDropMenu(ctx);
                controller.copyContent(ctx);
              },
            ),
            DropMenu(
              text: Row(
                children: [
                  Text(
                    "复制纯文本",
                    style: TextStyle(
                      color: editTheme.fontColor,
                    ),
                  ),
                ],
              ),
              onPress: (ctx) {
                hideDropMenu(ctx);
                controller.copyText(ctx);
              },
            ),
            DropMenu(
              text: Row(
                children: [
                  Text(
                    "复制 Markdown",
                    style: TextStyle(
                      color: editTheme.fontColor,
                    ),
                  ),
                ],
              ),
              onPress: (ctx) {
                hideDropMenu(ctx);
                controller.copyMarkdown(ctx);
              },
            ),
          ]),
      if (controller.doc.type != 'doc')
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
            showMoveToDocDialog(
              ctx,
            );
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
              context, controller.doc.name ?? "新建卡片", [controller.doc]);
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
          controller.deleteNote(ctx);
        },
      ),
    ]);
  }

  void showMoveToDocDialog(BuildContext ctx) {
    showDialog(
        context: ctx,
        builder: (context) {
          return SelectDocDirDialog(
            title: "存到",
            actionLabel: "存到这里",
            onSelect: (dir) {
              controller.moveToDocDir(dir);
            },
          );
        });
  }

  void showDocId(BuildContext ctx) async {
    var path = await controller.getDocPath();
    WidgetsBinding.instance.scheduleFrameCallback((timeStamp) {
      showDialog(
        context: ctx,
        builder: (ctx) {
          return fluent.ContentDialog(
            title: const Text("文件路径"),
            constraints: const BoxConstraints(
              maxHeight: 160,
              maxWidth: 300,
            ),
            content: fluent.TextBox(
              controller: TextEditingController(text: path),
            ),
          );
        },
      );
    });
  }
}

class _EditContent extends StatelessWidget {
  final WinNoteEditTabController controller;

  const _EditContent({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, cons) {
      var scale = controller.editScale;
      return FittedBox(
        child: SizedBox(
          width: cons.maxWidth * scale,
          height: cons.maxHeight * scale,
          child: EditWidget(
            controller: controller.editController,
          ),
        ),
      );
    });
  }
}
