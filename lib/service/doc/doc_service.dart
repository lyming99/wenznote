import 'package:fluent_ui/fluent_ui.dart';
import 'package:isar/isar.dart';
import 'package:wenznote/model/note/enum/note_type.dart';
import 'package:wenznote/model/note/po/doc_dir_po.dart';
import 'package:wenznote/model/note/po/doc_po.dart';
import 'package:wenznote/service/isar/isar_service_mixin.dart';
import 'package:wenznote/service/service_manager.dart';
import 'package:uuid/uuid.dart';

class DocService with IsarServiceMixin, ChangeNotifier {
  @override
  ServiceManager serviceManager;

  DocService(this.serviceManager);

  Future<void> createDoc(DocPO doc) async {
    doc.uuid ??= const Uuid().v1();
    doc.createTime = doc.updateTime = DateTime.now().millisecondsSinceEpoch;
    await upsertDbDelta(
        dataId: doc.uuid!, dataType: "note", properties: doc.toMap());
    await documentIsar.writeTxn(() async {
      await documentIsar.docPOs.put(doc);
    });
  }

  Future<void> deleteDoc(DocPO doc) async {
    await deleteDbDelta([doc.uuid!]);
    var isar = documentIsar;
    await isar.writeTxn(() async {
      await isar.docPOs.delete(doc.id);
    });
  }

  Future<void> updateDoc(DocPO doc, {bool uploadNow = true}) async {
    var oldItem = await documentIsar.docPOs.get(doc.id);
    await upsertDbDelta(
        dataId: doc.uuid!,
        dataType: "note",
        properties: diffMap((oldItem ?? DocPO()).toMap(), doc.toMap()));
    await documentIsar.writeTxn(() async {
      await documentIsar.docPOs.put(doc);
    });
  }

  Future<String> getDocName(int id) async {
    return (await documentIsar.docPOs.get(id))?.name ?? "";
  }

  Future<DocPO?> queryDoc(String? uuid) async {
    return await documentIsar.docPOs.filter().uuidEqualTo(uuid).findFirst();
  }

  Future<void> deleteDocReally(String? uuid) async {
    if (uuid == null) {
      return;
    }
    await deleteDbDelta([uuid]);
    await documentIsar.writeTxn(() async {
      await documentIsar.docPOs.filter().uuidEqualTo(uuid).deleteFirst();
    });
    serviceManager.editService.deleteDocFile(uuid);
  }

  Future<List<DocDirPO>> queryDocDirList(String? uuid) async {
    return await documentIsar.docDirPOs.filter().uuidEqualTo(uuid).findAll();
  }

  Future<List<DocDirPO>> queryAllDocDirList() async {
    return documentIsar.docDirPOs.where().findAll();
  }

  Future<List<DocPO>> queryAllDocList() async {
    return documentIsar.docPOs.filter().typeEqualTo("doc").findAll();
  }

  Future<List<DocPO>> queryDocAndNoteList() async {
    return documentIsar.docPOs.where().findAll();
  }

  Future<void> createDocDir(DocDirPO docDir) async {
    docDir.uuid ??= const Uuid().v1();
    docDir.updateTime = DateTime.now().millisecondsSinceEpoch;
    docDir.createTime = DateTime.now().millisecondsSinceEpoch;
    await upsertDbDelta(
      dataId: docDir.uuid!,
      dataType: "dir",
      properties: docDir.toMap(),
    );
    await documentIsar.writeTxn(() async {
      await documentIsar.docDirPOs.put(docDir);
    });
  }

  Future<void> updateDocDir(DocDirPO docDir) async {
    var oldItem = (await documentIsar.docPOs.get(docDir.id))?.toMap() ?? {};
    await upsertDbDelta(
      dataId: docDir.uuid!,
      dataType: "dir",
      properties: diffMap(oldItem, docDir.toMap()),
    );
    await documentIsar.writeTxn(() async {
      await documentIsar.docDirPOs.put(docDir);
    });
  }

  Future<void> deleteDir(String? uuid) async {
    if (uuid == null) {
      return;
    }
    await deleteDbDelta([uuid]);
    await documentIsar.writeTxn(() async {
      await documentIsar.docDirPOs.filter().uuidEqualTo(uuid).deleteFirst();
    });
  }

  Future<List> queryDirAndDocList(String? uuid) async {
    var result = [];
    var dirList = await documentIsar.docDirPOs
        .filter()
        .pidEqualTo(uuid)
        .sortByCreateTime()
        .findAll();
    result.addAll(dirList);
    var docList = await documentIsar.docPOs
        .filter()
        .pidEqualTo(uuid)
        .and()
        .typeEqualTo(NoteType.doc.name)
        .sortByCreateTime()
        .findAll();
    result.addAll(docList);
    return result;
  }

  Future<List<dynamic>> queryDirList(String? uuid) async {
    return await documentIsar.docDirPOs
        .filter()
        .pidEqualTo(uuid)
        .sortByCreateTime()
        .findAll();
  }

  Future<List<DocDirPO>> queryPath(String? uuid) async {
    var result = [DocDirPO(name: "我的笔记")];
    if (uuid == null) {
      return result;
    }
    var current =
        await documentIsar.docDirPOs.filter().uuidEqualTo(uuid).findFirst();
    while (current != null) {
      result.insert(1, current);
      if (current.pid == null) {
        break;
      }
      current = await documentIsar.docDirPOs
          .filter()
          .uuidEqualTo(current.pid)
          .findFirst();
    }
    return result;
  }
}
