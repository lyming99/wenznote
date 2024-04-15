class UserVO {
  int? id;
  String? username;
  String? email;
  String? avatar;
  String? nickname;
  String? sex;
  int? age;
  String? concat;
  String? mobile;
  String? note;
  String? address;
  String? sign;
  List<VipInfoVO>? vipInfoList;

  UserVO({
    this.id,
    this.username,
    this.email,
    this.avatar,
    this.nickname,
    this.sex,
    this.age,
    this.concat,
    this.mobile,
    this.note,
    this.address,
    this.sign,
    this.vipInfoList,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatar': avatar,
      'nickname': nickname,
      'sex': sex,
      'age': age,
      'concat': concat,
      'mobile': mobile,
      'note': note,
      'address': address,
      'sign': sign,
      'vipInfoList': vipInfoList?.map((v) => v.toMap()).toList(),
    };
  }

  factory UserVO.fromMap(Map<String, dynamic> map) {
    return UserVO(
      id: map['id'] as int?,
      username: map['username'] as String?,
      email: map['email'] as String?,
      avatar: map['avatar'] as String?,
      nickname: map['nickname'] as String?,
      sex: map['sex'] as String?,
      age: map['age'] as int?,
      concat: map['concat'] as String?,
      mobile: map['mobile'] as String?,
      note: map['note'] as String?,
      address: map['address'] as String?,
      sign: map['sign'] as String?,
      vipInfoList: map['vipInfoList'] != null
          ? List<VipInfoVO>.from(
              (map['vipInfoList'] as List<dynamic>).map<VipInfoVO?>(
                (x) => VipInfoVO.fromMap(x as Map<String, dynamic>),
              ),
            )
          : null,
    );
  }
}

class VipInfoVO {
  String? userId;
  String? vipType;
  String? limitTimeType;
  DateTime? startTime;
  DateTime? endTime;

  VipInfoVO({
    this.userId,
    this.vipType,
    this.limitTimeType,
    this.startTime,
    this.endTime,
  });

  factory VipInfoVO.fromMap(Map<String, dynamic> map) {
    return VipInfoVO(
      userId: map['userId'] as String?,
      vipType: map['vipType'] as String?,
      limitTimeType: map['limitTimeType'] as String?,
      startTime:
          map['startTime'] == null ? null : DateTime.parse(map['startTime']),
      endTime: map['endTime'] == null ? null : DateTime.parse(map['endTime']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'vipType': vipType,
      'limitTimeType': limitTimeType,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
    };
  }
}
