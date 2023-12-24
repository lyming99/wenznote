import 'package:isar/isar.dart';
import 'package:note/commons/util/json_compare_utils.dart';
import 'package:note/model/note/po/doc_dir_po.dart';
import 'package:note/model/note/po/doc_po.dart';
import 'package:note/service/file/wen_file_service.dart';
import 'package:note/service/isar/isar_service_mixin.dart';
import 'package:note/service/service_manager.dart';
import 'package:note/service/user/user_service.dart';
import 'package:uuid/uuid.dart';

class DocService with IsarServiceMixin {
  @override
  ServiceManager serviceManager;

  DocService(this.serviceManager);

  Future<void> createDoc(DocPO doc) async {
    doc.uuid ??= const Uuid().v1();
    doc.createTime = doc.updateTime = DateTime.now().millisecondsSinceEpoch;
    await documentIsar.writeTxn(() async {
      await documentIsar.docPOs.put(doc);
    });
  }

  Future<void> deleteDoc(DocPO doc) async {
    var isar = documentIsar;
    await isar.writeTxn(() async {
      await isar.docPOs.delete(doc.id);
    });
  }

  Future<void> updateDoc(DocPO doc) async {
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
    await documentIsar.writeTxn(() async {
      await documentIsar.docPOs.filter().uuidEqualTo(uuid).deleteFirst();
    });
    serviceManager.wenFileService.deleteDoc(uuid);
  }

  Future<List<DocDirPO>> queryDocDirList(String? uuid) async {
    return await documentIsar.docDirPOs.filter().uuidEqualTo(uuid).findAll();
  }

  Future<void> createDocDir(DocDirPO docDir) async {
    docDir.uuid ??= const Uuid().v1();
    docDir.updateTime = DateTime.now().millisecondsSinceEpoch;
    docDir.createTime = DateTime.now().millisecondsSinceEpoch;
    await documentIsar.writeTxn(() async {
      await documentIsar.docDirPOs.put(docDir);
    });
  }

  Future<List<DocDirPO>> queryAllDocDirList() async {
    return documentIsar.docDirPOs.where().findAll();
  }

  Future<List<DocPO>> queryAllDocList() async {
    return documentIsar.docPOs.filter().typeEqualTo("doc").findAll();
  }

  Future<void> deleteDir(String? uuid) async {
    await documentIsar.writeTxn(() async {
      await documentIsar.docDirPOs.filter().uuidEqualTo(uuid).deleteFirst();
    });
  }

  Future<void> updateDocDir(DocDirPO docDir) async {
    var origin = (await documentIsar.docPOs.get(docDir.id))?.toMap() ?? {};
    var delta = getJsonDiff1(origin, docDir.toMap());
    await documentIsar.writeTxn(() async {
      await documentIsar.docDirPOs.put(docDir);
    });
  }
}
