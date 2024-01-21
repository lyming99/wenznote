import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wenznote/commons/util/platform_util.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

void showWarningDialog(BuildContext context) {
  showMobileDialog(
      context: context,
      builder: (context) {
        return fluent.ContentDialog(
          constraints: BoxConstraints(
            maxWidth: 300,
          ),
          title: Text("提示"),
          content: Text("软件功能建设中,敬请期待..."),
          actions: [
            fluent.FilledButton(
              onPressed: () {
                Get.back();
              },
              child: Text("知道了"),
            ),
            fluent.Button(
              onPressed: () {
                Get.back();
              },
              child: Text("好的"),
            ),
          ],
        );
      });
}
