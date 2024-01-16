import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:note/model/card/po/card_set_po.dart';
import 'package:note/service/service_manager.dart';

import 'mobile_card_page_model.dart';

class MobileCardPageController extends ServiceManagerController {
  MobileCardPageController();

  var scrollController = ScrollController();

  var searchText = "".obs;

  var searchController = TextEditingController();

  var searchFocusNode = FocusNode();

  var modelList = RxList(<MobileCardModel>[]);

  bool get isSearchList => false;

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    searchText.listen((p0) {
      fetchData();
    });
    fetchData();
  }

  void fetchData() async {
    var cardSet = await serviceManager.cardService.queryCardSetList();
    if (searchText.isNotEmpty) {
      var search = searchText.value;
      cardSet.removeWhere(
          (element) => (element.name?.contains(search) ?? false) == false);
    }
    var studyService = serviceManager.cardStudyService;
    modelList.clear();
    for(var item in cardSet){
      //如何查询进入队列长度
      var todayStudyQueueCount =
      await studyService.queryTodayStudyQueueCount(item.uuid);
      var todayStudyCount =
      await studyService.queryTodayStudyCount(item.uuid);
      var reviewCount =
          (await studyService.queryReviewQueue(item.uuid)).length;
      modelList.add(MobileCardModel(
        card: item,
        todayStudyCount: todayStudyCount,
        todayStudyQueueCount: todayStudyQueueCount,
        reviewCount: reviewCount,
      ));
    }
  }

  void openCardSet(BuildContext context, MobileCardModel cardSetItem) {
    GoRouter.of(context).push("/mobile/cardSet/${cardSetItem.card.uuid}");
  }

  void deleteCardSet(MobileCardModel cardSetItem) async {
    await serviceManager.cardService.deleteCardSet(cardSetItem.card.uuid);
    fetchData();
  }

  void renameCardSet(MobileCardModel cardSetItem, String text) async {
    cardSetItem.card.name = text;
    await serviceManager.cardService.updateCardSet(cardSetItem.card);
    fetchData();
  }

  void createCardSet(String name) async {
    var cardSet = CardSetPO(name: name);
    await serviceManager.cardService.createCardSet(cardSet);
    fetchData();
  }
}
