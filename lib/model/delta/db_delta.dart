import 'package:isar/isar.dart';

part 'db_delta.g.dart';

@collection
class DbDelta {
  Id id = Isar.autoIncrement;
  int? clientId;
  String? dataId;
  String? dataType;
  String? content;
  int? updateTime;
  bool? deleted;
  bool? hasUpload;

  DbDelta({
    this.id = Isar.autoIncrement,
    this.clientId,
    this.dataType,
    this.dataId,
    this.content,
    this.updateTime,
    this.deleted,
    this.hasUpload,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'dataType': dataType,
      'dataId': dataId,
      'content': content,
      'updateTime': updateTime,
      'deleted': deleted,
      'hasUpload': hasUpload,
    };
  }

  factory DbDelta.fromMap(dynamic map) {
    var temp;
    return DbDelta(
      clientId: null == (temp = map['clientId'])
          ? null
          : (temp is num ? temp.toInt() : int.tryParse(temp)),
      dataType: map['dataType']?.toString(),
      dataId: map['dataId']?.toString(),
      content: map['content']?.toString(),
      updateTime: null == (temp = map['updateTime'])
          ? null
          : (temp is num ? temp.toInt() : int.tryParse(temp)),
      deleted: null == (temp = map['deleted'])
          ? null
          : (temp is bool
              ? temp
              : (temp is num
                  ? 0 != temp.toInt()
                  : ('true' == temp.toString()))),
      hasUpload: null == (temp = map['hasUpload'])
          ? null
          : (temp is bool
              ? temp
              : (temp is num
                  ? 0 != temp.toInt()
                  : ('true' == temp.toString()))),
    );
  }
}
