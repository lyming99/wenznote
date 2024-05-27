import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:get/get.dart';
import 'package:wenznote/editor/block/element/element.dart';
import 'package:wenznote/editor/block/text/text.dart';
import 'package:wenznote/editor/crdt/doc_utils.dart';
import 'package:wenznote/model/card/po/card_po.dart';
import 'package:wenznote/model/card/po/card_set_po.dart';
import 'package:wenznote/model/note/po/doc_po.dart';
import 'package:wenznote/service/card/card_service.dart';
import 'package:wenznote/service/service_manager.dart';
import 'package:uuid/uuid.dart';

void showGenerateCardDialog(
    BuildContext context, String cardName, List<DocPO> docList) async {
  List<String> cats = ["标题1", "标题2", "标题3", "标题4", "标题5", "标题6"];
  var splitTitle = "标题2".obs;
  var cardNameController = TextEditingController(text: cardName);
  showDialog(
    context: context,
    builder: (context) {
      return Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: fluent.ContentDialog(
          constraints: BoxConstraints(maxWidth: 300),
          title: Text("制作卡片"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Text("分割类型: "),
                  Expanded(
                      child: Obx(
                    () => fluent.ComboBox<String>(
                      placeholder: Text("请选择分割类型       "),
                      value: splitTitle.value,
                      items: cats.map<fluent.ComboBoxItem<String>>((e) {
                        return fluent.ComboBoxItem<String>(
                          child: Text(e),
                          value: e,
                        );
                      }).toList(),
                      onChanged: (val) {
                        splitTitle.value = val ?? "";
                      },
                    ),
                  )),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Text("卡片名称: "),
                  Expanded(
                    child: fluent.TextBox(
                      controller: cardNameController,
                      placeholder: "请输入卡片名称",
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
          actions: [
            fluent.Button(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("取消"),
            ),
            fluent.FilledButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await showDialog(
                    useSafeArea: true,
                    context: context,
                    builder: (context) => FutureProgressDialog(
                          message: const Text("正在生成中..."),
                          () async {
                            await _generateCard(
                                context,
                                cardNameController.text,
                                docList,
                                splitTitle.value);
                          }(),
                        ));
              },
              child: Text("开始制作"),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _generateCard(
  BuildContext context,
  String cardName,
  List<DocPO> docList,
  String? splitTitle,
) async {
  int level = 2;
  switch (splitTitle) {
    case "标题1":
      level = 1;
      break;
    case "标题2":
      level = 2;
      break;
    case "标题3":
      level = 3;
      break;
    case "标题4":
      level = 4;
      break;
    case "标题5":
      level = 5;
      break;
    case "标题6":
      level = 6;
      break;
  }
  var cardSet = CardSetPO(
    name: cardName,
    uuid: const Uuid().v1(),
    createTime: DateTime.now().millisecondsSinceEpoch,
    updateTime: DateTime.now().millisecondsSinceEpoch,
  );
  var serviceManager = ServiceManager.of(context);
  var editService = serviceManager.editService;
  await serviceManager.cardService.createCardSet(cardSet);
  for (var doc in docList) {
    var yDoc = await editService.readDoc(doc.uuid);
    if (yDoc == null) {
      continue;
    }
    List<CardPO> saveList = [];
    var elements = yDocToWenElements(yDoc);
    var current = <WenElement>[];
    for (var element in elements) {
      if (element is WenTextElement) {
        if (element.level == level) {
          //创建卡片
          await createCard(
              serviceManager.cardService, cardSet, saveList, current);
          current = [];
        } else if (element.level != 0 && element.level < level) {
          continue;
        }
      }
      current.add(element);
    }
    await createCard(serviceManager.cardService, cardSet, saveList, current);
    if (saveList.isNotEmpty) {
      await serviceManager.cardService.insertCards(cardSet.uuid, saveList);
      saveList.clear();
    }
  }
}

Future<void> createCard(CardService cardService, CardSetPO set,
    List<CardPO> saveList, List<WenElement> content) async {
  if (content.isEmpty) {
    return;
  }
  var jsonContent = jsonEncode(content.map((e) => e.toJson()).toList());
  var uuid = const Uuid().v1();
  saveList.add(CardPO(
    uuid: uuid,
    cardSetId: set.uuid,
    content: jsonContent,
    createTime: DateTime.now().millisecondsSinceEpoch,
    updateTime: DateTime.now().millisecondsSinceEpoch,
  ));
  if (saveList.length > 1000) {
    await cardService.insertCards(set.uuid, saveList);
    saveList.clear();
  }
}
