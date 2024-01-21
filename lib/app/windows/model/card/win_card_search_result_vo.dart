import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:wenznote/editor/block/element/element.dart';
import 'package:wenznote/editor/edit_controller.dart';
import 'package:wenznote/editor/edit_widget.dart';
import 'package:wenznote/model/card/po/card_po.dart';
import 'package:wenznote/service/service_manager.dart';

class WinCardSearchResultVO with ChangeNotifier {
  CardPO card;
  List<dynamic>? jsonContent;
  String searchText;
  int elementIndex = 0;
  EditController? editController;
  int? updateTime;

  WinCardSearchResultVO({
    required this.card,
    required this.searchText,
  });

  Future<void> readDoc() async {
    var content = card.content;
    if (content == null || content.isEmpty) {
      return;
    }
    jsonContent = jsonDecode(content);
  }

  Future<bool> search() async {
    var content = jsonContent;
    if (content == null) {
      return false;
    }
    var searchKey = searchText.toLowerCase();
    for (var i = 0; i < content.length; i++) {
      var item = content[i];
      var element = WenElement.parseJson(item);
      var contains = element.getText().toLowerCase().contains(searchKey);
      if (contains) {
        elementIndex = i;
        return true;
      }
    }
    return false;
  }

  void readContent(BuildContext context) {
    var controller = EditController(
      initFocus: false,
      padding: const EdgeInsets.all(20),
      scrollController: ScrollController(),
      reader: () async {
        return jsonContent?.sublist(elementIndex) ?? [];
      },
      editable: false,
      fileManager: ServiceManager.of(context).fileManager,
      copyService: ServiceManager.of(context).copyService,
    );
    controller.searchState.searchKey = searchText;
    editController = controller;
  }

  Widget buildEditWidget(BuildContext context) {
    return IgnorePointer(
      child: ListenableBuilder(
        listenable: this,
        builder: (context, child) {
          return LayoutBuilder(builder: (context, cons) {
            var scale = 1.2;
            if (editController == null) {
              readContent(context);
            }
            return FittedBox(
              child: SizedBox(
                width: cons.maxWidth * scale,
                height: cons.maxHeight * scale,
                child: EditWidget(
                  controller: editController!,
                ),
              ),
            );
          });
        },
      ),
    );
  }
}
