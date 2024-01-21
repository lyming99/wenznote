import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_crdt/flutter_crdt.dart';
import 'package:get/get.dart';
import 'package:note/app/windows/outline/outline_controller.dart';
import 'package:note/commons/mvc/controller.dart';
import 'package:note/commons/widget/flayout.dart';
import 'package:note/editor/crdt/YsEditController.dart';
import 'package:note/editor/crdt/YsTree.dart';
import 'package:note/model/note/po/doc_po.dart';
import 'package:note/service/service_manager.dart';

typedef DocReader = Future<Doc> Function(BuildContext context);

class MobileDocEditController extends ServiceManagerController {
  var title = "便签".obs;
  late YsEditController editController;
  YsTree? ysTree;
  var toolbarMenuController = FlyoutController();
  var isShowBottomPane = false.obs;
  var keyboardHeight = 0.0.obs;
  var keyboardHeightRecord = 0.0.obs;
  var bottomIndex = 0.obs;
  var textLevel = 0.obs;
  var outlineController = OutlineController();
  var drawSwipeEnable = true.obs;
  var canUndo = false.obs;
  var canRedo = false.obs;
  var textLength = 0.obs;
  DocPO? doc;
  bool hiderAppbar = false;
  Widget? submitButton;
  bool editOnOpen = false;
  bool showOutline = true;
  var canUpdateTitle = false.obs;

  MobileDocEditController({
    this.doc,
    this.hiderAppbar = false,
    this.submitButton,
    this.editOnOpen = false,
    this.showOutline = true,
  });

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    canUpdateTitle.value = title.value.isEmpty;
    editController = YsEditController(
      copyService: serviceManager.copyService,
      fileManager: serviceManager.fileManager,
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
        outlineController.updateTree(editController.viewContext, editController);
      });
    });
    title.listen((val) {
      if (canUpdateTitle.isTrue) {
        doc!.name = val;
        serviceManager.docService.updateDoc(doc!);
      }
    });
    canUndo.value = editController.canUndo;
    canRedo.value = editController.canRedo;
    editController.onContentChanged = () {
      outlineController.updateTree(editController.viewContext, editController);
      canUndo.value = editController.canUndo;
      canRedo.value = editController.canRedo;
      textLength.value = editController.textLength;
    };
    editController.viewContext = context;
    readDoc();
  }

  @override
  void onDidUpdateWidget(BuildContext context, MvcController oldController) {
    super.onDidUpdateWidget(context, oldController);
    var old = oldController as MobileDocEditController;
    title = old.title;
    editController = old.editController;
    ysTree = old.ysTree;
    toolbarMenuController = old.toolbarMenuController;
    isShowBottomPane = old.isShowBottomPane;
    keyboardHeight = old.keyboardHeight;
    keyboardHeightRecord = old.keyboardHeightRecord;
    bottomIndex = old.bottomIndex;
    textLevel = old.textLevel;
    outlineController = old.outlineController;
    drawSwipeEnable = old.drawSwipeEnable;
    canUndo = old.canUndo;
    canRedo = old.canRedo;
    textLength = old.textLength;
    doc = old.doc;
    hiderAppbar = old.hiderAppbar;
    submitButton = old.submitButton;
    editOnOpen = old.editOnOpen;
    showOutline = old.showOutline;
    canUpdateTitle = old.canUpdateTitle;
  }

  Future<void> readDoc() async {
    title.value = this.doc?.name ?? "";
    var doc = await serviceManager.editService.readDoc(this.doc?.uuid);
    if (doc != null) {
      initYsTree(doc);
      editController.waitLayout(() {
        editController.requestFocus();
      });
      doc.on("update", (args) async {
        var data = args[0];
        if (serviceManager.editService
            .isInUpdateCache(this.doc?.uuid ?? "", data)) {
          return;
        }
        await serviceManager.editService.writeDoc(this.doc?.uuid, doc);
        serviceManager.p2pService
            .sendDocEditMessage(this.doc?.uuid ?? "", data);
      });
    }
  }

  void initYsTree(Doc doc) {
    ysTree = YsTree(
      context: context,
      editController: editController,
      yDoc: doc,
    );
    ysTree!.init();
  }

  void getTextStyle() {
    int? level;
    bool isSameLevel = true;
    editController.visitSelectBlock(
      (block) {
        if (level == null) {
          level = block.element.level;
          return;
        }
        if (block.element.level != level) {
          isSameLevel = false;
        } else {
          level = block.element.level;
        }
      },
      visitCursor: true,
    );
    if (!isSameLevel) {
      level = 0;
    }
    if (level != null) {
      textLevel.value = level!;
    }
  }

  void changeAlignment(String? alignment) {
    editController.setAlignment(alignment);
  }

  void redo() {
    editController.redo();
  }

  void undo() {
    editController.undo();
  }

  void copyContent(BuildContext ctx) {}

  void deleteNote(BuildContext ctx) {}
}
