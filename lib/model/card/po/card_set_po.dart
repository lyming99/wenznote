import 'package:isar/isar.dart';

part 'card_set_po.g.dart';

@collection
class CardSetPO {
  Id id;
  String? uid;
  String? uuid;
  String? did;
  String? createBy;
  String? updateBy;
  int? createTime;
  int? updateTime;

  String? type;
  String? name;
  int? color;

  CardSetPO({
    this.id = Isar.autoIncrement,
    this.uid,
    this.uuid,
    this.did,
    this.createBy,
    this.updateBy,
    this.createTime,
    this.updateTime,
    this.type,
    this.name,
    this.color,
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
      'name': this.name,
      'color': this.color,
    };
  }

  factory CardSetPO.fromMap(Map<String, dynamic> map) {
    return CardSetPO(
      uid: map['uid'],
      uuid: map['uuid'],
      did: map['did'],
      createBy: map['createBy'],
      updateBy: map['updateBy'],
      createTime: map['createTime'],
      updateTime: map['updateTime'],
      type: map['type'],
      name: map['name'],
      color: map['color'],
    );
  }
}
