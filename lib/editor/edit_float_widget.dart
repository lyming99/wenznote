import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:wenznote/commons/widget/flayout.dart';
import 'package:wenznote/commons/widget/popup_stack.dart';
import 'package:wenznote/editor/block/code/code.dart';
import 'package:wenznote/editor/block/table/table_block.dart';
import 'package:wenznote/editor/cursor/cursor.dart';
import 'package:wenznote/editor/edit_controller.dart';
import 'package:wenznote/editor/theme/theme.dart';

import 'block/text/text.dart';
import 'widget/toggle_item.dart';

var defaultColors = <Color?>[
  fluent.Colors.yellow.darkest,
  fluent.Colors.orange.darkest,
  fluent.Colors.red.darkest,
  fluent.Colors.magenta.darkest,
  fluent.Colors.purple.darkest,
  fluent.Colors.blue.darkest,
  fluent.Colors.teal.darkest,
  fluent.Colors.green.darkest,
  Colors.black,
  fluent.Colors.yellow.darker,
  fluent.Colors.orange.darker,
  fluent.Colors.red.darker,
  fluent.Colors.magenta.darker,
  fluent.Colors.purple.darker,
  fluent.Colors.blue.darker,
  fluent.Colors.teal.darker,
  fluent.Colors.green.darker,
  Colors.grey.shade800,
  fluent.Colors.yellow.dark,
  fluent.Colors.orange.dark,
  fluent.Colors.red.dark,
  fluent.Colors.magenta.dark,
  fluent.Colors.purple.dark,
  fluent.Colors.blue.dark,
  fluent.Colors.teal.dark,
  fluent.Colors.green.dark,
  Colors.grey.shade600,
  fluent.Colors.yellow.normal,
  fluent.Colors.orange.normal,
  fluent.Colors.red.normal,
  fluent.Colors.magenta.normal,
  fluent.Colors.purple.normal,
  fluent.Colors.blue.normal,
  fluent.Colors.teal.normal,
  fluent.Colors.green.normal,
  Colors.grey.shade400,
  fluent.Colors.yellow.light,
  fluent.Colors.orange.light,
  fluent.Colors.red.light,
  fluent.Colors.magenta.light,
  fluent.Colors.purple.light,
  fluent.Colors.blue.light,
  fluent.Colors.teal.light,
  fluent.Colors.green.light,
  Colors.grey.shade200,
  fluent.Colors.yellow.lighter,
  fluent.Colors.orange.lighter,
  fluent.Colors.red.lighter,
  fluent.Colors.magenta.lighter,
  fluent.Colors.purple.lighter,
  fluent.Colors.blue.lighter,
  fluent.Colors.teal.lighter,
  fluent.Colors.green.lighter,
  Colors.white,
  fluent.Colors.yellow.lightest,
  fluent.Colors.orange.lightest,
  fluent.Colors.red.lightest,
  fluent.Colors.magenta.lightest,
  fluent.Colors.purple.lightest,
  fluent.Colors.blue.lightest,
  fluent.Colors.teal.lightest,
  fluent.Colors.green.lightest,
  null,
];

extension EditFloatToolController on EditController {
  void showToolbarContextMenu(BuildContext context, {bool showInsert = false}) {
    contextMenuController.showFlyout(builder: (context) {
      return fluent.MenuFlyout(
        items: [
          if (showInsert)
            fluent.MenuFlyoutItem(
              text: fluent.Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  fluent.Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(fluent.FluentIcons.padding_bottom),
                  ),
                  Text("上方插入"),
                ],
              ),
              onPressed: () {
                addTextBlockBefore();
                Navigator.of(context).pop();
              },
            ),
          if (showInsert)
            fluent.MenuFlyoutItem(
              text: fluent.Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  fluent.Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(fluent.FluentIcons.padding_top),
                  ),
                  Text("下方添加"),
                ],
              ),
              onPressed: () {
                addTextBlock();
                Navigator.of(context).pop();
              },
            ),
          if (showInsert) const fluent.MenuFlyoutSeparator(),
          fluent.MenuFlyoutItem(
            text: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.copy),
                ),
                Text("复制"),
              ],
            ),
            onPressed: () {
              copy();
              Navigator.of(context).pop();
            },
          ),
          fluent.MenuFlyoutItem(
            text: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.cut),
                ),
                Text("剪切"),
              ],
            ),
            onPressed: () {
              cut();
              Navigator.of(context).pop();
            },
          ),
          fluent.MenuFlyoutItem(
            text: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.paste),
                ),
                Text("粘贴"),
              ],
            ),
            onPressed: () {
              paste();
              Navigator.of(context).pop();
            },
          ),
          fluent.MenuFlyoutItem(
            text: fluent.Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                fluent.Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.select_all),
                ),
                Text("全选"),
              ],
            ),
            onPressed: () {
              selectAll();
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    });
  }

  Rect getSelectRect() {
    var selectMarginBottom = isMobile ? 24 : 0;
    var selectStart = selectState.realStart;
    var selectEnd = selectState.realEnd;
    double left = double.infinity;
    double right = 0;
    double top = double.infinity;
    double bottom = 0;
    if (selectStart != null &&
        selectEnd != null &&
        selectStart.isValid &&
        selectEnd.isValid) {
      var startBlock = selectStart.block!;
      var startPosition = selectStart.textPosition!;
      var endBlock = selectEnd.block!;
      var endPosition = selectEnd.textPosition!;
      if (startBlock.top > endBlock.top) {
        startBlock = selectEnd.block!;
        endBlock = selectStart.block!;
        startPosition = selectEnd.textPosition!;
        endPosition = selectStart.textPosition!;
      }
      var blocks = blockManager.layout(
          viewContext, scrollOffset, Size(blockMaxWidth, visionHeight), padding);
      for (var block in blocks) {
        //判断block的y是否在start block和end block之间
        if (block.top < startBlock.top || block.top > endBlock.top) continue;
        TextPosition drawStart, drawEnd;
        drawStart = block.startPosition;
        drawEnd = block.endPosition;
        if (block.top == startBlock.top) {
          drawStart = startPosition;
        }
        if (block.top == endBlock.top) {
          drawEnd = endPosition;
        }
        block.selected = true;
        block.selectedStart = drawStart;
        block.selectedEnd = drawEnd;
        //绘制选择高亮
        var selection = TextSelection.fromPosition(drawStart).extendTo(drawEnd);
        var boxes = block.getBoxesForSelection(selection);
        for (var box in boxes) {
          var boxRect = box.toRect();
          left = min(left, boxRect.left);
          right = max(right, boxRect.right);
          top = min(top, boxRect.top + block.top);
          bottom = max(bottom, boxRect.bottom + block.top);
        }
      }

      var startRect = getCursorRect(selectState.start);
      if (startRect != null) {
        left = min(left, startRect.left);
        right = max(right, startRect.right);
        top = min(top, startRect.top);

        bottom = max(bottom, startRect.bottom + selectMarginBottom);
      }
      var endRect = getCursorRect(selectState.end);
      if (endRect != null) {
        left = min(left, endRect.left);
        right = max(right, endRect.right);
        top = min(top, endRect.top);
        bottom = max(bottom, endRect.bottom + selectMarginBottom);
      }
      return Rect.fromLTRB(left, top, right, bottom);
    }
    return Rect.zero;
  }

  Rect? getCursorRect([CursorPosition? position]) {
    position ??= cursorState.cursorPosition;
    if (position == null) {
      return null;
    }
    var block = position.block;
    var pos = position.textPosition;
    if (block == null || pos == null) {
      return null;
    }
    var rect = block.getCursorRect(pos);
    if (rect != null) {
      return rect.translate(0, block.top);
    }
    return rect;
  }

  PopupPositionWidget? buildDesktopFloatToolWidget() {
    if (!editable) {
      return null;
    }
    if (rightMenuShowing) {
      return null;
    }
    if (!selectState.isCursorDragging &&
        !selectState.shiftDown &&
        !mouseKeyboardState.mouseLeftDown &&
        selectState.hasSelect) {
      var start = selectState.realStart;
      var end = selectState.realEnd;

      //标题、粗体、颜色、斜体、下划线、删除线、链接、标记
      bool showLink = start?.block == end?.block && start?.block is TextBlock;
      if (start?.block == end?.block && start?.block is TableBlock) {
        var tableBlock = start!.block as TableBlock;
        showLink = tableBlock.isShowLink(
            start!.textPosition!.offset, end!.textPosition!.offset);
      }
      bool isRemark = true;
      int? blockTextLevel;
      bool showBlockTextLevel = true;
      bool showAlignment = false;

      bool isBold = true;
      bool isItalic = true;
      bool isUnderLine = true;
      bool isDeleteLine = true;
      bool hasText = false;

      visitSelectElement((block, element) {
        if (element is WenTextElement) {
          hasText = true;
          if (element.bold != true) {
            isBold = false;
          }
          if (element.italic != true) {
            isItalic = false;
          }
          if (element.lineThrough != true) {
            isDeleteLine = false;
          }
          if (element.underline != true) {
            isUnderLine = false;
          }
          if (element.remark != true) {
            isRemark = false;
          }
        }
      });
      visitSelectBlock((block) {
        if (block is TextBlock) {
          var level = block.textElement.level;
          if (blockTextLevel == null) {
            blockTextLevel = level;
          } else {
            if (level != blockTextLevel) {
              showBlockTextLevel = false;
            }
          }
        }
        if (block is! CodeBlock) {
          showAlignment = true;
        }
      });

      var selectRect = getSelectRect();
      selectRect =
          selectRect.translate(padding.left, padding.top - scrollOffset);
      var menuChildren = [
        if (!isMobile && showAlignment) _buildLeftAlignmentButton(),
        if (!isMobile && showAlignment) _buildCenterAlignmentButton(),
        if (!isMobile && showAlignment) _buildRightAlignmentButton(),
        //字体颜色
        if (hasText) _buildFontColorPicker(null),
        //字体底色
        if (hasText) _buildBgColorPicker(null),
        //加粗
        if (hasText)
          ToggleItem(
            checked: isBold,
            onChanged: (val) {
              setBold(val);
            },
            itemBuilder:
                (BuildContext context, bool checked, bool hover, bool pressed) {
              return Container(
                width: 30,
                height: 30,
                color: hover ? EditTheme.of(context).scrollBarHoverColor : null,
                alignment: Alignment.center,
                child: Icon(
                  //刷子
                  Icons.format_bold_outlined,
                  color: checked ? Colors.blue : Colors.black,
                ),
              );
            },
          ),
        //倾斜
        if (hasText)
          ToggleItem(
            checked: isItalic,
            onChanged: (val) {
              setItalic(val);
            },
            itemBuilder:
                (BuildContext context, bool checked, bool hover, bool pressed) {
              return Container(
                width: 30,
                height: 30,
                color: hover ? EditTheme.of(context).scrollBarHoverColor : null,
                alignment: Alignment.center,
                child: Icon(
                  Icons.format_italic_outlined,
                  color: checked ? Colors.blue : Colors.black,
                ),
              );
            },
          ),
        //下滑线
        if (hasText)
          ToggleItem(
            checked: isUnderLine,
            onChanged: (val) {
              setUnderline(val);
            },
            itemBuilder:
                (BuildContext context, bool checked, bool hover, bool pressed) {
              return Container(
                width: 30,
                height: 30,
                color: hover ? EditTheme.of(context).scrollBarHoverColor : null,
                alignment: Alignment.center,
                child: Icon(
                  Icons.format_underline_outlined,
                  color: checked ? Colors.blue : Colors.black,
                ),
              );
            },
          ),
        //删除线
        if (hasText)
          ToggleItem(
            checked: isDeleteLine,
            onChanged: (val) {
              setLineThrough(val);
            },
            itemBuilder:
                (BuildContext context, bool checked, bool hover, bool pressed) {
              return Container(
                width: 30,
                height: 30,
                color: hover ? EditTheme.of(context).scrollBarHoverColor : null,
                alignment: Alignment.center,
                child: Icon(
                  Icons.format_strikethrough_outlined,
                  color: checked ? Colors.blue : Colors.black,
                ),
              );
            },
          ),
        //链接
        if (showLink) _buildLinkButton(),
        //清除样式
        if (hasText) _buildClearStyleButton(),
        _buildContextMenuButton(),
      ];
      return menuChildren.isEmpty ||
              selectRect.overlaps(
                      Rect.fromLTWH(0, 0, visionWidth, visionHeight)) ==
                  false
          ? null
          : PopupPositionWidget(
              layerIndex: 1,
              keepVision: true,
              anchorRect: selectRect,
              popupAlignment: Alignment.topCenter,
              overflowAlignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 2,
                      // blurStyle: BlurStyle.outer,
                      color: Colors.grey.shade500,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: menuChildren,
                ),
              ));
    }
    return null;
  }

  ToggleItem _buildLeftAlignmentButton() {
    return ToggleItem(
      onTap: (context) {
        setAlignment(null);
      },
      itemBuilder:
          (BuildContext context, bool checked, bool hover, bool pressed) {
        return Container(
          width: 30,
          height: 30,
          color: hover ? EditTheme.of(context).scrollBarHoverColor : null,
          alignment: Alignment.center,
          child: Icon(
            Icons.format_align_left,
            color: Colors.black,
          ),
        );
      },
    );
  }

  ToggleItem _buildCenterAlignmentButton() {
    return ToggleItem(
      onTap: (context) {
        // 左对齐
        setAlignment("center");
      },
      itemBuilder:
          (BuildContext context, bool checked, bool hover, bool pressed) {
        return Container(
          width: 30,
          height: 30,
          color: hover ? EditTheme.of(context).scrollBarHoverColor : null,
          alignment: Alignment.center,
          child: Icon(
            Icons.format_align_center,
            color: Colors.black,
          ),
        );
      },
    );
  }

  ToggleItem _buildRightAlignmentButton() {
    return ToggleItem(
      onTap: (context) {
        setAlignment("right");
      },
      itemBuilder:
          (BuildContext context, bool checked, bool hover, bool pressed) {
        return Container(
          width: 30,
          height: 30,
          color: hover ? EditTheme.of(context).scrollBarHoverColor : null,
          alignment: Alignment.center,
          child: const Icon(
            Icons.format_align_right,
            color: Colors.black,
          ),
        );
      },
    );
  }

  Widget _buildContextMenuButton() {
    return FlyoutTarget(
      controller: contextMenuController,
      child: ToggleItem(
        onTap: (context) {
          showToolbarContextMenu(context);
        },
        itemBuilder:
            (BuildContext context, bool checked, bool hover, bool pressed) {
          return Container(
            width: 30,
            height: 30,
            color: hover ? EditTheme.of(context).scrollBarHoverColor : null,
            alignment: Alignment.center,
            child: Icon(
              Icons.more_vert_outlined,
              color: Colors.black,
            ),
          );
        },
      ),
    );
  }

  ToggleItem _buildLinkButton() {
    return ToggleItem(
      onTap: (context) {
        setLink();
      },
      itemBuilder:
          (BuildContext context, bool checked, bool hover, bool pressed) {
        return Container(
          width: 30,
          height: 30,
          color: hover ? EditTheme.of(context).scrollBarHoverColor : null,
          alignment: Alignment.center,
          child: Icon(
            Icons.link,
            color: Colors.black,
          ),
        );
      },
    );
  }

  ToggleItem _buildClearStyleButton() {
    return ToggleItem(
      onTap: (context) {
        clearStyle();
      },
      itemBuilder:
          (BuildContext context, bool checked, bool hover, bool pressed) {
        return Container(
          width: 30,
          height: 30,
          color: hover ? EditTheme.of(context).scrollBarHoverColor : null,
          alignment: Alignment.center,
          child: Icon(
            Icons.format_clear,
            color: Colors.black,
          ),
        );
      },
    );
  }

  Widget _buildFontColorPicker(int? color) {
    return FlyoutTarget(
      controller: fontColorPickerController,
      child: ToggleItem(
        onTap: (context) {
          fontColorPickerController.showFlyout(
            builder: (ctx) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 2,
                      // blurStyle: BlurStyle.outer,
                      color: Colors.grey.shade500,
                    ),
                  ],
                ),
                width: 270,
                height: 270 * 7 / 9 + 1,
                child: GridView.builder(
                  itemCount: defaultColors.length,
                  padding: const EdgeInsets.all(4),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 9,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4),
                  itemBuilder: (context, index) {
                    return ToggleItem(
                      onTap: (context) {
                        setTextColor(index);
                        Navigator.pop(context);
                      },
                      itemBuilder: (BuildContext context, bool checked,
                          bool hover, bool pressed) {
                        return Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                              border: hover
                                  ? Border.all(
                                      color: Colors.grey,
                                    )
                                  : null),
                          padding: EdgeInsets.all(1),
                          child: defaultColors[index] != null
                              ? Container(
                                  color: defaultColors[index],
                                )
                              : Container(
                                  child: Icon(
                                    Icons.block,
                                    color: Colors.red,
                                  ),
                                ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          );
        },
        itemBuilder:
            (BuildContext context, bool checked, bool hover, bool pressed) {
          return Container(
            width: 30,
            height: 30,
            color: hover || fontColorPickerController.isOpen
                ? Colors.grey.shade300.withAlpha(100)
                : null,
            alignment: Alignment.center,
            child: Icon(
              //刷子
              Icons.format_color_text,
              color: Colors.black,
            ),
          );
        },
      ),
    );
  }

  Widget _buildBgColorPicker(int? color) {
    return FlyoutTarget(
      controller: bgColorPickerController,
      child: ToggleItem(
        onTap: (context) {
          bgColorPickerController.showFlyout(
            builder: (context) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 2,
                      // blurStyle: BlurStyle.outer,
                      color: Colors.grey.shade500,
                    ),
                  ],
                ),
                width: 270,
                height: 270 * 7 / 9 + 1,
                child: GridView.builder(
                  itemCount: defaultColors.length,
                  padding: EdgeInsets.all(4),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 9,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4),
                  itemBuilder: (context, index) {
                    return ToggleItem(
                      onTap: (context) {
                        setBackgroundColor(index);
                        Navigator.pop(context);
                      },
                      itemBuilder: (BuildContext context, bool checked,
                          bool hover, bool pressed) {
                        return Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                              border: hover
                                  ? Border.all(
                                      color: Colors.grey,
                                    )
                                  : null),
                          padding: EdgeInsets.all(1),
                          child: defaultColors[index] != null
                              ? Container(
                                  color: defaultColors[index],
                                )
                              : Container(
                                  child: Icon(
                                    Icons.block,
                                    color: Colors.red,
                                  ),
                                ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          );
        },
        itemBuilder:
            (BuildContext context, bool checked, bool hover, bool pressed) {
          return Container(
            width: 30,
            height: 30,
            color: hover || bgColorPickerController.isOpen
                ? Colors.grey.shade300.withAlpha(150)
                : null,
            alignment: Alignment.center,
            child: Icon(
              //刷子
              Icons.format_color_fill_outlined,
              color: Colors.black,
            ),
          );
        },
      ),
    );
  }
}
