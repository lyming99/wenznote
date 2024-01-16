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
  String?sign;

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
  });

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'username': this.username,
      'email': this.email,
      'avatar': this.avatar,
      'nickname': this.nickname,
      'sex': this.sex,
      'age': this.age,
      'concat': this.concat,
      'mobile': this.mobile,
      'note': this.note,
      'address': this.address,
      'sign':this.sign,
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
    );
  }
}
