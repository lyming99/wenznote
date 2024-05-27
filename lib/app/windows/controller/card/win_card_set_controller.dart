import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wenznote/app/windows/controller/card/win_card_set_detail_page_controller.dart';
import 'package:wenznote/app/windows/controller/home/win_home_controller.dart';
import 'package:wenznote/app/windows/model/card/win_card_set_item_vo.dart';
import 'package:wenznote/app/windows/view/card/win_card_set_detail_page.dart';
import 'package:wenznote/model/card/po/card_po.dart';
import 'package:wenznote/model/card/po/card_set_po.dart';
import 'package:wenznote/service/card/card_service.dart';
import 'package:wenznote/service/card/card_study_service.dart';
import 'package:wenznote/service/service_manager.dart';

class WinCardSetController extends ServiceManagerController {
  var searchController = TextEditingController();
  var searchContent = "".obs;
  var cardSetList = RxList<WinCardSetItemVO>();
  late CardService cardSetService;
  late CardStudyService studyService;
  StreamSubscription? cardSetSubscription;
  StreamSubscription? cardSubscription;
  WinHomeController homeController;

  WinCardSetController(this.homeController);

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    cardSetService = serviceManager.cardService;
    studyService = serviceManager.cardStudyService;
    fetchData();
    // cardSetSubscription =
    //     cardSetService.documentIsar.cardSetPOs.watchLazy().listen((event) {
    //   fetchData();
    // });
    // cardSubscription =
    //     cardSetService.documentIsar.cardPOs.watchLazy().listen((event) {
    //   fetchData();
    // });
    searchContent.listen((p0) {
      fetchData();
    });
  }

  @override
  void onDispose() {
    super.onDispose();
    cardSetSubscription?.cancel();
  }

  void refresh() {
    fetchData();
  }

  Future<void> fetchData() async {
    var cardSets = await cardSetService.queryCardSetList();
    var showItems = <WinCardSetItemVO>[];
    for (var cardSet in cardSets) {
      if (searchContent.isNotEmpty) {
        if (cardSet.name?.contains(searchContent.value) == false) {
          continue;
        }
      }
      //如何查询进入队列长度
      var todayStudyQueueCount =
          await studyService.queryTodayStudyQueueCount(cardSet.uuid);
      var todayStudyCount =
          await studyService.queryTodayStudyCount(cardSet.uuid);
      var reviewCount =
          (await studyService.queryReviewQueue(cardSet.uuid)).length;
      showItems.add(WinCardSetItemVO(
        cardSet: cardSet,
        todayStudyCount: todayStudyCount,
        todayStudyQueueCount: todayStudyQueueCount,
        reviewCount: reviewCount,
      ));
    }
    cardSetList.value = showItems;
  }

  void createCardSet(String title) {
    var cardSet = CardSetPO(name: title);
    cardSetService.createCardSet(cardSet);
  }

  void openCardSet(BuildContext context, WinCardSetItemVO cardSetItem) {
    var body = WinCardSetDetailPage(
        controller: WinCardSetDetailPageController(
      homeController: homeController,
      cardSet: cardSetItem,
    ));
    homeController.openTab(
      id: "cardSet-${cardSetItem.cardSet.uuid}",
      text: Text("${cardSetItem.cardSet.name}"),
      body: body,
    );
  }

  void deleteCardSet(WinCardSetItemVO cardSetItem) {
    cardSetService.deleteCardSet(cardSetItem.cardSet.uuid);
    homeController.closeTab("cardSet-${cardSetItem.cardSet.uuid}");
  }

  void renameCardSet(WinCardSetItemVO cardSetItem, String text) {
    cardSetItem.cardSet.name = text;
    cardSetService.updateCardSet(cardSetItem.cardSet);
  }
}
