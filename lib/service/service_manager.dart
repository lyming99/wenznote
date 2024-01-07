import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:note/app/windows/service/doc_list/win_doc_list_service.dart';
import 'package:note/app/windows/service/today/win_today_service.dart';
import 'package:note/commons/mvc/controller.dart';
import 'package:note/commons/service/copy_service.dart';
import 'package:note/commons/service/document_manager.dart';
import 'package:note/commons/service/settings_manager.dart';
import 'package:note/service/card/card_service.dart';
import 'package:note/service/card/card_study_service.dart';
import 'package:note/service/crypt/crypt_service.dart';
import 'package:note/service/doc/doc_service.dart';
import 'package:note/service/edit/doc_edit_service.dart';
import 'package:note/service/file/file_manager.dart';
import 'package:note/service/isar/isar_service.dart';
import 'package:note/service/search/search_service.dart';
import 'package:note/service/sync/doc_snapshot_service.dart';
import 'package:note/service/sync/file_sync_service.dart';
import 'package:note/service/sync/p2p_service.dart';
import 'package:note/service/sync/record_sync_service.dart';
import 'package:note/service/sync/upload_task_service.dart';
import 'package:note/service/user/user_service.dart';
import 'package:note/widgets/root_widget.dart';

import 'config/config_manager.dart';

class ServiceManagerController extends MvcController {
  late ServiceManager serviceManager;

  @mustCallSuper
  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    serviceManager = ServiceManager.of(context);
  }

  @override
  @mustCallSuper
  void onDidUpdateWidget(BuildContext context, MvcController oldController) {
    super.onDidUpdateWidget(context, oldController);
    serviceManager = (oldController as ServiceManagerController).serviceManager;
  }
}

class ServiceManager with ChangeNotifier {
  static ServiceManager of(BuildContext context) {
    var state = context.findAncestorStateOfType<ServiceManagerWidgetState>();
    return state!.serviceManager;
  }

  late UserService userService;
  late IsarService isarService;
  late FileManager fileManager;
  late DocEditService editService;
  late DocService docService;
  late CardService cardService;
  late CardStudyService cardStudyService;
  late WinTodayService todayService;
  late CopyService copyService;
  late WinDocListService docListService;
  late SettingsManager settingsManager;
  late DocumentManager documentManager;
  late ConfigManager configManager;
  late RecordSyncService recordSyncService;
  late CryptService cryptService;
  late P2pService p2pService;
  late DocSnapshotService docSnapshotService;
  late UploadTaskService uploadTaskService;
  late FileSyncService fileSyncService;
  late SearchService searchService;
  bool isStart = false;
  int time = DateTime.now().millisecondsSinceEpoch;
  late BuildContext context;

  void onInitState(BuildContext context) {
    isarService = IsarService(this);
    userService = UserService(this);
    fileManager = FileManager(this);
    editService = DocEditService(this);
    docService = DocService(this);
    cardStudyService = CardStudyService(this);
    cardService = CardService(this);
    todayService = WinTodayService(this);
    copyService = CopyService(this);
    docListService = WinDocListService(this);
    settingsManager = SettingsManager(this);
    documentManager = DocumentManager(this);
    configManager = ConfigManager(this);
    recordSyncService = RecordSyncService(this);
    cryptService = CryptService(this);
    p2pService = P2pService(this);
    docSnapshotService = DocSnapshotService(this);
    uploadTaskService = UploadTaskService(this);
    fileSyncService = FileSyncService(this);
    searchService = SearchService(this);
    startService();
  }

  Future<void> startService() async {
    Hive.init("${await fileManager.getRootDir()}/hive");
    await Hive.openBox("settings");
    // await userService.login(email: "44185539@qq.com", password: "12345678");
    await isarService.open();
    isStart = true;
    recordSyncService.startPullTimer();
    p2pService.connect();
    uploadTaskService.startUploadTimer();
    docSnapshotService.startDownloadTimer();
    notifyListeners();
  }

  Future<void> stopService() async {
    await isarService.close();
    p2pService.close();
    recordSyncService.stopPullTimer();
    uploadTaskService.stopUploadTimer();
    docSnapshotService.stopDownloadTimer();
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