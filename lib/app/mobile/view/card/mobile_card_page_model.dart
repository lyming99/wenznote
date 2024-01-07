import 'package:flutter/material.dart';
import 'package:note/model/card/po/card_set_po.dart';

class MobileCardModel {
  MobileCardModel({
    required this.card,
    this.todayStudyQueueCount = 0,
    this.todayStudyCount = 0,
    this.reviewCount = 0,
  });

  int todayStudyQueueCount;

  int todayStudyCount;

  int reviewCount;

  CardSetPO card;

  String? get title => card.name;

  Color get color =>
      card.color == null ? Colors.blue.shade100 : Color(card.color!);
}
