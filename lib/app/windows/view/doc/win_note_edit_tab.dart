import 'package:date_format/date_format.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_crdt/flutter_crdt.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';
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
import 'package:wenznote/service/task/task.dart';
import 'package:window_manager/window_manager.dart';

class WinNoteEditTabController extends WinEditTabController {
  DocPO doc;
  bool isCreateMode;
  var title = "".obs;
  String firstCreatTitle = "";
  Function(Doc content)? onUpdate;
  late YsEditController editController;

  YsTree? tree;

  var outlineController = OutlineController();
  var showOutline = false.obs;

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
    title.value = getDocTitle();
    readDoc();
  }

  Future<void> readDoc() async {
    var doc =
        await homeController.serviceManager.editService.readDoc(this.doc.uuid);
    if (doc != null) {
      editController.viewContext = context;
      tree = YsTree(
        context: context,
        editController: editController,
        yDoc: doc,
      );
      tree!.init();
      doc.on("update", (args) async {
        onContentChanged(doc);
        var data = args[0];
        if (homeController.serviceManager.editService
            .isInUpdateCache(this.doc.uuid ?? "", data)) {
          return;
        }
        await homeController.serviceManager.editService
            .writeDoc(this.doc.uuid, doc);
        homeController.serviceManager.p2pService
            .sendDocEditMessage(this.doc.uuid ?? "", data);
      });
      editController.waitLayout(() {
        editController.requestFocus();
      });
    }
  }

  void onContentChanged(Doc content) async {
    if (isCreateMode) {
      await TaskService.instance.executeTask(
          taskGroup: "createModeQueue",
          task: () async {
            var docName = await homeController.serviceManager.docService
                .getDocName(doc.id);
            if (firstCreatTitle != docName) {
              isCreateMode = false;
            } else {
              var blocks = editController.ysTree?.blocks;
              if (blocks != null && blocks.length == 1) {
                var text = blocks[0].yMap.get("text");
                if (text is YText) {
                  var name = text.toString();
                  if (name.length > 20) {
                    name = name.substring(0, 20);
                  }
                  doc.name = name;
                  firstCreatTitle = name;
                  title.value = getDocTitle();
                }
              }
            }
          });
    }
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
      for (var block in blocks) {
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

  void sync(BuildContext ctx) {
    printLog("手动同步笔记：${doc.uuid},${doc.name}");
    homeController.serviceManager.docSnapshotService
        .downloadDocFile(doc.uuid ?? "");
  }
}

class WinNoteEditTab extends MvcView<WinNoteEditTabController> with Focusable {
  Doc? docContent;
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
              var editWidget = EditWidget(
                controller: controller.editController,
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
                        primaryMinSize: 300,
                        subMinSize: 300,
                        primarySize: 300,
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
          controller.sync(ctx);
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
}
