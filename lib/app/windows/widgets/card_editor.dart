import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_crdt/flutter_crdt.dart';
import 'package:note/editor/block/element/element.dart';
import 'package:note/editor/crdt/YsEditController.dart';
import 'package:note/editor/crdt/YsTree.dart';
import 'package:note/editor/edit_widget.dart';
import 'package:note/model/card/po/card_po.dart';

class CardEditor extends StatefulWidget {
  final CardPO card;
  final YsEditController editController;
  final Function(Doc? doc)? onCardUpdate;

  const CardEditor({
    Key? key,
    required this.card,
    required this.editController,
    this.onCardUpdate,
  }) : super(key: key);

  @override
  State<CardEditor> createState() => _CardEditorState();
}

class _CardEditorState extends State<CardEditor>
    with AutomaticKeepAliveClientMixin {
  YsTree? tree;

  @override
  void initState() {
    super.initState();
    readDoc();
  }

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

  Future<String?> getJson() async {
    var json = tree?.editController.blockManager.getSaveContentJson();
    if (json != null) {
      return jsonEncode(json);
    }
    return null;
  }

  Future<void> readDoc() async {
    var doc = await jsonToDoc(widget.card.content);
    widget.editController.viewContext = context;
    tree = YsTree(
      context: context,
      editController: widget.editController,
      yDoc: doc,
    );
    tree!.init();
    doc.on("update", (args) async {
      var json = await getJson();
      widget.card.content = json;
      widget.onCardUpdate?.call(doc);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (tree == null) {
      return Container();
    }
    return EditWidget(controller: tree!.editController);
  }

  @override
  bool get wantKeepAlive => true;
}
