import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/scheduler.dart';
import 'package:wenznote/commons/util/platform_util.dart';
import 'package:wenznote/editor/block/block.dart';
import 'package:wenznote/editor/block/code/code.dart';
import 'package:wenznote/editor/block/image/image_block.dart';
import 'package:wenznote/editor/block/table/table_block.dart';
import 'package:wenznote/editor/block/table/table_cell.dart';
import 'package:wenznote/editor/block/table/text_cell.dart';
import 'package:wenznote/editor/block/text/text.dart';
import 'package:wenznote/editor/crdt/YsCursor.dart';
import 'package:wenznote/editor/crdt/YsSelection.dart';
import 'package:wenznote/editor/cursor/cursor.dart';
import 'package:wenznote/editor/edit_controller.dart';
import 'package:wenznote/editor/edit_float_widget.dart';
import 'package:ydart/ydart.dart';

import 'YsTree.dart';

class YsEditController extends EditController {
  YsTree? ysTree;
  UndoManager? undoManager;

  YsEditController({
    super.reader,
    super.onContentChanged,
    super.writer,
    super.initFocus = false,
    super.editable = true,
    super.hideTextModes,
    super.padding = EdgeInsets.zero,
    super.initBlockIndex,
    super.initTextOffset,
    super.scrollController,
    super.maxEditWidth,
    required super.fileManager,
    required super.copyService,
  });

  bool get isEmpty => blockManager.isEmpty;

  void initTree(YsTree tree) {
    ysTree = tree;
  }

  @override
  Future<void> readContent(BuildContext context,
      {bool initContent = false}) async {
    SchedulerBinding.instance.scheduleFrameCallback((timeStamp) {
      notifyListeners();
    });
  }

  void setBlocks(List<WenBlock> blocks) {
    blockManager.setBlocks(blocks);
  }

  @override
  void onInputAction(TextInputAction action) {
    if (action == TextInputAction.newline) {
      if (Platform.isAndroid || Platform.isIOS) {
        enter();
        WidgetsBinding.instance.scheduleFrameCallback((timeStamp) {
          refreshCursorPosition();
        });
      }
    }
  }

  @override
  Future<void> pasteImageFile(String path) {
    return super.pasteImageFile(path);
  }

  @override
  void addIndent() {
    if (currentStartBlockIndex != -1 &&
        currentStartBlockIndex == currentEndBlockIndex) {
      var block = blockManager.blocks[currentStartBlockIndex];
      if (block is TableBlock) {
        block.nextTable();
        return;
      }
    }
    ysTree?.addIndent();
  }

  @override
  void removeIndent() {
    ysTree?.removeIndent();
  }

  @override
  void enter() {
    if (replaceWithCodeCheck()) {
      return;
    }
    if (popupTool.isShow) {
      popupTool.enter();
      return;
    }
    ysTree?.enter();
    super.updateWindowCursorRecordPosition();
    record();
  }

  @override
  void onInputComposing(TextEditingValue composing) {
    super.onInputComposing(composing);
    ysTree?.onInputComposing(composing);
  }

  @override
  void deleteComposing() {
    super.deleteComposing();
    ysTree?.deleteComposing();
  }

  @override
  void onInputText(TextEditingValue text) {
    ysTree?.transact((transaction) {
      deleteComposing();
      deleteSelectRange();
      ysTree?.onInputText(text);
    });
    record();
    showPopupTool(true);
    replaceWithTitleCheck();
    replaceWithLiCheck();
    replaceWithQuoteCheck();
  }

  @override
  void delete(bool backspace) {
    if (selectState.hasSelectRange) {
      deleteSelectRange();
    } else {
      deleteCursor(backspace);
    }
    showPopupTool();
  }

  @override
  void deleteCursor(bool backspace) {
    ysTree?.deleteCursor(backspace);
    record();
  }

  @override
  void deleteSelectRange() {
    ysTree?.deleteSelectRange();
    record();
  }

  @override
  void insertContent(List<WenBlock>? insertBlocks, String? insertText) {
    if (insertBlocks == null || insertBlocks.isEmpty) {
      if (insertText == null || insertText == "") {
        return;
      }
      insertBlocks = parseTextToBlock(insertText);
    }
    insertBlocks = dealPasteBlocks(insertBlocks);
    ysTree?.insertContent(insertBlocks);
    record();
  }

  @override
  void changeTextLevel(int level) {
    ysTree?.changeTextLevel(level);
    record();
  }

  @override
  void changeTextToQuote() {
    ysTree?.changeTextToQuote();
    record();
  }

  @override
  void addCodeBlock({String code = "", String language = ""}) {
    ysTree?.addCodeBlock(code: code, language: language);
    record();
  }

  @override
  void addBlock(WenBlock block) {
    ysTree?.addBlock(block);
    record();
  }

  @override
  void addTextBlock() {
    ysTree?.addTextBlockAfter();
    ysTree?.applySelectionToEditor();
    ysTree?.applyCursorToEditor();
    record();
  }

  @override
  void addTextBlockBefore() {
    ysTree?.addTextBlockBefore();
    ysTree?.applySelectionToEditor();
    ysTree?.applyCursorToEditor();
    record();
  }

  @override
  void addLink() {
    var linkController = fluent.TextEditingController(text: "");
    var textController = fluent.TextEditingController(text: "");
    var ok = false;
    showMobileDialog(
        context: viewContext,
        builder: (context) {
          return fluent.ContentDialog(
            title: const fluent.Text("添加链接"),
            constraints: isMobile
                ? const BoxConstraints(maxWidth: 300)
                : fluent.kDefaultContentDialogConstraints,
            content: fluent.Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                fluent.Container(
                  margin: const EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: fluent.TextBox(
                    placeholder: "请输入链接文字",
                    autofocus: true,
                    onSubmitted: (s) {
                      ok = true;
                      Navigator.pop(context, '取消');
                    },
                    controller: textController,
                  ),
                ),
                Container(
                  child: fluent.TextBox(
                    placeholder: "http://",
                    controller: linkController,
                    onSubmitted: (s) {
                      ok = true;
                      Navigator.pop(context, '取消');
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
                    ok = true;
                    Navigator.pop(context, '确定');
                  },
                  child: const Text("确定")),
            ],
          );
        }).then((value) {
      if (ok && linkController.text.isNotEmpty) {
        var link = linkController.text;
        var text = textController.text;
        if (text.isEmpty) {
          text = link;
        }
        insertContent([
          TextBlock(
              editController: this,
              context: viewContext,
              textElement: WenTextElement(
                children: [
                  WenTextElement(
                    text: text,
                    url: link,
                  ),
                ],
              ))
        ], null);
      }
    });
  }

  @override
  void addTable(int rowCount, int colCount) {
    ysTree?.addTable(rowCount, colCount);
    record();
  }

  @override
  void addLine() {
    ysTree?.addLine();
    ysTree?.applySelectionToEditor();
    ysTree?.applyCursorToEditor();
    record();
  }

  @override
  void toggleCode({String language = ""}) {
    ysTree?.toggleCode(language: language);
    ysTree?.applySelectionToEditor();
    ysTree?.applyCursorToEditor();
    record();
  }

  @override
  void replaceBlock(int startIndex, int replaceCount, List<WenBlock> blocks) {
    ysTree?.replaceWenBlock(startIndex, replaceCount, blocks);
    record();
  }

  @override
  void clearStyle() {
    ysTree?.clearStyle();
    record();
  }

  @override
  void record() {
    ysTree?.record();
    onContentChanged?.call();
    notifyListeners();
  }

  @override
  void undo() {
    ysTree?.undo();
    onContentChanged?.call();
  }

  @override
  void redo() {
    ysTree?.redo();
    onContentChanged?.call();
  }

  @override
  bool get canRedo => ysTree?.undoManager?.canRedo() ?? false;

  @override
  bool get canUndo => ysTree?.undoManager?.canUndo() ?? false;

  @override
  void setLink() {
    var linkController = fluent.TextEditingController(text: "");
    var textController = fluent.TextEditingController(text: getSelectText());
    var ok = false;
    showMobileDialog(
        context: viewContext,
        builder: (context) {
          return fluent.ContentDialog(
            constraints: isMobile
                ? const BoxConstraints(maxWidth: 300, maxHeight: 300)
                : fluent.kDefaultContentDialogConstraints,
            title: const fluent.Text("添加链接"),
            content: fluent.Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                fluent.Container(
                  margin: const EdgeInsets.only(bottom: 10, top: 10),
                  child: fluent.TextBox(
                    placeholder: "请输入链接文字",
                    onSubmitted: (inputText) {
                      ok = true;
                      Navigator.pop(context, '取消');
                    },
                    controller: textController,
                  ),
                ),
                fluent.Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: fluent.TextBox(
                    autofocus: true,
                    placeholder: "http://",
                    controller: linkController,
                    onSubmitted: (s) {
                      ok = true;
                      Navigator.pop(context, '取消');
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
                    ok = true;
                    Navigator.pop(context, '确定');
                  },
                  child: const Text("确定")),
            ],
          );
        }).then((value) {
      if (ok && linkController.text.isNotEmpty) {
        ysTree?.setLink(textController.text, linkController.text);
        record();
      }
    });
  }

  @override
  void updateCursor(
    CursorPosition position, {
    bool scrollToShowCursor = true,
    bool applyUpdate = false,
  }) {
    super.updateCursor(position, scrollToShowCursor: scrollToShowCursor);
    if (applyUpdate) {
      var block = position.block;
      var pos = position.textPosition;
      if (pos == null || block == null) {
        ysTree?.removeCursor();
        return;
      }
      // 特殊情况，需要得到子block的position
      YsCursor? cursor = createYsCursor(position);
      if (cursor == null) {
        ysTree?.removeCursor();
        return;
      }
      ysTree!.setCursor(cursor);
    }
  }

  void updateCursorToEdit(CursorPosition position) {
    super.updateCursor(position);
  }

  YsCursor? createYsCursor(CursorPosition? position) {
    if (position == null) {
      return null;
    }
    var blockIndex = position.blockIndex ?? 0;
    var block = position.block;
    var pos = position.textPosition;
    if (pos == null || block == null) {
      return null;
    }
    // 特殊情况，需要得到子block的position
    if (block is TableBlock) {
      var rowIndex = block.getRowIndex(pos.offset);
      var cellIndex = block.getColIndex(rowIndex, pos.offset);
      var cell = block.getCell(pos.offset);
      var textOffset = pos.offset - (cell as TableBaseCell).offset;
      return createTableCursor(
          ysTree!, blockIndex, rowIndex, cellIndex, textOffset);
    } else if (block is TextBlock) {
      return createTextCursor(ysTree!, blockIndex, pos.offset);
    } else if (block is CodeBlock) {
      return createCodeCursor(ysTree!, blockIndex, pos.offset);
    } else if (block is ImageBlock) {
      return createImageCursor(ysTree!, blockIndex, pos.offset);
    } else {
      return createLineCursor(ysTree!, blockIndex, pos.offset);
    }
  }

  @override
  void onSelectChanged() {
    if (selectState.hasSelect) {
      var selection = YsSelection();
      selection.start = createYsCursor(selectState.realStart);
      selection.end = createYsCursor(selectState.realEnd);
      ysTree!.setSelection(selection);
    } else {
      ysTree!.setSelection(null);
    }
  }

  @override
  void changeBlockChecked(TextBlock textBlock, bool? checked) {
    ysTree!.changeBlockChecked(textBlock.blockIndex, checked);
    record();
  }

  @override
  void addTableRowOnPrevious() {
    ysTree?.addTableRowOnPrevious();
    record();
  }

  @override
  void addTableRowOnNext() {
    ysTree?.addTableRowOnNext();
    record();
  }

  @override
  void addTableColOnPrevious() {
    ysTree?.addTableColOnPrevious();
    record();
  }

  @override
  void addTableColOnNext() {
    ysTree?.addTableColOnNext();
    record();
  }

  @override
  void deleteTableRow() {
    ysTree?.deleteRow();
    record();
  }

  @override
  void deleteTableCol() {
    ysTree?.deleteCol();
    record();
  }

  @override
  void deleteTable() {
    ysTree?.deleteTable();
    record();
  }

  @override
  void deleteCode() {
    ysTree?.deleteCode();
    record();
  }

  @override
  void setItemType({String itemType = "li"}) {
    ysTree?.setItemType(itemType: itemType);
    record();
  }

  @override
  void updateFormula(TextBlock block, WenTextElement element, String formula) {
    if (block is TextTableCell) {
      var table = block.tableBlock;
      var offset = block.offset;
      var rowIndex = table.getRowIndex(offset);
      var colIndex = table.getColIndex(rowIndex, offset);
      ysTree?.updateTableCellFormula(blockManager.indexOfBlockByBlock(table),
          rowIndex, colIndex, element.offset, formula);
    } else {
      ysTree?.updateFormula(
          blockManager.indexOfBlockByBlock(block), element.offset, formula);
    }
    record();
  }

  @override
  void setTableAlignment(TableBlock block, String alignment) {
    var blockIndex = blockManager.indexOfBlockByBlock(block);
    if (blockIndex == -1) {
      return;
    }
    ysTree?.setTableAlignment(blockIndex, alignment);
    record();
  }

  @override
  void adjustTable(TableBlock tableBlock, int newRowCount, int newColCount) {
    var blockIndex = blockManager.indexOfBlockByBlock(tableBlock);
    if (blockIndex == -1) {
      return;
    }
    ysTree?.adjustTable(blockIndex, newRowCount, newColCount);
    record();
  }

  @override
  void setAlignment(String? alignment) {
    ysTree?.setAlignment(alignment);
    record();
  }

  @override
  void setTextColor(int index) {
    ysTree?.setTextColor(defaultColors[index]?.value);
    record();
  }

  @override
  void updateCodeLanguage(CodeBlock codeBlock, String language) {
    ysTree?.updateCodeLanguage(codeBlock.blockIndex, language);
    record();
  }

  @override
  void setBackgroundColor(int index) {
    ysTree?.setBackgroundColor(defaultColors[index]?.value);
    record();
  }

  @override
  void setBold(bool? bold) {
    ysTree?.setBold(bold);
    record();
  }

  @override
  void setItalic(bool? italic) {
    ysTree?.setItalic(italic);
    record();
  }

  @override
  void setLineThrough(bool? lineThrough) {
    ysTree?.setLineThrough(lineThrough);
    record();
  }

  @override
  void setUnderline(bool? underline) {
    ysTree?.setUnderline(underline);
    record();
  }
  @override
  bool insertRow(TableBlock tableBlock, int rowIndex, int colIndex) {
    ysTree?.insertRow(tableBlock.blockIndex,rowIndex,colIndex);
    record();
    return true;
  }
  @override
  bool insertCol(TableBlock tableBlock, int rowIndex, int colIndex) {
    ysTree?.insertCol(tableBlock.blockIndex,rowIndex,colIndex);
    record();
    return true;
  }
}
