import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:note/model/card/po/card_po.dart';
import 'package:note/model/card/po/card_set_po.dart';
import 'package:note/model/card/po/card_study_config_po.dart';
import 'package:note/model/card/po/card_study_queue_po.dart';
import 'package:note/model/card/po/card_study_record_po.dart';
import 'package:note/model/card/po/card_study_score_po.dart';
import 'package:note/model/delta/db_delta.dart';
import 'package:note/model/file/file_link_po.dart';
import 'package:note/model/file/file_po.dart';
import 'package:note/model/note/po/doc_dir_po.dart';
import 'package:note/model/note/po/doc_po.dart';
import 'package:note/model/note/po/doc_state_po.dart';
import 'package:note/model/note/po/upload_task_po.dart';
import 'package:note/model/settings/settings_po.dart';
import 'package:note/service/service_manager.dart';

class IsarService {
  ServiceManager serviceManager;

  var lock = Lock();
  Isar? _documentIsar;

  Isar get documentIsar => _documentIsar!;

  IsarService(this.serviceManager);

  Future<bool> open() async {
    lock.lock();
    try{
      var dir = await serviceManager.fileManager.getRootDir();
      var databases = Directory(
          "$dir/${serviceManager.userService.userPath}databases");
      if(!databases.existsSync()) {
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
        maxSizeMiB: 128000,
      );
      return _documentIsar!.isOpen;
    }finally{
      lock.unlock();
    }

  }

  Future<void> close() async {
    lock.lock();
    try{
      await _documentIsar?.close();
      _documentIsar = null;
    }finally{
      lock.unlock();
    }
  }
}
