import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oktoast/oktoast.dart';
import 'package:wenznote/app/mobile/theme/mobile_theme.dart';
import 'package:wenznote/app/windows/outline/outline_tree.dart';
import 'package:wenznote/app/windows/view/card/win_create_card_dialog.dart';
import 'package:wenznote/commons/mvc/view.dart';
import 'package:wenznote/editor/edit_controller.dart';
import 'package:wenznote/editor/edit_widget.dart';
import 'package:wenznote/editor/widget/drop_menu.dart';
import 'package:wenznote/editor/widget/toggle_item.dart' as custom;

import '../../widgets/inner_darawer.dart';
import 'doc_edit_controller.dart';

class MobileDocEditWidget extends MvcView<MobileDocEditController> {
  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    if (controller.isShowBottomPane.isTrue &&
        keyboardHeight > controller.keyboardHeightRecord.value &&
        keyboardHeight >= controller.keyboardHeight.value) {
      controller.isShowBottomPane.value = false;
    }
    controller.keyboardHeightRecord.value = keyboardHeight;
    if (controller.hiderAppbar) {
      return Material(
        child: buildEditContentBody(context),
      );
    }
    return OKToast(
      child: Material(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            surfaceTintColor: Colors.transparent,
            title: Obx(() {
              return Text(controller.title.value);
            }),
            titleSpacing: 0,
            leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.arrow_back,
                  size: 24,
                )),
            toolbarHeight: 56,
            backgroundColor: MobileTheme.of(context).mobileNavBgColor,
            shadowColor: Colors.transparent,
            foregroundColor: MobileTheme.of(context).fontColor,
            systemOverlayStyle: MobileTheme.overlayStyle(context),
            actions: [
              if (keyboardHeight > 10)
                Obx(() {
                  return IconButton(
                    enableFeedback: true,
                    onPressed: controller.canUndo.isFalse
                        ? null
                        : () {
                            controller.editController.undo();
                          },
                    icon: Icon(
                      Icons.undo,
                      size: 24,
                    ),
                  );
                }),
              if (keyboardHeight > 10)
                Obx(
                  () {
                    return IconButton(
                      enableFeedback: true,
                      onPressed: controller.canRedo.isFalse
                          ? null
                          : () {
                              controller.editController.redo();
                            },
                      icon: Icon(
                        Icons.redo,
                        size: 24,
                      ),
                    );
                  },
                ),
              Builder(builder: (context) {
                return IconButton(
                  enableFeedback: true,
                  onPressed: () {
                    showMoreContextMenu(context);
                  },
                  icon: Icon(
                    Icons.more_vert_outlined,
                    size: 24,
                  ),
                );
              })
            ],
          ),
          body: buildEditContentBody(context),
        ),
      ),
    );
  }

  const MobileDocEditWidget({super.key, required super.controller});

  SelectDragListener buildEditContentBody(fluent.BuildContext context) {
    return SelectDragListener(
      onStatusChanged: () {
        controller.drawSwipeEnable.value =
            !controller.editController.isFloatWidgetDragging;
      },
      child: Obx(() {
        return InnerDrawer(
          onTapClose: true,
          boxShadow: const [],
          onDragUpdate: (val, dir) {
            controller.editController.inputManager.closeInputMethod();
          },
          // default false
          swipe: controller.showOutline && controller.drawSwipeEnable.isTrue,
          swipeChild: true,
          offset: const IDOffset.horizontal(0.4),
          // colorTransitionChild: Colors.transparent,
          // colorTransitionScaffold: Colors.transparent,
          //When setting the vertical offset, be sure to use only top or bottom
          colorTransitionChild: Colors.transparent,
          // default Color.black54
          colorTransitionScaffold: Colors.black54,
          proportionalChildArea: true,
          // default true
          borderRadius: 0,
          // default 0
          leftAnimationType: InnerDrawerAnimation.static,
          // default static
          rightAnimationType: InnerDrawerAnimation.quadratic,
          backgroundDecoration: const BoxDecoration(color: Colors.transparent),
          rightChild: Container(
              color: MobileTheme.of(context).bgColor,
              child: OutlineTree(
                controller: controller.outlineController,
                itemHeight: 48,
                iconSize: 32,
                indentWidth: 24,
              )),
          scaffold: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    EditWidget(controller: controller.editController),
                    Align(
                      alignment: Alignment.topRight,
                      child: ListenableBuilder(
                        listenable: controller.editController,
                        builder: (BuildContext context, Widget? child) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "字数: ${controller.editController.textLength}",
                              style: TextStyle(
                                color: MobileTheme.of(context)
                                    .fontColor
                                    .withOpacity(0.6),
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              if (MediaQuery.of(context).viewInsets.bottom > 10 ||
                  controller.isShowBottomPane.isTrue)
                buildBottomToolbar(context),
              Obx(() {
                if (controller.isShowBottomPane.isFalse) {
                  return Container(
                    height: MediaQuery.of(context).viewInsets.bottom,
                  );
                }
                return IndexedStack(
                  index: controller.bottomIndex.value,
                  children: [
                    buildCreatePane(context),
                    buildFontStylePane(context),
                  ],
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  Widget buildBottomToolbar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MobileTheme.of(context).mobileNavBgColor,
        border: Border(
          top: BorderSide(
            color: MobileTheme.of(context).lineColor,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              child: fluent.IconButton(
                icon: Obx(() {
                  if (controller.isShowBottomPane.isTrue &&
                      controller.bottomIndex.value == 0) {
                    return Opacity(
                      opacity: 0.6,
                      child: Icon(
                        Icons.cancel,
                        size: 24,
                      ),
                    );
                  } else {
                    return Icon(
                      fluent.FluentIcons.add_to,
                      size: 24,
                    );
                  }
                }),
                onPressed: () {
                  if (controller.isShowBottomPane.isTrue &&
                      controller.bottomIndex.value == 0) {
                    closeBottomPane();
                  } else {
                    showBottomPane(context, 0);
                  }
                },
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 40,
              child: fluent.IconButton(
                icon: Obx(() {
                  if (controller.isShowBottomPane.isTrue &&
                      controller.bottomIndex.value == 1) {
                    return Opacity(
                      opacity: 0.6,
                      child: Icon(
                        Icons.cancel,
                        size: 24,
                      ),
                    );
                  } else {
                    return Icon(
                      Icons.font_download_outlined,
                      size: 22,
                    );
                  }
                }),
                onPressed: () {
                  if (controller.isShowBottomPane.isTrue &&
                      controller.bottomIndex.value == 1) {
                    closeBottomPane();
                  } else {
                    controller.getTextStyle();
                    showBottomPane(context, 1);
                  }
                },
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 40,
              child: fluent.IconButton(
                icon: Icon(
                  fluent.FluentIcons.photo2,
                  size: 20,
                ),
                onPressed: () {
                  showAddImageDialog(context);
                },
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 40,
              child: fluent.IconButton(
                icon: Icon(
                  fluent.FluentIcons.bulleted_list,
                  size: 22,
                ),
                onPressed: () {
                  controller.editController.setItemType(itemType: "li");
                },
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 40,
              child: fluent.IconButton(
                icon: Icon(
                  fluent.FluentIcons.checkbox_composite,
                  size: 18,
                ),
                onPressed: () {
                  controller.editController.setItemType(itemType: "check");
                },
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 40,
              child: Builder(builder: (context) {
                return fluent.IconButton(
                  icon: Icon(
                    fluent.FluentIcons.more,
                    size: 20,
                  ),
                  onPressed: () {
                    showToolbarContextMenu(context);
                  },
                );
              }),
            ),
          ),
          Expanded(
            child: Container(
              height: 40,
              child: fluent.IconButton(
                icon: Icon(
                  Icons.keyboard_hide_rounded,
                  size: 20,
                ),
                onPressed: () {
                  controller.editController.inputManager.closeInputMethod();
                },
              ),
            ),
          ),
          if (controller.submitButton != null)
            Container(
              height: 40,
              child: controller.submitButton,
            )
        ],
      ),
    );
  }

  void showAddImageDialog(BuildContext context) async {
    var imagePicker = ImagePicker();
    var list = await imagePicker.pickMultiImage();
    if (list.isNotEmpty) {
      for (var item in list) {
        await controller.editController.pasteImageFile(item.path);
      }
    }
  }

  void showBottomPane(BuildContext context, int index) {
    controller.bottomIndex.value = index;
    var keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    if (keyboardHeight == 0) {
      return;
    }
    controller.keyboardHeight.value = keyboardHeight;
    controller.isShowBottomPane.value = true;
    controller.editController.inputManager.closeInputMethod();
  }

  void closeBottomPane() {
    controller.editController.inputManager.openInputMethod();
  }

  Widget buildCreatePane(BuildContext context) {
    if (controller.isShowBottomPane.isTrue) {
      return Container(
        height: controller.keyboardHeight.value,
        color: MobileTheme.of(context).mobileNavBgColor,
        child: GridView.extent(
          maxCrossAxisExtent: 180,
          padding: const EdgeInsets.all(10),
          childAspectRatio: 3.6,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            // newline
            buildCreateButton(
              context,
              onTap: () async {
                controller.editController.addTextBlock();
                closeBottomPane();
              },
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      Icons.new_label_outlined,
                      size: 24,
                    ),
                  ),
                  Text("添加行"),
                ],
              ),
            ),
            // 引用
            buildCreateButton(
              context,
              onTap: () async {
                controller.editController.changeTextToQuote();
                closeBottomPane();
              },
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      Icons.format_quote_outlined,
                      size: 24,
                    ),
                  ),
                  Text("引用"),
                ],
              ),
            ),
            // line
            buildCreateButton(
              context,
              onTap: () async {
                controller.editController.addLine();
                closeBottomPane();
              },
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      fluent.FluentIcons.charticulator_line_style_dashed,
                      size: 24,
                    ),
                  ),
                  Text("分割线"),
                ],
              ),
            ),
            // link
            buildCreateButton(
              context,
              onTap: () async {
                controller.editController.addLink();
                closeBottomPane();
              },
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      Icons.link,
                      size: 24,
                    ),
                  ),
                  Text("链接"),
                ],
              ),
            ),
            // 公式
            buildCreateButton(
              context,
              onTap: () async {
                await controller.editController.addFormula();
                closeBottomPane();
              },
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      Icons.abc_outlined,
                      size: 24,
                    ),
                  ),
                  Text("公式"),
                ],
              ),
            ),
            // 代码
            buildCreateButton(
              context,
              onTap: () {
                controller.editController.addCodeBlock();
                closeBottomPane();
              },
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      Icons.code_rounded,
                      size: 24,
                    ),
                  ),
                  Text("代码"),
                ],
              ),
            ),
            // 表格
            buildCreateButton(
              context,
              onTap: () {
                controller.editController.addTable(3, 3);
                closeBottomPane();
              },
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      Icons.grid_on_outlined,
                      size: 24,
                    ),
                  ),
                  Text("表格"),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        height: MediaQuery.of(context).viewInsets.bottom,
      );
    }
  }

  Material buildCreateButton(BuildContext context,
      {required VoidCallback onTap, required Widget child}) {
    return Material(
      color: Colors.transparent,
      child: Ink(
          decoration: BoxDecoration(
            color: MobileTheme.of(context).fontColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: child,
          )),
    );
  }

  Widget buildFontStylePane(BuildContext context) {
    return Container(
      color: MobileTheme.of(context).mobileNavBgColor,
      height: controller.keyboardHeight.value,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // 正文-标题
            Container(
              height: 48,
              margin: EdgeInsets.only(
                top: 10,
                left: 10,
                bottom: 10,
                right: 10,
              ),
              decoration: BoxDecoration(
                color: MobileTheme.buildColor(
                  context,
                  darkColor: Colors.black54,
                  lightColor: Colors.grey.withOpacity(0.1),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  for (var i = 0; i < 7; i++)
                    Expanded(
                      child: buildHeadingButton(context, i),
                    ),
                ],
              ),
            ),
            // 缩进-对齐方式
            Row(
              children: [
                // 缩进
                Expanded(
                  flex: 2,
                  child: Container(
                      height: 48,
                      margin: EdgeInsets.only(
                        left: 10,
                        bottom: 10,
                        right: 5,
                      ),
                      decoration: BoxDecoration(
                        color: MobileTheme.buildColor(
                          context,
                          darkColor: Colors.black54,
                          lightColor: Colors.grey.withOpacity(0.1),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: buildToggleButton(
                              context,
                              child: Icon(
                                Icons.format_indent_increase_outlined,
                                size: 24,
                                color: MobileTheme.of(context)
                                    .fontColor
                                    .withOpacity(0.6),
                              ),
                              onPress: () {
                                controller.editController.addIndent();
                              },
                            ),
                          ),
                          Expanded(
                            child: buildToggleButton(
                              context,
                              child: Icon(
                                Icons.format_indent_decrease_outlined,
                                size: 24,
                                color: MobileTheme.of(context)
                                    .fontColor
                                    .withOpacity(0.6),
                              ),
                              onPress: () {
                                controller.editController.removeIndent();
                              },
                            ),
                          ),
                        ],
                      )),
                ),
                // 对齐方式
                Expanded(
                  flex: 3,
                  child: Container(
                      height: 48,
                      margin: EdgeInsets.only(
                        left: 5,
                        bottom: 10,
                        right: 10,
                      ),
                      decoration: BoxDecoration(
                        color: MobileTheme.buildColor(
                          context,
                          darkColor: Colors.black54,
                          lightColor: Colors.grey.withOpacity(0.1),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: buildToggleButton(
                              context,
                              child: Icon(
                                Icons.format_align_left_outlined,
                                size: 24,
                                color: MobileTheme.of(context)
                                    .fontColor
                                    .withOpacity(0.6),
                              ),
                              onPress: () {
                                controller.changeAlignment(null);
                              },
                            ),
                          ),
                          Expanded(
                            child: buildToggleButton(
                              context,
                              child: Icon(
                                Icons.format_align_center_outlined,
                                size: 24,
                                color: MobileTheme.of(context)
                                    .fontColor
                                    .withOpacity(0.6),
                              ),
                              onPress: () {
                                controller.changeAlignment("center");
                              },
                            ),
                          ),
                          Expanded(
                            child: buildToggleButton(
                              context,
                              child: Icon(
                                Icons.format_align_right_outlined,
                                size: 24,
                                color: MobileTheme.of(context)
                                    .fontColor
                                    .withOpacity(0.6),
                              ),
                              onPress: () {
                                controller.changeAlignment("right");
                              },
                            ),
                          ),
                        ],
                      )),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget buildHeadingButton(BuildContext context, int level) {
    String levelText = "正文";
    if (level > 0) {
      levelText = "H$level";
    }
    return Obx(() {
      return custom.ToggleItem(
        checked: controller.textLevel.value == level,
        onTap: (context) {
          if (controller.textLevel.value != level) {
            controller.editController.changeTextLevel(level);
            controller.textLevel.value = level;
            closeBottomPane();
          }
        },
        itemBuilder:
            (BuildContext context, bool checked, bool hover, bool pressed) {
          bool isChecked = controller.textLevel.value == level;
          return Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: MobileTheme.buildColor(
                  context,
                  lightColor: isChecked ? Colors.white : null,
                  darkColor: isChecked ? Colors.grey : null,
                )),
            child: Center(child: Text(levelText)),
          );
        },
      );
    });
  }

  Widget buildToggleButton(
    BuildContext context, {
    Widget? child,
    bool isChecked = false,
    VoidCallback? onPress,
  }) {
    return custom.ToggleItem(
      checked: isChecked,
      onTap: (context) {
        onPress?.call();
      },
      itemBuilder:
          (BuildContext context, bool checked, bool hover, bool pressed) {
        return Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: MobileTheme.buildColor(
                context,
                lightColor: isChecked ? Colors.white : null,
                darkColor: isChecked ? Colors.grey : null,
              )),
          child: Opacity(
            opacity: pressed ? 0.4 : 1,
            child: Center(child: child),
          ),
        );
      },
    );
  }

  void showToolbarContextMenu(BuildContext context) {
    showDropMenu(
      context,
      modal: false,
      childrenHeight: 40,
      popupAlignment: Alignment.topCenter,
      margin: 10,
      menus: [
        DropMenu(
          text: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text("上方插入"),
          ),
          icon: Icon(fluent.FluentIcons.padding_bottom),
          onPress: (ctx) {
            hideDropMenu(ctx);
            controller.editController.addTextBlockBefore();
          },
        ),
        DropMenu(
          text: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text("下方添加"),
          ),
          icon: Icon(fluent.FluentIcons.padding_top),
          onPress: (ctx) {
            hideDropMenu(ctx);
            controller.editController.addTextBlock();
          },
        ),
        DropSplit(),
        DropMenu(
          text: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text("全选"),
          ),
          icon: Icon(Icons.select_all),
          onPress: (ctx) {
            hideDropMenu(ctx);
            controller.editController.selectAll();
          },
        ),
        DropMenu(
          text: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text("粘贴"),
          ),
          icon: Icon(Icons.paste),
          onPress: (ctx) {
            hideDropMenu(ctx);
            controller.editController.paste();
          },
        ),
        DropMenu(
          text: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text("复制"),
          ),
          icon: Icon(Icons.copy),
          onPress: (ctx) {
            hideDropMenu(ctx);
            controller.editController.copy();
          },
        ),
        DropMenu(
          text: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text("剪切"),
          ),
          icon: Icon(Icons.cut),
          onPress: (ctx) {
            hideDropMenu(ctx);
            controller.editController.cut();
          },
        ),
      ],
    );
  }

  void showMoreContextMenu(BuildContext context) {
    var editTheme = MobileTheme.of(context);
    showDropMenu(
      context,
      childrenWidth: 180,
      childrenHeight: 48,
      offset: Offset(-10, 0),
      modal: true,
      menus: [
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
            controller.copyContent(ctx);
            showToast("复制成功！", context: context);
          },
        ),
        if (controller.doc?.type != 'doc')
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
                context, controller.doc?.name ?? "新建卡片", [controller.doc!]);
          },
        ),
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
      ],
    );
  }

  void showMoveToDocDialog(BuildContext ctx) {}
}
