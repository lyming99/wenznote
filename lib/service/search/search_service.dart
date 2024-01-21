import 'dart:collection';

import 'package:flutter_crdt/flutter_crdt.dart';
import 'package:isar/isar.dart';
import 'package:wenznote/editor/block/element/element.dart';
import 'package:wenznote/editor/crdt/doc_utils.dart';
import 'package:wenznote/model/note/po/doc_dir_po.dart';
import 'package:wenznote/model/note/po/doc_po.dart';
import 'package:wenznote/model/task/task.dart';
import 'package:wenznote/service/isar/isar_service_mixin.dart';
import 'package:wenznote/service/search/search_result_vo.dart';
import 'package:wenznote/service/service_manager.dart';

class SearchService with IsarServiceMixin {
  @override
  ServiceManager serviceManager;

  BaseTask? searchTask;

  SearchService(this.serviceManager);

  void searchDoc({
    String? pid,
    String? type,
    required String text,
    required Function(DocPO doc, List<SearchResultVO> result) callback,
    Function? onEnd,
    int maxElementCount = 1,
  }) async {
    searchTask?.cancel = true;
    searchTask = BaseTask.start((BaseTask task) async {
      try {
        if (pid == null) {
          List<DocPO> docList;
          if (type != null) {
            docList =
                await documentIsar.docPOs.filter().typeEqualTo(type).findAll();
          } else {
            docList = await documentIsar.docPOs.where().findAll();
          }
          await searchDocListContent(docList, task, text, callback);
        } else {
          Queue<String> pidQueue = Queue();
          pidQueue.addLast(pid);
          while (pidQueue.isNotEmpty) {
            if (task.cancel) {
              break;
            }
            var pid = pidQueue.removeFirst();
            var filter = documentIsar.docPOs.filter().pidEqualTo(pid);
            if (type != null) {
              filter = filter.typeEqualTo(type);
            }
            var docList = await filter.findAll();
            if (task.cancel) {
              break;
            }
            await searchDocListContent(docList, task, text, callback);
            if (task.cancel) {
              break;
            }
            var nextList = await documentIsar.docDirPOs
                .filter()
                .pidEqualTo(pid)
                .uuidProperty()
                .findAll();
            for (var next in nextList) {
              if (next == null) {
                continue;
              }
              pidQueue.addLast(next);
            }
          }
        }
      } finally {
        onEnd?.call();
      }
    });
  }

  Future<void> searchDocListContent(
      List<DocPO> docList,
      BaseTask task,
      String text,
      Function(DocPO doc, List<SearchResultVO> result) callback) async {
    for (var doc in docList) {
      if (task.cancel) {
        break;
      }
      //对doc进行搜索
      var searchResult = await searchDocContent(doc, text);
      if (!task.cancel) {
        callback.call(doc, searchResult);
      }
    }
  }

  /// 搜索包含字符串的文档
  Future<List<SearchResultVO>> searchDocContent(DocPO doc, String searchContent,
      [int searchCount = 1]) async {
    List<SearchResultVO> result = [];
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
      result.add(SearchResultVO(
        doc: doc,
        docContent: docContent,
        searchText: searchContent,
        element: searchResult,
        elementIndex: index,
      ));
      if (searchCount == -1 || result.length >= searchCount) {
        break;
      }
    }
    return result;
  }

  Future<WenElement?> searchElement(
      YMap<dynamic> map, String searchContent) async {
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
}
