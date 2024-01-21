import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:wenznote/commons/mvc/view.dart';
import 'package:wenznote/model/note/po/doc_po.dart';
import 'package:wenznote/service/service_manager.dart';

class DocTitleController extends ServiceManagerController {
  var title = "".obs;
  DocPO? doc;
  StreamSubscription? listener;

  DocTitleController(this.doc);

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    updateTitle();
    listener = serviceManager.isarService.documentIsar.docPOs
        .filter()
        .uuidEqualTo(doc?.uuid)
        .watch()
        .listen((event) {
      if (event.isNotEmpty) {
        doc = event.first;
      } else {
        doc = null;
      }
      updateTitle();
    });
  }

  @override
  void onDispose() {
    super.onDispose();
    listener?.cancel();
    listener = null;
  }

  void updateTitle() {
    if (doc == null) {
      this.title.value = "文件已删除";
      return;
    }
    var title = doc?.name ?? "";
    if (title.isEmpty) {
      if (doc?.type == "note") {
        title = "便签";
      } else {
        title = "笔记-未命名";
      }
    }
    this.title.value = title;
  }
}

class DocTitleWidget extends MvcView<DocTitleController> {
  const DocTitleWidget({super.key, required super.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Text(controller.title.value));
  }
}
