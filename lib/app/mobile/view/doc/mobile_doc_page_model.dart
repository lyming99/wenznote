import 'package:note/model/note/po/doc_dir_po.dart';
import 'package:note/model/note/po/doc_po.dart';

class MobileDocModel {
  MobileDocModel({
    required this.value,
  });

  dynamic value;

  String get type => "doc";

  String? get uuid => value.uuid;

  String? get name => value.name;

  String getTypeTitle() {
    return "便签";
  }

  String getTimeString() {
    return "";
  }

  bool get isFolder => value is DocDirPO;

  bool get isDoc => value is DocPO;
}
