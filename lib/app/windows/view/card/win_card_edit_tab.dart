import 'package:flutter/material.dart';
import 'package:flutter_crdt/flutter_crdt.dart';
import 'package:note/app/windows/controller/home/win_home_controller.dart';
import 'package:note/app/windows/widgets/card_editor.dart';
import 'package:note/commons/mvc/controller.dart';
import 'package:note/commons/mvc/view.dart';
import 'package:note/editor/crdt/YsEditController.dart';
import 'package:note/editor/widget/toggle_item.dart';
import 'package:note/model/card/po/card_po.dart';
import 'package:note/service/service_manager.dart';
import 'package:uuid/uuid.dart';
import 'package:window_manager/window_manager.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

class WinCardEditController extends MvcController {
  WinHomeController homeController;

  WinCardEditController(this.homeController);
}

class WinCardEditTab extends MvcView<WinCardEditController> {
  CardPO card;
  bool isCreateMode;
  CardEditor? cardEditor;
  Doc? cardYDoc;
  late ServiceManager serviceManager;

  WinCardEditTab({
    super.key,
    required this.card,
    this.isCreateMode = false,
    required super.controller,
  });

  @override
  Widget build(BuildContext context) {
    return buildContent(context);
  }

  Widget buildContent(BuildContext context) {
    serviceManager = ServiceManager.of(context);
    cardEditor ??= CardEditor(
      card: card,
      key: ValueKey(card),
      editController: YsEditController(
        initFocus: false,
        padding: const EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: 100,
        ),
        scrollController: ScrollController(),
        fileManager: serviceManager.fileManager,
        copyService: serviceManager.copyService,
      ),
      onCardUpdate: (doc) {
        cardYDoc = doc;
        if (isCreateMode) {
          if (cardEditor?.editController.isEmpty == true) {
            serviceManager.cardService.deleteCard(card);
            return;
          }
        }
        serviceManager.cardService.updateCard(card);
      },
    );
    return cardEditor!;
  }

  void createNewCard() {
    // controller.homeController.closeTab(tabId);
    var card = CardPO(
      cardSetId: this.card.cardSetId,
      uuid: Uuid().v1(),
      createTime: DateTime.now().millisecondsSinceEpoch,
      updateTime: DateTime.now().millisecondsSinceEpoch,
    );
    serviceManager.cardService.createCard(card);
    openCard(card, true);
  }

  void openCard(CardPO card, [bool isCreateMode = false]) {
    var body = WinCardEditTab(
      card: card,
      isCreateMode: isCreateMode,
      controller: WinCardEditController(
        controller.homeController,
      ),
    );
    controller.homeController.tabController.openTab(
      id: "card-${card.uuid}",
      body: body,
      text: Text("编辑卡片"),
    );
  }
}
