import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note/app/windows/controller/home/win_home_controller.dart';
import 'package:note/app/windows/model/card/win_card_set_item_vo.dart';
import 'package:note/app/windows/view/card/win_card_set_tab.dart';
import 'package:note/model/card/po/card_po.dart';
import 'package:note/model/card/po/card_set_po.dart';
import 'package:note/service/card/card_service.dart';
import 'package:note/service/card/card_study_service.dart';
import 'package:note/service/service_manager.dart';

class WinCardSetController extends GetxController {
  var searchController = TextEditingController();
  var searchContent = "".obs;
  var cardSetList = RxList<WinCardSetItemVO>();
  late CardService cardSetService;
  late CardStudyService studyService;
  StreamSubscription? cardSetSubscription;
  StreamSubscription? cardSubscription;

  @override
  void onInit() {
    super.onInit();
    var sm = ServiceManager.of(Get.context!);
    cardSetService = sm.cardService;
    studyService = sm.cardStudyService;
    fetchData();
    cardSetSubscription =
        cardSetService.documentIsar.cardSetPOs.watchLazy().listen((event) {
      fetchData();
    });
    cardSubscription =
        cardSetService.documentIsar.cardPOs.watchLazy().listen((event) {
      fetchData();
    });
    searchContent.listen((p0) {
      fetchData();
    });
  }

  @override
  void onClose() {
    super.onClose();
    cardSetSubscription?.cancel();
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
    WinHomeController home = Get.find();
    home.openTab("cardSet-${cardSetItem.cardSet.uuid}", () {
      return WinCardSetTab(cardSet: cardSetItem);
    });
  }

  void deleteCardSet(WinCardSetItemVO cardSetItem) {
    cardSetService.deleteCardSet(cardSetItem.cardSet.uuid);
    WinHomeController home = Get.find();
    home.closeTab("cardSet-${cardSetItem.cardSet.uuid}");
  }

  void renameCardSet(WinCardSetItemVO cardSetItem, String text) {
    cardSetItem.cardSet.name = text;
    cardSetService.updateCardSet(cardSetItem.cardSet);
  }
}
