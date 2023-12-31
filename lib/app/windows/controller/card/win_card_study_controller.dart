import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:note/app/windows/widgets/win_edit_tab.dart';
import 'package:note/commons/fsrs/fsrs.dart' as fsrs;
import 'package:note/editor/block/element/element.dart';
import 'package:note/editor/block/text/hide_text_mode.dart';
import 'package:note/model/card/po/card_po.dart';
import 'package:note/model/card/po/card_set_po.dart';
import 'package:note/model/card/po/card_study_config_po.dart';
import 'package:note/model/card/po/card_study_record_po.dart';
import 'package:note/service/card/card_service.dart';
import 'package:note/service/card/card_study_service.dart';
import 'package:note/service/service_manager.dart';
import 'package:uuid/uuid.dart';

class WinCardStudyController extends WinEditTabController {
  late CardStudyService studyService;
  late CardService cardService;
  CardSetPO cardSet;
  var currentCard = Rxn<CardPO>();
  var cardStudyConfig = CardStudyConfigPO().obs;
  int startTime = DateTime.now().millisecondsSinceEpoch;
  var nextTimes = RxList<int>();
  var hasFocus = true;
  FlutterTts? flutterTts;

  var focusNode = FocusNode();

  @override
  String get tabId => "cardSetStudy-${cardSet.uuid}";

  WinCardStudyController({
    required this.cardSet,
  });

  List<HideTextMode>? get hideTextModes => cardStudyConfig.value.hideTextMode
      ?.split(",")
      .map((e) {
        switch (e) {
          case "color":
            return HideTextMode.color;
          case "formula":
            return HideTextMode.formula;
          case "background":
            return HideTextMode.background;
          case "underline":
            return HideTextMode.underline;
        }
        return null;
      })
      .where((element) => element != null)
      .map((e) => e!)
      .toList();

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    var sm = ServiceManager.of(context);
    cardService = sm.cardService;
    studyService = sm.cardStudyService;
    initTts();
    focusNode.addListener(() {
      hasFocus = focusNode.hasFocus;
    });
    focusNode.requestFocus();
  }

  @override
  void onOpenTab() {
    focusNode.requestFocus();
  }

  Future<void> initTts() async {
    flutterTts = FlutterTts();
    var langs = await flutterTts?.getLanguages;
    await flutterTts?.setLanguage("en-UK");
    // await flutterTts?.setSpeechRate(1.0);
    // await flutterTts?.setVolume(1.0);
    // await flutterTts?.setPitch(1.0);
    // await flutterTts?.isLanguageAvailable("en-US");
    await studyService.generateStudyQueue(cardSet.uuid);
    await fetchCard();
  }

  Future<void> fetchData() async {
    await fetchCard();
  }

  Future<void> fetchCard() async {
    var config = await studyService.queryStudyConfig(cardSet.uuid);
    if (config != null) {
      cardStudyConfig.value = config;
    }
    var mode = config?.studyQueueMode ?? StudyQueueMode.mixin.name;
    var cardIds = <String>[];
    if (mode == StudyQueueMode.mixin.name ||
        mode == StudyQueueMode.study.name) {
      var studyQueue = await studyService.queryNeedStudyQueue(cardSet.uuid);
      if (studyQueue.isNotEmpty) {
        cardIds.add(studyQueue.first);
      }
    }
    if (mode == StudyQueueMode.mixin.name ||
        mode == StudyQueueMode.review.name) {
      var reviewQueue = await studyService.queryReviewQueue(cardSet.uuid);
      if (reviewQueue.isNotEmpty) {
        cardIds.add(reviewQueue.first);
      }
    }
    if (cardIds.isNotEmpty) {
      var random = Random(DateTime.now().millisecondsSinceEpoch);
      var index = random.nextInt(cardIds.length);
      var cardId = cardIds[index];
      currentCard.value = await cardService.queryCard(cardId);
    } else {
      currentCard.value = null;
    }
    await queryNextTime();
    startTime = DateTime.now().millisecondsSinceEpoch;
    playAudio();
  }

  Future<void> queryNextTime() async {
    this.nextTimes.clear();
    var card = currentCard.value;
    if (card == null) {
      return;
    }
    var fsrsCard = await queryFsrsCardInfo(card);
    fsrsCard ??= fsrs.Card(
      due: DateTime.now(),
      stability: 0,
      difficulty: 0,
      elapsedDays: 0,
      scheduledDays: 0,
      reps: 0,
      lapses: 0,
      state: fsrs.State.newCard,
      lastReview: DateTime.now(),
    );
    var parameters = fsrs.defaultParameters();
    var state = parameters.repeat(fsrsCard, DateTime.now());
    List<int> nextTimes = [];
    for (var i = 0; i < fsrs.scoreArray.length; i++) {
      var schedulingInfo = state[fsrs.scoreArray[i]];
      var nextTime = schedulingInfo?.card.due.millisecondsSinceEpoch ??
          (DateTime.now().millisecondsSinceEpoch + 1000 * 60);

      nextTimes.add(
          max(30 * 1000, nextTime - DateTime.now().millisecondsSinceEpoch));
    }
    this.nextTimes.value = nextTimes;
  }

  Future<void> recordStudy(int score) async {
    var card = currentCard.value;
    if (card == null) {
      return;
    }
    var fsrsCard = await queryFsrsCardInfo(card);
    fsrsCard ??= fsrs.Card(
      due: DateTime.now(),
      stability: 0,
      difficulty: 0,
      elapsedDays: 0,
      scheduledDays: 0,
      reps: 0,
      lapses: 0,
      state: fsrs.State.newCard,
      lastReview: DateTime.now(),
    );
    var parameters = fsrs.defaultParameters();
    var state = parameters.repeat(fsrsCard, DateTime.now());
    var schedulingInfo = state[fsrs.scoreArray[score]];
    var recordCard = schedulingInfo?.card;
    var fsrsRemInfo = jsonEncode({'card': recordCard?.toJson()});
    var nextTime = max(DateTime.now().millisecondsSinceEpoch + 30 * 1000,
        schedulingInfo?.card.due.millisecondsSinceEpoch ?? 0);
    var endTime = DateTime.now().millisecondsSinceEpoch;
    var record = CardStudyRecordPO(
        uuid: const Uuid().v1(),
        cardSetId: cardSet.uuid,
        cardId: card.uuid,
        startTime: startTime,
        endTime: endTime,
        createTime: DateTime.now().millisecondsSinceEpoch,
        updateTime: DateTime.now().millisecondsSinceEpoch,
        score: score,
        fsrsRemInfo: fsrsRemInfo,
        nextStudyTime: nextTime);
    await studyService.createStudyRecord(record);
    await fetchCard();
  }

  Future<fsrs.Card?> queryFsrsCardInfo(CardPO card) async {
    var recordInfo = await studyService.queryStudyRecord(card.uuid);
    var remInfo = recordInfo?.fsrsRemInfo;
    if (remInfo != null) {
      var remoInfoJson = jsonDecode(remInfo);
      var cardJson = remoInfoJson['card'];
      if (cardJson != null) {
        return fsrs.Card.fromJson(cardJson);
      }
    }
    return null;
  }

  get time1 {
    if (nextTimes.length < 1) {
      return null;
    }
    return getTimeString(nextTimes[0]);
  }

  get time2 {
    if (nextTimes.length < 2) {
      return null;
    }
    return getTimeString(nextTimes[1]);
  }

  get time3 {
    if (nextTimes.length < 3) {
      return null;
    }
    return getTimeString(nextTimes[2]);
  }

  get time4 {
    if (nextTimes.length < 4) {
      return null;
    }
    return getTimeString(nextTimes[3]);
  }

  String getTimeString(int mill) {
    int secondMod = 1000;
    int minuteMod = secondMod * 60;
    int hourMod = minuteMod * 60;
    int dayMod = hourMod * 24;
    int day = (mill / dayMod).round();
    int hour = (mill / hourMod).round();
    int minute = (mill / minuteMod).round();
    int second = (mill / secondMod).round();
    if (hour >= 24) {
      return "$day天后";
    }
    if (minute >= 60) {
      return "$hour小时后";
    }
    if (second >= 60) {
      return "$minute分钟后";
    }
    return "$second秒后";
  }

  void playAudio() async {
    if (currentCard.value == null) {
      return;
    }
    int playCount = 0;
    var playMode = cardStudyConfig.value.playTtsMode;
    if (playMode == PlayTtsMode.play1.name) {
      playCount = 1;
    } else if (playMode == PlayTtsMode.play2.name) {
      playCount = 2;
    } else if (playMode == PlayTtsMode.play3.name) {
      playCount = 3;
    } else if (playMode == PlayTtsMode.playAll.name) {
      playCount = 100000000;
    } else {
      playCount = 1;
    }
    var content = currentCard.value?.content;
    if (content == null) {
      return;
    }
    List items = jsonDecode(content);
    var elements = items.map((e) => WenElement.parseJson(e)).toList();
    StringBuffer playBuff = StringBuffer();
    int cnt = 0;
    for (var element in elements) {
      if (cnt >= playCount) {
        break;
      }
      var text = element.getText();
      if (text.isNotEmpty) {
        cnt++;
        playBuff.writeln(text);
      }
    }
    // await flutterTts?.stop();
    String text = playBuff.toString();
    flutterTts?.stop();
    flutterTts?.speak(text);
  }
}
