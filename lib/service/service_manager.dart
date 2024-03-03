import 'package:fluent_ui/fluent_ui.dart';
import 'package:hive/hive.dart';
import 'package:synchronized/extension.dart';
import 'package:wenznote/app/windows/service/doc/win_doc_list_service.dart';
import 'package:wenznote/app/windows/service/today/win_today_service.dart';
import 'package:wenznote/commons/mvc/controller.dart';
import 'package:wenznote/commons/service/copy_service.dart';
import 'package:wenznote/commons/service/document_manager.dart';
import 'package:wenznote/commons/service/settings_manager.dart';
import 'package:wenznote/service/card/card_service.dart';
import 'package:wenznote/service/card/card_study_service.dart';
import 'package:wenznote/service/crypt/crypt_service.dart';
import 'package:wenznote/service/doc/doc_service.dart';
import 'package:wenznote/service/edit/doc_edit_service.dart';
import 'package:wenznote/service/file/file_manager.dart';
import 'package:wenznote/service/isar/isar_service.dart';
import 'package:wenznote/service/search/search_service.dart';
import 'package:wenznote/service/sync/doc_snapshot_service.dart';
import 'package:wenznote/service/sync/file_sync_service.dart';
import 'package:wenznote/service/sync/p2p_service.dart';
import 'package:wenznote/service/sync/record_sync_service.dart';
import 'package:wenznote/service/sync/upload_task_service.dart';
import 'package:wenznote/service/user/user_service.dart';
import 'package:wenznote/widgets/root_widget.dart';

import 'config/config_manager.dart';
import 'theme/theme_manager.dart';

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
    serviceManager.context = context;
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
  late ImportService importService;
  late ConfigManager configManager;
  late RecordSyncService recordSyncService;
  late CryptService cryptService;
  late P2pService p2pService;
  late DocSnapshotService docSnapshotService;
  late UploadTaskService uploadTaskService;
  late FileSyncService fileSyncService;
  late SearchService searchService;
  late ThemeManager themeManager;
  bool isStart = false;
  bool _canPop = false;
  int time = DateTime.now().millisecondsSinceEpoch;
  late BuildContext context;

  ServiceManager();

  void onInitState(BuildContext context) {
    this.context = context;
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
    importService = ImportService(this);
    configManager = ConfigManager(this);
    recordSyncService = RecordSyncService(this);
    cryptService = CryptService(this);
    p2pService = P2pService(this);
    docSnapshotService = DocSnapshotService(this);
    uploadTaskService = UploadTaskService(this);
    fileSyncService = FileSyncService(this);
    searchService = SearchService(this);
    themeManager = ThemeManager(this);
  }

  Future<void> startService() async {
    await synchronized(() async {
      if (isStart) {
        return;
      }
      Hive.init("${await fileManager.getRootDir()}/hive");
      await Hive.openBox("settings");
      try {
        await userService.startUserService();
      } catch (e) {
        print(e);
      }
      await isarService.open();
      await themeManager.readConfig();
      p2pService.connect();
      recordSyncService.startPullTimer();
      uploadTaskService.startUploadTimer();
      docSnapshotService.startDownloadTimer();
      isStart = true;
      notifyListeners();
    });
  }

  Future<void> stopService() async {
    await synchronized(() async {
      if (!isStart) {
        return;
      }
      await Hive.close();
      await isarService.close();
      p2pService.close();
      recordSyncService.stopPullTimer();
      uploadTaskService.stopUploadTimer();
      docSnapshotService.stopDownloadTimer();
      isStart = false;
    });
  }

  bool canPop() {
    if (_canPop) {
      _canPop = false;
      return true;
    }
    return _canPop;
  }

  void setCanPopOnce() {
    _canPop = true;
  }
}
