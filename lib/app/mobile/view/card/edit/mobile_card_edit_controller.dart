import 'dart:convert';

import 'package:flutter_crdt/flutter_crdt.dart';
import 'package:note/app/mobile/view/edit/doc_edit_controller.dart';
import 'package:note/editor/block/element/element.dart';
import 'package:note/model/card/po/card_po.dart';

class MobileCardEditController extends MobileDocEditController {
  CardPO card;

  MobileCardEditController({
    required this.card,
    super.editOnOpen,
  });

  Future<Doc> jsonToDoc(String? json) async {
    Doc doc = Doc();
    var blocks = doc.getArray("blocks");
    if (json == null || json.isEmpty) {
      return doc;
    }
    var jsonArray = jsonDecode(json);
    if (jsonArray is! List) {
      return doc;
    }
    var elements = jsonArray
        .map((e) => WenElement.parseJson(e))
        .map((e) => e.getYMap())
        .toList();
    blocks.insert(0, elements);
    return doc;
  }

  Future<String?> getDocJson() async {
    var json = editController.blockManager.getSaveContentJson();
    return jsonEncode(json);
  }

  @override
  Future<void> readDoc() async {
    title.value = "编辑卡片";
    var doc = await jsonToDoc(card.content??"[]");
    initYsTree(doc);
    editController.waitLayout(() {
      editController.requestFocus();
    });

    doc.on("update", (args) async {
      card.content = await getDocJson();
      await serviceManager.cardService.updateCard(card);
    });
  }
}
