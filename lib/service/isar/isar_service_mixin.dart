import 'package:isar/isar.dart';
import 'package:note/service/service_manager.dart';


mixin IsarServiceMixin {
  ServiceManager get serviceManager;

  Isar get documentIsar => serviceManager.isarService.documentIsar;
}
