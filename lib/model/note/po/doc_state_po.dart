import 'package:isar/isar.dart';

part 'doc_state_po.g.dart';

@collection
class DocStatePO {
  Id id = Isar.autoIncrement;
  String? docId;
  int? clientId;
  int? updateTime;

  DocStatePO({
    this.id = Isar.autoIncrement,
    this.docId,
    this.clientId,
    this.updateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'docId': this.docId,
      'clientId': this.clientId,
      'updateTime': this.updateTime,
    };
  }

  factory DocStatePO.fromMap(Map<String, dynamic> map) {
    return DocStatePO(
      docId: map['docId'] as String?,
      clientId: map['clientId'] as int?,
      updateTime: map['updateTime'] as int?,
    );
  }
}
