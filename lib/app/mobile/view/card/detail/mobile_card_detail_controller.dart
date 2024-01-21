import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:wenznote/app/mobile/view/card/detail/mobile_card_detail_model.dart';
import 'package:wenznote/commons/mvc/controller.dart';
import 'package:wenznote/model/card/po/card_po.dart';
import 'package:wenznote/model/note/vo/xy_item.dart';
import 'package:wenznote/model/task/task.dart';
import 'package:wenznote/service/service_manager.dart';
import 'package:uuid/uuid.dart';

class MobileCardDetailController extends ServiceManagerController {
  MobileCardDetailController({
    this.cardSetId,
  });

  var tabIndex = 0.obs;

  var searchText = "".obs;

  var searchFocusNode = FocusNode();

  var allCardList = RxList<CardSearchResultVO>();

  var todayCardList = RxList<CardSearchResultVO>();

  var reviewCardList = RxList<CardSearchResultVO>();

  var searchController = TextEditingController();

  var searchContent = "".obs;

  var studyCountGraphx = RxList<XYItem<String, int>>();

  var reviewCountGraphx = RxList<XYItem<String, int>>();

  var studyTimeGraphx = RxList<XYItem<String, int>>();

  var todayStudyQueue = <String>[];

  var reviewQueue = <String>[];

  var cardCategory = "全部".obs;

  String? cardSetId;

  var model = Rxn<CardDetailModel>();

  BaseTask? searchTask;

  String get title => model.value?.title ?? "";

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    fetchData();
    searchContent.listen((e) {
      fetchData();
    });
  }

  @override
  void onDidUpdateWidget(BuildContext context, MvcController oldController) {
    super.onDidUpdateWidget(context, oldController);
    var old = (oldController as MobileCardDetailController);
    cardSetId = old.cardSetId;
    searchText = old.searchText;
    fetchData();
  }

  Future<void> fetchData() async {
    var cardService = serviceManager.cardService;
    var cardSet = await cardService.queryCardSet(cardSetId);
    model.value = CardDetailModel(cardSet: cardSet);
    var studyService = serviceManager.cardStudyService;
    await serviceManager.cardStudyService.generateStudyQueue(cardSetId);
    await fetchGraphxData();
    searchTask?.stopTask();
    searchTask = BaseTask.start((task) async {
      todayStudyQueue = await studyService.queryTodayStudyQueue(cardSetId);
      reviewQueue = await studyService.queryReviewQueue(cardSetId);
      var cardList = await cardService.queryCardList(
        cardCategory.value,
        cardSetId,
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
        var model = CardSearchResultVO(
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
                .where(
                    (element) => todayStudyQueue.contains(element.card!.uuid))
                .toList();
            reviewCardList.value = allCardList
                .where((element) => reviewQueue.contains(element.card!.uuid))
                .toList();
          } else {
            allCardList.add(model);
            if (todayStudyQueue.contains(model.card!.uuid)) {
              todayCardList.add(model);
            }
            if (reviewQueue.contains(model.card!.uuid)) {
              reviewCardList.add(model);
            }
          }
        }
      }
    });
  }

  Future<void> fetchGraphxData() async {
    var studyService = serviceManager.cardStudyService;
    //学习数据如何查询？
    studyCountGraphx.value =
        await studyService.queryStudyCountGraphx(cardSetId);
    reviewCountGraphx.value =
        await studyService.queryReviewCountGraphx(cardSetId);
    //学习时长统计
    studyTimeGraphx.value = await studyService.queryStudyTimeGraphx(cardSetId);
  }

  void createCard() {
    var card = CardPO(
      cardSetId: cardSetId,
      uuid: const Uuid().v1(),
      createTime: DateTime.now().millisecondsSinceEpoch,
      updateTime: DateTime.now().millisecondsSinceEpoch,
    );
    var cardService = serviceManager.cardService;
    cardService.createCard(card);
    openCard(card);
  }

  void openCardStudy() {
    GoRouter.of(context)
        .push("/mobile/cardSet/$cardSetId/study", extra: {
      "cardSet": model.value?.cardSet,
    });
  }

  void openCard(CardPO? card) {
    if (card != null) {
      GoRouter.of(context).push("/mobile/card/edit", extra: {
        "card": card,
        "editOnOpen": false,
      });
    }
  }

  void deleteCard(CardPO? card) {}

  void openCardConfig() {
    GoRouter.of(context)
        .push("/mobile/cardSet/$cardSetId/settings", extra: {
      "cardSet": model.value?.cardSet,
    });
  }
}
