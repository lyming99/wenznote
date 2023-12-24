import 'package:flutter/material.dart';
import 'package:note/model/card/po/card_set_po.dart';

class WinCardSetItemVO with ChangeNotifier {
  CardSetPO cardSet;
  int todayStudyQueueCount;
  int todayStudyCount;
  int reviewCount;

  WinCardSetItemVO({
    required this.cardSet,
    this.todayStudyQueueCount = 0,
    this.todayStudyCount = 0,
    this.reviewCount = 0,
  });

  String? get title => cardSet.name;

  Color get color =>
      cardSet.color == null ? Colors.blue.shade100 : Color(cardSet.color!);
}
