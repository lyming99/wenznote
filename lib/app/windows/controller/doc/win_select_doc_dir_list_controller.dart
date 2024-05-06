import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wenznote/app/windows/model/doc/win_doc_list_item_vo.dart';
import 'package:wenznote/app/windows/service/doc/win_doc_list_service.dart';
import 'package:wenznote/commons/mvc/controller.dart';
import 'package:wenznote/model/note/po/doc_dir_po.dart';
import 'package:wenznote/model/note/po/doc_po.dart';
import 'package:wenznote/service/doc/doc_service.dart';
import 'package:wenznote/service/service_manager.dart';

class WinSelectDocDirListController extends MvcController {
  bool Function(List<DocDirPO> dir)? dirFilter;
  late WinDocListService docListService;
  late DocService docService;

  String? docDirUuid;
  var pathList = RxList<DocDirPO>();
  var docList = RxList<WinDocListItemVO>();
  var selectItem = Rxn<WinDocListItemVO>();
  var canMoveHear = false.obs;
  StreamSubscription? subscription;

  WinSelectDocDirListController({
    this.docDirUuid,
    this.dirFilter,
  });

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    docListService = ServiceManager.of(context).docListService;
    docService = ServiceManager.of(context).docService;
    fetchData();
    // subscription =
    //     docService.documentIsar.docDirPOs.watchLazy().listen((event) {
    //   queryDirList();
    // });
    // subscription = docService.documentIsar.docPOs.watchLazy().listen((event) {
    //   queryDirList();
    // });
  }

  void fetchData() async {
    await queryPathList();
    await queryDirList();
  }

  Future<void> queryDirList() async {
    var dirAndDocList = await docListService.queryDirList(docDirUuid);
    var itemList = dirAndDocList.map((e) => WinDocListItemVO(item: e)).toList();
    docList.value = itemList;
  }

  Future<void> queryPathList() async {
    pathList.value = await docListService.queryPath(docDirUuid);
    var filter = dirFilter;
    if (filter != null) {
      canMoveHear.value = filter.call(pathList);
    } else {
      canMoveHear.value = true;
    }
  }

  void openDirectory(BuildContext context, String? uuid,
      [bool restore = false]) {
    var routeName = uuid ?? "/";
    if (restore) {
      Navigator.of(context).popUntil((item) {
        return item.settings.name == routeName || item.settings.name == "/";
      });
      return;
    }
    Navigator.of(context).restorablePushNamed(routeName);
  }

  void openDocOrDirectory(
    BuildContext context,
    WinDocListItemVO docItem,
  ) {
    if (docItem.isFolder) {
      openDirectory(context, docItem.uuid);
    }
  }

  Future<void> createDirectory(BuildContext context, String text) async {
    await docListService.createDirectory(docDirUuid, text);
  }

  @override
  void onDispose() {
    super.onDispose();
    subscription?.cancel();
  }
}
