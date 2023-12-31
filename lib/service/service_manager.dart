import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:note/app/windows/service/doc_list/win_doc_list_service.dart';
import 'package:note/app/windows/service/today/win_today_service.dart';
import 'package:note/commons/service/copy_service.dart';
import 'package:note/commons/service/document_manager.dart';
import 'package:note/commons/service/file_manager.dart';
import 'package:note/commons/service/settings_manager.dart';
import 'package:note/service/card/card_service.dart';
import 'package:note/service/card/card_study_service.dart';
import 'package:note/service/crypt/crypt_service.dart';
import 'package:note/service/sync/doc_snapshot_service.dart';
import 'package:note/service/sync/p2p_service.dart';
import 'package:note/service/doc/doc_service.dart';
import 'package:note/service/file/wen_file_service.dart';
import 'package:note/service/isar/isar_service.dart';
import 'package:note/service/sync/sync_service.dart';
import 'package:note/service/user/user_service.dart';
import 'package:note/widgets/root_widget.dart';

import 'config/config_manager.dart';

class ServiceManager with ChangeNotifier {
  static ServiceManager of(BuildContext context) {
    var state = context.findAncestorStateOfType<ServiceManagerWidgetState>();
    return state!.serviceManager;
  }

  late UserService userService;
  late IsarService isarService;
  late FileManager fileManager;
  late WenFileService wenFileService;
  late DocService docService;
  late CardService cardService;
  late CardStudyService cardStudyService;
  late WinTodayService todayService;
  late CopyService copyService;
  late WinDocListService docListService;
  late SettingsManager settingsManager;
  late DocumentManager documentManager;
  late ConfigManager configManager;
  late SyncService syncService;
  late CryptService cryptService;
  late P2pService p2pService;
  late DocSnapshotService docSnapshotService;
  bool isStart = false;
  int time = DateTime.now().millisecondsSinceEpoch;
  late BuildContext context;

  void onInitState(BuildContext context) {
    isarService = IsarService(this);
    userService = UserService(this);
    fileManager = FileManager(this);
    wenFileService = WenFileService(this);
    docService = DocService(this);
    cardStudyService = CardStudyService(this);
    cardService = CardService(this);
    todayService = WinTodayService(this);
    copyService = CopyService(this);
    docListService = WinDocListService(this);
    settingsManager = SettingsManager(this);
    documentManager = DocumentManager(this);
    configManager = ConfigManager(this);
    syncService = SyncService(this);
    cryptService = CryptService(this);
    p2pService = P2pService(this);
    docSnapshotService = DocSnapshotService(this);
    startService();
  }

  Future<void> startService() async {
    await isarService.open();
    isStart = true;
    syncService.startPullTimer();
    p2pService.connect();
    notifyListeners();
  }

  Future<void> stopService() async {
    await isarService.close();
    isStart = false;
    notifyListeners();
  }

  Future<void> restartService() async {
    await isarService.close();
    isStart = false;
    Get.offAllNamed("/");
    notifyListeners();
    startService();
  }
}
