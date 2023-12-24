import 'package:isar/isar.dart';

part 'card_po.g.dart';
@collection
class CardPO {
  Id id;
  String? uid;
  String? uuid;
  String? did;
  String? createBy;
  String? updateBy;
  int? createTime;
  int? updateTime;

  String? type;
  String? cardSetId;
  String? content;
  String? sourceId;

  CardPO({
    this.id = Isar.autoIncrement,
    this.uid,
    this.uuid,
    this.did,
    this.createBy,
    this.updateBy,
    this.createTime,
    this.updateTime,
    this.type,
    this.cardSetId,
    this.content,
    this.sourceId,
  });
}
