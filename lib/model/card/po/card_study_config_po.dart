import 'package:isar/isar.dart';

part 'card_study_config_po.g.dart';

@collection
class CardStudyConfigPO {
  Id id;
  String? uid;
  String? uuid;
  String? did;
  String? createBy;
  String? updateBy;
  int? createTime;
  int? updateTime;

  String? cardSetId;
  int? dailyStudyCount;
  int? dailyReviewCount;
  String? studyOrderType;

  //学习模式：混合模式/学习模式/复习模式
  String? studyQueueMode;

  //阅读设置-挖空模式：不挖空/下划线/字体颜色/背景颜色
  String? hideTextMode;

  //阅读设置-显示设置：显示全部/显示一行/显示二行
  String? showMode;

  //语音播放: 不播放/播放一行/播放二行/播放全部
  String? playTtsMode;

  //tts语音模型：系统tts/第三方tts
  String? ttsType;

  //ttsId
  String? ttsId;

  //记忆算法
  String? reviewAlgorithm;

  CardStudyConfigPO({
    this.id = Isar.autoIncrement,
    this.uid,
    this.uuid,
    this.did,
    this.createBy,
    this.updateBy,
    this.createTime,
    this.updateTime,
    this.cardSetId,
    this.dailyStudyCount,
    this.dailyReviewCount,
    this.studyOrderType,
    this.studyQueueMode,
    this.hideTextMode,
    this.showMode,
    this.playTtsMode,
    this.ttsType,
    this.ttsId,
    this.reviewAlgorithm,
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
      'cardSetId': this.cardSetId,
      'dailyStudyCount': this.dailyStudyCount,
      'dailyReviewCount': this.dailyReviewCount,
      'studyOrderType': this.studyOrderType,
      'studyQueueMode': this.studyQueueMode,
      'hideTextMode': this.hideTextMode,
      'showMode': this.showMode,
      'playTtsMode': this.playTtsMode,
      'ttsType': this.ttsType,
      'ttsId': this.ttsId,
      'reviewAlgorithm': this.reviewAlgorithm,
    };
  }

  factory CardStudyConfigPO.fromMap(Map<String, dynamic> map) {
    return CardStudyConfigPO(
      uid: map['uid'],
      uuid: map['uuid'],
      did: map['did'],
      createBy: map['createBy'],
      updateBy: map['updateBy'],
      createTime: map['createTime'],
      updateTime: map['updateTime'],
      cardSetId: map['cardSetId'],
      dailyStudyCount: map['dailyStudyCount'],
      dailyReviewCount: map['dailyReviewCount'],
      studyOrderType: map['studyOrderType'],
      studyQueueMode: map['studyQueueMode'],
      hideTextMode: map['hideTextMode'],
      showMode: map['showMode'],
      playTtsMode: map['playTtsMode'],
      ttsType: map['ttsType'],
      ttsId: map['ttsId'],
      reviewAlgorithm: map['reviewAlgorithm'],
    );
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
enum StudyOrderType{
  createTime,random
}


enum ShowMode{
  show1,show2,show3,showAll
}


enum PlayTtsMode{
  play1,play2,play3,playAll,none
}
enum TtsType{
  system,other
}


enum ReviewAlgorithm{
  fsrs
}

