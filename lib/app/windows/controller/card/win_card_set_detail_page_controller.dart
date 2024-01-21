import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note/app/windows/controller/card/win_card_set_config_tab_controller.dart';
import 'package:note/app/windows/controller/card/win_card_study_controller.dart';
import 'package:note/app/windows/controller/home/win_home_controller.dart';
import 'package:note/app/windows/model/card/win_card_search_result_vo.dart';
import 'package:note/app/windows/model/card/win_card_set_item_vo.dart';
import 'package:note/app/windows/view/card/win_card_edit_tab.dart';
import 'package:note/app/windows/view/card/win_card_set_config_tab.dart';
import 'package:note/app/windows/view/card/win_card_study_tab.dart';
import 'package:note/app/windows/widgets/win_edit_tab.dart';
import 'package:note/commons/util/date_util.dart';
import 'package:note/editor/block/text/text.dart';
import 'package:note/model/card/po/card_po.dart';
import 'package:note/model/note/vo/xy_item.dart';
import 'package:note/model/task/task.dart';
import 'package:note/service/card/card_service.dart';
import 'package:note/service/card/card_study_service.dart';
import 'package:note/service/service_manager.dart';
import 'package:uuid/uuid.dart';

class WinCardSetDetailPageController extends ServiceManagerController {
  late CardStudyService studyService;
  late CardService cardService;
  var allCardList = RxList<WinCardSearchResultVO>();
  var todayCardList = RxList<WinCardSearchResultVO>();
  var reviewCardList = RxList<WinCardSearchResultVO>();
  var todayStudyQueue = <String>[];
  var reviewQueue = <String>[];
  var cardCategory = "全部".obs;
  WinCardSetItemVO cardSet;
  StreamSubscription? cardListener;
  BaseTask? searchTask;
  WinHomeController homeController;

  var searchController = TextEditingController();

  var searchContent = "".obs;

  var tabIndex = 0.obs;

  var studyCountGraphx = RxList<XYItem<String, int>>();

  var reviewCountGraphx = RxList<XYItem<String, int>>();

  var studyTimeGraphx = RxList<XYItem<String, int>>();

  WinCardSetDetailPageController({
    required this.homeController,
    required this.cardSet,
  });

  List<XYItem<String, int>> get zeroItems {
    var res = <XYItem<String, int>>[];
    var now = DateTime.now();
    for (var i = 0; i < 30; i++) {
      var date = DateUtil.dateToMd(now);
      res.add(XYItem(x: date, y: 0));
      now = DateUtil.addDays(now, -1);
    }
    return res.reversed.toList();
  }

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    cardService = serviceManager.cardService;
    studyService = serviceManager.cardStudyService;
    fetchData();
    cardListener = cardService.documentIsar.cardPOs.watchLazy().listen((event) {
      fetchData();
    });
    searchContent.listen((e) {
      fetchData();
    });
  }

  Future<void> fetchData() async {
    await studyService.generateStudyQueue(cardSet.cardSet.uuid);
    await fetchGraphxData();
    searchTask?.stopTask();
    searchTask = BaseTask.start((task) async {
      todayStudyQueue =
          await studyService.queryTodayStudyQueue(cardSet.cardSet.uuid);
      reviewQueue = await studyService.queryReviewQueue(cardSet.cardSet.uuid);
      var cardList = await cardService.queryCardList(
        cardCategory.value,
        cardSet.cardSet.uuid,
      );
      if (cardList.isEmpty) {
        if (!task.cancel) {
          allCardList.clear();
          reviewCardList.clear();
          todayCardList.clear();
        }
        return;
      }
      bool first = true;
      for (var item in cardList) {
        var model = WinCardSearchResultVO(
          card: item,
          searchText: searchContent.value,
        );
        await model.readDoc();
        bool searchResult = await model.search();
        if (task.cancel) {
          break;
        }
        if (!searchResult) {
          if (first) {
            first = false;
            allCardList.value = [];
            todayCardList.value = [];
            reviewCardList.value = [];
          } else {
            continue;
          }
        } else {
          if (first) {
            first = false;
            allCardList.value = [model];
            todayCardList.value = allCardList
                .where((element) => todayStudyQueue.contains(element.card.uuid))
                .toList();
            reviewCardList.value = allCardList
                .where((element) => reviewQueue.contains(element.card.uuid))
                .toList();
          } else {
            allCardList.add(model);
            if (todayStudyQueue.contains(model.card.uuid)) {
              todayCardList.add(model);
            }
            if (reviewQueue.contains(model.card.uuid)) {
              reviewCardList.add(model);
            }
          }
        }
      }
    });
  }

  Future<void> fetchGraphxData() async {
    //学习数据如何查询？
    studyCountGraphx.value =
        await studyService.queryStudyCountGraphx(cardSet.cardSet.uuid);
    reviewCountGraphx.value =
        await studyService.queryReviewCountGraphx(cardSet.cardSet.uuid);
    //学习时长统计
    studyTimeGraphx.value =
        await studyService.queryStudyTimeGraphx(cardSet.cardSet.uuid);
  }

  void createCard() async {
    var card = CardPO(
      cardSetId: cardSet.cardSet.uuid,
      uuid: Uuid().v1(),
      createTime: DateTime.now().millisecondsSinceEpoch,
      updateTime: DateTime.now().millisecondsSinceEpoch,
    );
    await cardService.createCard(card);
    openCard(card, true);
  }

  @override
  void onDispose() {
    super.onDispose();
    searchTask?.stopTask();
    cardListener?.cancel();
  }

  void openCard(CardPO card, [bool isCreateMode = false]) {
    homeController.closeWhere((element) => element is WinCardEditTab);
    var body = WinCardEditTab(
      card: card,
      isCreateMode: isCreateMode,
      controller: WinCardEditController(homeController),
    );
    homeController.openTab(
        id: "card-${card.uuid}", text: Text("编辑卡片"), body: body);
  }

  void deleteCard(CardPO card) {
    cardService.deleteCard(card);
  }

  void openCardConfig() {
    homeController.openTab(
        id: "cardSetConfig-${cardSet.cardSet.uuid}",
        text: Text("学习设置"),
        body: WinCardSetConfigTab(
          controller: WinCardSetConfigTabController(
            cardSet: cardSet.cardSet,
            homeController: homeController,
          ),
        ));
  }

  void openCardStudy() {
    homeController.openTab(
        id: "cardSetStudy-${cardSet.cardSet.uuid}",
        text: Text("学习"),
        body: WinCardStudyTab(
          controller: WinCardStudyController(
            cardSet: cardSet.cardSet,
            homeController: homeController,
          ),
        ));
  }
}

String createDemoCardContent() {
  var element = WenTextElement(
    children: [
      WenTextElement(
        text: "Hello 温知笔记\n 做最好的笔记软件",
      )
    ],
    level: 1,
  ).toJson();
  return jsonEncode([element, element]);
}
