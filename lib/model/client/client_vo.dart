class ClientVO {
  int?id;
  int? uid;
  String? clientType;
  String? systemType;
  String?systemVersion;
  int? createTime;

  ClientVO({
    this.id,
    this.uid,
    this.clientType,
    this.systemType,
    this.systemVersion,
    this.createTime,
  });

  factory ClientVO.fromMap(dynamic map) {
    var temp;
    return ClientVO(
      id: null == (temp = map['id'])
          ? null
          : (temp is num ? temp.toInt() : int.tryParse(temp)),
      uid: null == (temp = map['uid'])
          ? null
          : (temp is num ? temp.toInt() : int.tryParse(temp)),
      clientType: map['clientType']?.toString(),
      systemType: map['systemType']?.toString(),
      systemVersion: map['systemVersion']?.toString(),
      createTime: null == (temp = map['createTime'])
          ? null
          : (temp is num ? temp.toInt() : int.tryParse(temp)),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id':id,
      'uid': uid,
      'clientType': clientType,
      'systemType': systemType,
      'createTime': createTime,
      'systemVersion':systemVersion,
    };
  }
}
