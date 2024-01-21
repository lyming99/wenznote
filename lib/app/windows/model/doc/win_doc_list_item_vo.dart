import 'package:wenznote/model/note/po/doc_dir_po.dart';
import 'package:wenznote/model/note/po/doc_po.dart';

class WinDocListItemVO {
  Object? item;

  WinDocListItemVO({
    this.item,
  });

  bool get isFolder => item is DocDirPO;

  String? get uuid {
    var item = this.item;
    if (item is DocDirPO) {
      return item.uuid;
    }
    if (item is DocPO) {
      return item.uuid;
    }
    return null;
  }

  DocPO? get doc => (item is DocPO) ? item as DocPO : null;

  DocDirPO? get dir => (item is DocDirPO) ? item as DocDirPO : null;

  String? get name {
    var item = this.item;
    if (item is DocDirPO) {
      if (item.name?.isEmpty == true) {
        return "无标题";
      }
      return item.name;
    }
    if (item is DocPO) {
      if (item.name?.isEmpty == true) {
        return "无标题";
      }
      return item.name;
    }
    return null;
  }
}
