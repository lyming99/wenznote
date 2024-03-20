import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wenznote/editor/block/element/element.dart';
import 'package:wenznote/editor/crdt/YsEditController.dart';
import 'package:wenznote/editor/crdt/YsTree.dart';
import 'package:wenznote/editor/edit_widget.dart';
import 'package:wenznote/model/card/po/card_po.dart';
import 'package:ydart/ydart.dart';

class CardEditor extends StatefulWidget {
  final CardPO card;
  final YsEditController editController;
  final Function(YDoc? doc)? onCardUpdate;

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
  YsTree? ysTree;

  @override
  void initState() {
    super.initState();
    readDoc();
  }

  @override
  void dispose() {
    super.dispose();
    ysTree?.dispose();
  }

  Future<YDoc> jsonToDoc(String? json) async {
    YDoc doc = YDoc();
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
    var json = ysTree?.editController.blockManager.getSaveContentJson();
    if (json != null) {
      return jsonEncode(json);
    }
    return null;
  }

  Future<void> readDoc() async {
    var doc = await jsonToDoc(widget.card.content);
    widget.editController.viewContext = context;
    ysTree = YsTree(
      context: context,
      editController: widget.editController,
      yDoc: doc,
    );
    ysTree!.init();
    doc.updateV2['update'] = ((data, origin, transaction) async {
      var json = await getJson();
      widget.card.content = json;
      widget.onCardUpdate?.call(doc);
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (ysTree == null) {
      return Container();
    }
    return EditWidget(
      controller: ysTree!.editController,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
