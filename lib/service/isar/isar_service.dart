import 'dart:io';

import 'package:isar/isar.dart';
import 'package:note/model/card/po/card_po.dart';
import 'package:note/model/card/po/card_set_po.dart';
import 'package:note/model/card/po/card_study_config_po.dart';
import 'package:note/model/card/po/card_study_queue_po.dart';
import 'package:note/model/card/po/card_study_record_po.dart';
import 'package:note/model/card/po/card_study_score_po.dart';
import 'package:note/model/note/po/doc_dir_po.dart';
import 'package:note/model/note/po/doc_po.dart';
import 'package:note/model/settings/settings_po.dart';
import 'package:note/service/service_manager.dart';
import 'package:note/service/user/user_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';

class IsarService {
  ServiceManager serviceManager;

  var lock = Lock();
  Isar? _documentIsar;

  Isar get documentIsar => _documentIsar!;

  IsarService(this.serviceManager);

  Future<bool> open() async {
    return await lock.synchronized(() async {
      await _documentIsar?.close();
      var dir = await getApplicationDocumentsDirectory();
      var databases = Directory(
          "${dir.path}/WenNote/${serviceManager.userService.userPath}databases");
      databases.createSync(recursive: true);
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
        ],
        directory: databases.path,
        name: "documents",
        maxSizeMiB: 128000,
      );
      return _documentIsar!.isOpen;
    });
  }

  Future<void> close() async {
    await lock.synchronized(() async {
      await _documentIsar?.close();
      _documentIsar = null;
    });
  }
}
