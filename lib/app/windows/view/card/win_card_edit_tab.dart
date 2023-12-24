import 'package:flutter/material.dart';
import 'package:flutter_crdt/flutter_crdt.dart';
import 'package:get/get.dart';
import 'package:note/app/windows/controller/home/win_home_controller.dart';
import 'package:note/app/windows/widgets/card_editor.dart';
import 'package:note/app/windows/widgets/win_edit_tab.dart';
import 'package:note/editor/crdt/YsEditController.dart';
import 'package:note/editor/widget/toggle_item.dart';
import 'package:note/model/card/po/card_po.dart';
import 'package:note/service/card/card_service.dart';
import 'package:note/service/service_manager.dart';
import 'package:uuid/uuid.dart';
import 'package:window_manager/window_manager.dart';

class WinCardEditTab with WinEditTabMixin {
  CardPO card;
  bool isCreateMode;
  CardEditor? cardEditor;
  Doc? cardYDoc;
  late ServiceManager serviceManager;

  WinCardEditTab({
    required this.card,
    this.isCreateMode = false,
  });

  @override
  String get tabId => "card-${card.uuid}";

  @override
  Widget buildWidget(BuildContext context) {
    return Column(
      children: [
        buildNav(context),
        Expanded(
          child: buildContent(context),
        ),
      ],
    );
  }

  Widget buildNav(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // drawer button
          ToggleItem(
            onTap: (ctx) {
              closeTab();
            },
            itemBuilder:
                (BuildContext context, bool checked, bool hover, bool pressed) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: Icon(
                  Icons.arrow_back,
                  size: 24,
                ),
              );
            },
          ),
          Expanded(
              child: DragToMoveArea(
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                isCreateMode ? "新建卡片" : "编辑卡片",
                style: TextStyle(fontSize: 16),
              ),
            ),
          )),
          // actio
          // actions
          if (isCreateMode)
            ToggleItem(
              itemBuilder: (BuildContext context, bool checked, bool hover,
                  bool pressed) {
                return Container(
                  padding: const EdgeInsets.all(8.0),
                  color: hover ? Colors.grey.shade200 : null,
                  child: Icon(
                    Icons.add,
                    size: 22,
                  ),
                );
              },
              onTap: (ctx) {
                createNewCard();
              },
            ),
          SizedBox(
            width: 4,
          ),
        ],
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    serviceManager = ServiceManager.of(context);
    cardEditor ??= CardEditor(
      card: card,
      key: ValueKey(card),
      editController: YsEditController(
        initFocus: true,
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
    closeTab();
    var card = CardPO(
      cardSetId: this.card.cardSetId,
      uuid: Uuid().v1(),
      createTime: DateTime.now().millisecondsSinceEpoch,
      updateTime: DateTime.now().millisecondsSinceEpoch,
    );
    openCard(card, true);
  }

  void openCard(CardPO card, [bool isCreateMode = false]) {
    WinHomeController home = Get.find();
    home.closeWhere((element) => element is WinCardEditTab);
    home.openTab("card-${card.uuid}", () {
      return WinCardEditTab(
        card: card,
        isCreateMode: isCreateMode,
      );
    });
  }
}
