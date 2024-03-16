import '../service/service_manager.dart';

Future<void> testService()async{
  var sm = ServiceManager();
  sm.init();
  await sm.startService();
  sm.recordSyncService.pullDbData(pullAll: true);
}