import 'dart:math';

import 'package:date_format/date_format.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:wenznote/editor/edit_controller.dart';
import 'package:wenznote/editor/edit_widget.dart';
import 'package:wenznote/model/note/enum/note_order_type.dart';
import 'package:wenznote/model/note/po/doc_po.dart';

import 'mobile_today_controller.dart';

class MobileTodayModel {
  String? uuid;
  DocType type;
  DocPO? doc;
  int createTime;
  int updateTime;
  int reviewTime;
  int readTime;
  int priority;
  String? searchKey;
  List<dynamic>? searchResult;
  var content = Rxn<dynamic>();
  EditController? controller;
  var contentHeight = 400.0.obs;
  var reading = false;
  MobileTodayController todayController;

  MobileTodayModel({
    required this.todayController,
    this.type = DocType.doc,
    this.uuid,
    this.doc,
    this.createTime = 0,
    this.updateTime = 0,
    this.reviewTime = 0,
    this.priority = 0,
    this.readTime = 0,
  });

  void readContent() async {
    if (reading) {
      return;
    }
    reading = true;
    var uuid = doc?.uuid;
    if (uuid == null) {
      content.value = [];
      return;
    }
    if (searchResult != null) {
      content.value = searchResult;
    } else {
      var doc = await todayController.serviceManager.editService.readDoc(uuid);

    }
    controller = EditController(
      initFocus: false,
      editable: false,
      padding: const EdgeInsets.all(20),
      reader: () async {
        return content.value;
      },
      fileManager: todayController.serviceManager.fileManager,
      copyService: todayController.serviceManager.copyService,
    )..searchState.searchKey = searchKey;
    reading = false;
  }

  Widget buildContent(BuildContext context) {
    if (content.value == null) {
      readContent();
      return Container(
        height: min(400, contentHeight.value + 40),
        padding: EdgeInsets.only(bottom: 40, left: 20),
      );
    }
    return IgnorePointer(
      child: NotificationListener<EditContentHeightNotification>(
        onNotification: (event) {
          SchedulerBinding.instance.scheduleFrameCallback((timeStamp) {
            if (contentHeight.value != event.height) {
              contentHeight.value = event.height;
            }
          });
          return false;
        },
        child: Obx(
          () {
            return SizedBox(
              height: max(140, min(400, contentHeight.value + 40)),
              child: EditWidget(
                controller: controller!,
              ),
            );
          },
        ),
      ),
    );
  }

  String getUpdateTime() {
    return formatDate(DateTime.fromMillisecondsSinceEpoch(updateTime),
        [yyyy, '-', mm, '-', dd, " ", HH, ":", nn]);
  }

  String getCreateTime() {
    return formatDate(DateTime.fromMillisecondsSinceEpoch(createTime),
        [yyyy, '-', mm, '-', dd, " ", HH, ":", nn]);
  }

  String getTypeName() {
    switch (type) {
      case DocType.doc:
        return "笔记";
      case DocType.card:
        return "卡片";
      case DocType.important:
        return "重点";
      case DocType.diaryNote:
        return "日记";
      case DocType.tagNote:
        return "便签";
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MobileTodayModel &&
          runtimeType == other.runtimeType &&
          uuid == other.uuid;

  @override
  int get hashCode => uuid.hashCode;

  void clearSearch() {
    searchKey = null;
    searchResult = null;
    readContent();
  }
}
