import 'package:flutter/material.dart';
import 'package:note/app/windows/controller/card/win_card_set_detail_page_controller.dart';
import 'package:note/app/windows/model/card/win_card_set_item_vo.dart';
import 'package:note/app/windows/view/card/win_card_set_detail_page.dart';
import 'package:note/app/windows/widgets/win_edit_tab.dart';
import 'package:note/widgets/local_get_builder.dart';

class WinCardSetTab with ChangeNotifier, WinEditTabMixin {
  WinCardSetItemVO cardSet;
  WinCardSetDetailPageController? controller;

  WinCardSetTab({
    required this.cardSet,
  });

  @override
  Widget buildWidget(BuildContext context) {
    controller ??= WinCardSetDetailPageController(cardSet: cardSet);
    return createLocalGetBuilder(
        controller: controller!,
        builder: (context) {
          return WinCardSetDetailPage(
            controller: controller!,
          );
        });
  }

  @override
  String get tabId => "cardSet-${cardSet.cardSet.uuid}";

  @override
  void onOpenPage() {
    super.onOpenPage();
    controller?.fetchGraphxData();
  }
}
