import 'dart:io';

import 'package:isar/isar.dart';
import 'package:synchronized/extension.dart';
import 'package:wenznote/model/card/po/card_po.dart';
import 'package:wenznote/model/card/po/card_set_po.dart';
import 'package:wenznote/model/card/po/card_study_config_po.dart';
import 'package:wenznote/model/card/po/card_study_queue_po.dart';
import 'package:wenznote/model/card/po/card_study_record_po.dart';
import 'package:wenznote/model/card/po/card_study_score_po.dart';
import 'package:wenznote/model/delta/db_delta.dart';
import 'package:wenznote/model/file/file_link_po.dart';
import 'package:wenznote/model/file/file_po.dart';
import 'package:wenznote/model/note/po/doc_dir_po.dart';
import 'package:wenznote/model/note/po/doc_po.dart';
import 'package:wenznote/model/note/po/doc_state_po.dart';
import 'package:wenznote/model/note/po/upload_task_po.dart';
import 'package:wenznote/model/settings/settings_po.dart';
import 'package:wenznote/service/service_manager.dart';

class IsarService {
  ServiceManager serviceManager;

  Isar? _documentIsar;

  Isar get documentIsar => _documentIsar!;

  IsarService(this.serviceManager);

  Future<bool> open() async {
    return synchronized(() async {
      if(_documentIsar!=null){
        return true;
      }
      var dir = await serviceManager.fileManager.getSaveDir();
      var databases =
          Directory("$dir/${serviceManager.userService.userPath}databases");
      if (!databases.existsSync()) {
        databases.createSync(recursive: true);
      }
      _documentIsar = await Isar.open(
        [
          DocDirPOSchema,
          DocPOSchema,
          CardSetPOSchema,
          CardPOSchema,
          CardStudyQueuePOSchema,
          CardStudyRecordPOSchema,
          CardStudyScorePOSchema,
          CardStudyConfigPOSchema,
          SettingsPOSchema,
          DbDeltaSchema,
          DocStatePOSchema,
          UploadTaskPOSchema,
          FilePOSchema,
          FileLinkPOSchema,
        ],
        directory: databases.path,
        name: "documents",
        maxSizeMiB: 10000,
      );
      return _documentIsar!.isOpen;
    });
  }

  Future<void> close() async {
    return synchronized(() async {
      var future = _documentIsar?.close();
      _documentIsar = null;
      await future;
    });
  }
}
