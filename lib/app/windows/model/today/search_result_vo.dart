import 'package:date_format/date_format.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:wenznote/editor/block/block.dart';
import 'package:wenznote/editor/block/block_manager.dart';
import 'package:wenznote/editor/block/element/element.dart';
import 'package:wenznote/editor/crdt/doc_utils.dart';
import 'package:wenznote/editor/edit_controller.dart';
import 'package:wenznote/editor/edit_widget.dart';
import 'package:wenznote/model/note/enum/note_order_type.dart';
import 'package:wenznote/model/note/po/doc_po.dart';
import 'package:wenznote/service/service_manager.dart';
import 'package:ydart/ydart.dart';

class WinTodaySearchResultVO with ChangeNotifier {
  DocPO doc;
  YDoc? docContent;
  String searchText;
  int elementIndex;
  WenElement element;
  EditController? editController;
  int? updateTime;

  WinTodaySearchResultVO({
    required this.doc,
    this.docContent,
    required this.searchText,
    required this.element,
    required this.elementIndex,
  });

  Future<void> updateContent(YDoc? doc) async {
    docContent = doc;
    notifyListeners();
  }

  void readContent(BuildContext context) {
    var elements = getWenElements().map((e) => e.toJson()).toList();
    var controller = EditController(
      initFocus: false,
      padding: EdgeInsets.all(10),
      scrollController: ScrollController(),
      reader: () async {
        return elements;
      },
      editable: false,
      fileManager: ServiceManager.of(context).fileManager,
      copyService: ServiceManager.of(context).copyService,
    );
    controller.searchState.searchKey = searchText;
    editController = controller;
    // 将搜索结果显示出来
    var blocks = getWenBlocks(context, controller);
    controller.blockManager.setBlocks(blocks);
  }

  Widget buildEditWidget(BuildContext context) {
    return ListenableBuilder(
      listenable: this,
      builder: (context, child) {
        return LayoutBuilder(builder: (context, cons) {
          var scale = 1.2;
          readContent(context);
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
    );
  }

  List<WenElement> getWenElements() {
    var result = <WenElement>[];
    var blocks = docContent?.getArray("blocks");
    if (blocks is! YArray) {
      return result;
    }
    for (int i = elementIndex; i < blocks.length && i < elementIndex + 6; i++) {
      var block = blocks.get(i);
      if (block is! YMap) {
        continue;
      }
      var element = createWenElementFromYMap(block);
      if (element == null) {
        continue;
      }
      result.add(element);
    }
    return result;
  }

  List<WenElement> getAllWenElements() {
    var result = <WenElement>[];
    var blocks = docContent?.getArray("blocks");
    if (blocks is! YArray) {
      return result;
    }
    for (int i = 0; i < blocks.length; i++) {
      var block = blocks.get(i);
      if (block is! YMap) {
        continue;
      }
      var element = createWenElementFromYMap(block);
      if (element == null) {
        continue;
      }
      result.add(element);
    }
    return result;
  }

  List<WenBlock> getWenBlocks(BuildContext context, EditController controller) {
    var elements = getWenElements();
    return elements.map((e) {
      return createWenBlock(context, controller, e);
    }).toList();
  }

  String getTypeTitle() {
    switch (doc.type ?? "note") {
      case "note":
        return "便签";
      case "doc":
        return "笔记";
      case "dayNote":
        return "日记";
      default:
        return "便签";
    }
  }

  String getTimeString(
      [OrderProperty? value = OrderProperty.updateTime]) {
    DateTime dateTime;
    if (value == OrderProperty.createTime) {
      var time = doc.createTime ?? 0;
      dateTime = DateTime.fromMillisecondsSinceEpoch(time);
    } else {
      var time = doc.updateTime ?? 0;
      dateTime = DateTime.fromMillisecondsSinceEpoch(time);
    }
    return formatDate(
        dateTime, [yyyy, "-", mm, "-", dd, " ", HH, ":", nn, ":", ss]);
  }

  String getTitleString() {
    var content = docContent;
    if (content != null) {
      var blocks = content.getArray("blocks");
      for (var block in blocks.enumerateList()) {
        if (block is! YMap) {
          continue;
        }
        var type = block.get("level") ?? 0;
        if (type == 0) {
          continue;
        }
        var text = block.get("text");
        if (text is! YText) {
          continue;
        }
        var title = text.toString().trim();
        if (title.isEmpty) {
          continue;
        }
        return title;
      }
    }
    return "${getTypeTitle()} ${getTimeString(OrderProperty.updateTime)}";
  }
}
