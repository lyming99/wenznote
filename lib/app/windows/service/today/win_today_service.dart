import 'package:isar/isar.dart';
import 'package:wenznote/app/windows/model/today/search_result_vo.dart';
import 'package:wenznote/editor/block/element/element.dart';
import 'package:wenznote/editor/crdt/doc_utils.dart';
import 'package:wenznote/model/note/enum/note_order_type.dart';
import 'package:wenznote/model/note/enum/note_type.dart';
import 'package:wenznote/model/note/po/doc_po.dart';
import 'package:wenznote/service/isar/isar_service_mixin.dart';
import 'package:wenznote/service/service_manager.dart';
import 'package:ydart/ydart.dart';

class WinTodayService with IsarServiceMixin {
  @override
  ServiceManager serviceManager;

  WinTodayService(this.serviceManager);

  /// 查询文档列表
  Future<List<DocPO>> queryDocList(
    List<NoteType> types, [
    OrderProperty orderProperty = OrderProperty.updateTime,
  ]) async {
    if (types.isEmpty) {
      var result = (await documentIsar.docPOs.where().findAll());
      return result;
    }
    var dao = documentIsar.docPOs;
    List<DocPO> result = [];
    for (var type in types) {
      var find = await dao.filter().typeEqualTo(type.name).findAll();
      result.addAll(find);
    }
    return result;
  }

  /// 搜索包含字符串的文档
  Future<List<WinTodaySearchResultVO>> searchDocContent(
      DocPO doc, String searchContent,
      [int searchCount = 1]) async {
    List<WinTodaySearchResultVO> result = [];
    var docContent = await serviceManager.editService.readDoc(doc.uuid);
    if (docContent == null) {
      return result;
    }
    var blocks = docContent.getArray("blocks");
    for (var index = 0; index < blocks.length; index++) {
      var value = blocks.get(index);
      if (value is! YMap) {
        continue;
      }
      var searchResult = await searchElement(value, searchContent);
      if (searchResult == null) {
        continue;
      }
      result.add(WinTodaySearchResultVO(
        doc: doc,
        docContent: docContent,
        searchText: searchContent,
        element: searchResult,
        elementIndex: index,
      ));
      if (searchCount == -1 || result.length > -searchCount) {
        break;
      }
    }
    return result;
  }

  Future<WenElement?> searchElement(
      YMap map, String searchContent) async {
    var element = createWenElementFromYMap(map);
    if (searchContent.isEmpty) {
      return element;
    }
    if (element
            ?.getText()
            .toLowerCase()
            .contains(searchContent.toLowerCase()) ==
        true) {
      return element;
    }
    return null;
  }

  Future<void> deleteNote(DocPO doc) async {
    await serviceManager.docService.deleteDoc(doc);
  }

  Future<void> updateDoc(DocPO doc) async {
    await serviceManager.docService.updateDoc(doc);
  }
}
