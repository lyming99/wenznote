import 'dart:convert';

import 'package:sqflite_common/sqlite_api.dart';

class CardSetOptionPO {
  int? id;
  String? cardSetUuid;
  int? dailyStudyCount;
  int? dailyReviewCount;

  int? createTime;
  int? updateTime;
  String? moreInfo;
  static String tableName = "wz_card_set_option_t";
  static String createSql = """
    create table wz_card_set_option_t(
        id integer primary key autoincrement ,
        cardSetUuid varchar(64),
        dailyStudyCount integer,
        dailyReviewCount integer,
        createTime integer,
        updateTime integer,
        moreInfo text
    )
  """;

  CardSetOptionPO({
    this.id,
    this.cardSetUuid,
    this.dailyStudyCount,
    this.dailyReviewCount,
    this.createTime,
    this.updateTime,
    this.moreInfo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'cardSetUuid': this.cardSetUuid,
      'dailyStudyCount': this.dailyStudyCount,
      'dailyReviewCount': this.dailyReviewCount,
      'createTime': this.createTime,
      'updateTime': this.updateTime,
      'moreInfo': this.moreInfo,
    };
  }

  factory CardSetOptionPO.fromMap(Map<String, dynamic> map) {
    return CardSetOptionPO(
      id: map['id'] as int?,
      cardSetUuid: map['cardSetUuid'] as String?,
      dailyStudyCount: map['dailyStudyCount'] as int?,
      dailyReviewCount: map['dailyReviewCount'] as int?,
      createTime: map['createTime'] as int?,
      updateTime: map['updateTime'] as int?,
      moreInfo: map['moreInfo'] as String?,
    );
  }

  static Future<void> upgradeDb(Database db) async {}

  StudyConfigInfo? get studyModeInfo {
    if (moreInfo == null) {
      return null;
    }
    return StudyConfigInfo.fromMap(jsonDecode(moreInfo!));
  }
}

class StudyConfigInfo {
  String orderType;
  String studyMode;
  String reviewMethod;
  String? hideBlockMode;
  List<dynamic>? hideTextModes;
  String? playType;
  String? playMode;

  StudyConfigInfo({
    required this.orderType,
    required this.studyMode,
    required this.reviewMethod,
    this.hideBlockMode,
    this.hideTextModes,
    this.playType,
    this.playMode,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderType': this.orderType,
      'studyMode': this.studyMode,
      'reviewMethod': this.reviewMethod,
      'hideBlockMode': this.hideBlockMode,
      'hideTextModes': this.hideTextModes,
      'playType': this.playType,
      'playMode': this.playMode,
    };
  }

  factory StudyConfigInfo.fromMap(Map<String, dynamic> map) {
    return StudyConfigInfo(
      orderType: map['orderType'] as String,
      studyMode: map['studyMode'] as String,
      reviewMethod: map['reviewMethod'] as String,
      hideBlockMode: map['hideBlockMode'] as String?,
      hideTextModes: map['hideTextModes'] as List<dynamic>?,
      playType: map['playType'] as String?,
      playMode: map['playMode'] as String?,
    );
  }
}

enum StudyOrderType {
  asc,
  random;

  static StudyOrderType forName(String? name) {
    if (name == "random") {
      return StudyOrderType.random;
    }
    return StudyOrderType.asc;
  }
}

enum StudyMode {
  mixin,
  study,
  review;

  static StudyMode forName(String? name) {
    if (name == "mixin") {
      return StudyMode.mixin;
    }
    if (name == "study") {
      return StudyMode.study;
    }
    return StudyMode.review;
  }
}

enum ReviewMethod { fsrs }

enum HideBlockMode {
  none,
  keepOne,
  keepTwo,
  keepThree;

  static HideBlockMode forName(String? name) {
    if (name == "keepOne") {
      return HideBlockMode.keepOne;
    }
    if (name == "keepTwo") {
      return HideBlockMode.keepTwo;
    }
    if (name == "keepThree") {
      return HideBlockMode.keepThree;
    }
    return HideBlockMode.none;
  }

  String getDisplayName() {
    switch (this) {
      case none:
        return "显示全部";
      case keepOne:
        return "显示一行";
      case keepTwo:
        return "显示二行";
      case keepThree:
        return "显示三行";
    }
  }
}

enum PlayType {
  tts,
  url;

  static PlayType forName(String? name) {
    if (name == "url") {
      return PlayType.url;
    }
    return PlayType.tts;
  }

  String getDisplayName() {
    switch (this) {
      case tts:
        return "系统tts";
      case url:
        return "语音合成";
    }
  }
}

enum PlayMode {
  none,
  one,
  two,
  all;

  static PlayMode forName(String? name) {
    if (name == "two") {
      return PlayMode.two;
    }
    if (name == "one") {
      return PlayMode.one;
    }
    if (name == "all") {
      return PlayMode.all;
    }
    return PlayMode.none;
  }

  String getDisplayName() {
    switch (this) {
      case none:
        return "不播放";
      case one:
        return "播放一行";
      case two:
        return "播放二行";
      case all:
        return "播放全部";
    }
  }
}
