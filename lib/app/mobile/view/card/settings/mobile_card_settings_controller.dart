import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note/commons/mvc/controller.dart';
import 'package:note/editor/block/text/hide_text_mode.dart';
import 'package:note/model/card/po/card_set_po.dart';
import 'package:note/model/card/po/card_study_config_po.dart';
import 'package:note/model/note/enum/note_order_type.dart';
import 'package:note/service/card/card_study_service.dart';
import 'package:note/service/service_manager.dart';
import 'package:uuid/uuid.dart';

class MobileCardSettingsController extends ServiceManagerController {
  MobileCardSettingsController({
    required this.cardSet,
  });

  CardSetPO cardSet;

  var cardSetConfig = Rx<CardStudyConfigPO>(CardStudyConfigPO());

  late CardStudyService cardService;

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    cardService = serviceManager.cardStudyService;
    fetchData();
  }

  Future<void> fetchData() async {}

  Future<void> readConfig() async {
    var config = await cardService.queryStudyConfig(cardSet.uuid);
    if (config != null) {
      cardSetConfig.value = config;
    } else {
      cardSetConfig.value = CardStudyConfigPO(
        uuid: Uuid().v1(),
        cardSetId: cardSet.uuid,
      );
    }
  }

  Future<void> saveConfig() async {
    var config = cardSetConfig.value;
    if (config.cardSetId != null) {
      await cardService.saveStudyConfig(config);
    }
  }

  String get studyOrderType =>
      cardSetConfig.value.studyOrderType ?? StudyOrderType.createTime.name;

  int get studyCount => cardSetConfig.value.dailyStudyCount ?? 100;

  set studyCount(count) {
    cardSetConfig.update((val) {
      val?.dailyStudyCount = count;
    });
  }

  int get reviewCount => cardSetConfig.value.dailyReviewCount ?? 100;

  set reviewCount(count) {
    cardSetConfig.update((val) {
      val?.dailyReviewCount = count;
    });
  }

  set studyOrderType(type) {
    cardSetConfig.update((val) {
      val?.studyOrderType = type;
    });
  }

  String get studyQueueMode =>
      cardSetConfig.value.studyQueueMode ?? StudyMode.mixin.name;

  set studyQueueMode(mode) {
    cardSetConfig.update((val) {
      val?.studyQueueMode = mode;
    });
  }

  String get showMode => cardSetConfig.value.showMode ?? ShowMode.showAll.name;

  set showMode(String mode) {
    cardSetConfig.update((val) {
      val?.showMode = mode;
    });
  }

  String get showModeName => getShowModeName(showMode);

  List<String> get hideTextMode => (cardSetConfig.value.hideTextMode ??
          HideTextMode.values.map((e) => e.name).join(","))
      .split(",")
    ..removeWhere((element) => element.isEmpty);

  set hideTextMode(List<String> mode) {
    cardSetConfig.update((val) {
      val?.hideTextMode = mode.join(",");
    });
  }

  String get studyQueueModeName => getStudyQueueModeName(studyQueueMode);

  String get studyOrderTypeName => getOrderTypeName(studyOrderType);

  List<String> get orderTypes => OrderType.values.map((e) => e.name).toList();

  String getOrderTypeName(String value) {
    switch (value) {
      case "random":
        return "随机顺序";
      case "createTime":
        return "按创建时间";
      default:
        return "";
    }
  }

  List<String> get studyQueueModes =>
      StudyMode.values.map((e) => e.name).toList();

  String getStudyQueueModeName(String studyQueueMode) {
    switch (studyQueueMode) {
      case "study":
        return "学习优先";
      case "review":
        return "复习优先";
      case "mixin":
        return "混合模式";
      default:
        return "";
    }
  }

  List<String> get showModes => ShowMode.values.map((e) => e.name).toList();

  String getShowModeName(String studyQueueMode) {
    switch (studyQueueMode) {
      case "show1":
        return "显示1行";
      case "show2":
        return "显示2行";
      case "show3":
        return "显示3行";
      case "showAll":
        return "显示全部";
      default:
        return "";
    }
  }

  List<String> get hideTextModes =>
      HideTextMode.values.map((e) => e.name).toList();

  String getHideTextModeName(String mode) {
    return HideTextMode.forName(mode)?.getDisplayName() ?? "";
  }

  String get playTtsMode =>
      cardSetConfig.value.playTtsMode ?? PlayTtsMode.play1.name;

  set playTtsMode(String mode) {
    cardSetConfig.update((val) {
      val?.playTtsMode = mode;
    });
  }

  String get playTssModeName => getPlayTtsModeName(playTtsMode);

  List<String> get playTtsModes =>
      PlayTtsMode.values.map((e) => e.name).toList();

  String getPlayTtsModeName(String mode) {
    switch (mode) {
      case "play1":
        return "播放1行";
      case "play2":
        return "播放2行";
      case "play3":
        return "播放3行";
      case "playAll":
        return "播放全部";
      case "none":
        return "不播放";
      default:
        return "";
    }
  }

  String get ttsType => cardSetConfig.value.ttsType ?? TtsType.system.name;

  set ttsType(String mode) {
    cardSetConfig.update((val) {
      val?.ttsType = mode;
    });
  }

  String get ttsTypeName => getTtsTypeName(ttsType);

  List<String> get ttsTypes => TtsType.values.map((e) => e.name).toList();

  String getTtsTypeName(String type) {
    switch (type) {
      case "system":
        return "系统tts";
      case "other":
        return "第三方tts";
      default:
        return "";
    }
  }

  String get reviewAlgorithm =>
      cardSetConfig.value.reviewAlgorithm ?? ReviewAlgorithm.fsrs.name;

  set reviewAlgorithm(String type) {
    cardSetConfig.update((val) {
      val?.reviewAlgorithm = type;
    });
  }

  String get reviewAlgorithmName => getReviewAlgorithmName(reviewAlgorithm);

  List<String> get reviewAlgorithms =>
      ReviewAlgorithm.values.map((e) => e.name).toList();

  String getReviewAlgorithmName(String type) {
    switch (type) {
      case "fsrs":
        return "fsrs";
      default:
        return "";
    }
  }
}
