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

  Map<String, dynamic> toMap() {
    return {
      'uid': this.uid,
      'uuid': this.uuid,
      'did': this.did,
      'createBy': this.createBy,
      'updateBy': this.updateBy,
      'createTime': this.createTime,
      'updateTime': this.updateTime,
      'type': this.type,
      'cardSetId': this.cardSetId,
      'content': this.content,
      'sourceId': this.sourceId,
    };
  }

  factory CardPO.fromMap(Map<String, dynamic> map) {
    return CardPO(
      uid: map['uid'] as String?,
      uuid: map['uuid'] as String?,
      did: map['did'] as String?,
      createBy: map['createBy'] as String?,
      updateBy: map['updateBy'] as String?,
      createTime: map['createTime'] as int?,
      updateTime: map['updateTime'] as int?,
      type: map['type'] as String?,
      cardSetId: map['cardSetId'] as String?,
      content: map['content'] as String?,
      sourceId: map['sourceId'] as String?,
    );
  }
}
