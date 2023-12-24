import 'dart:convert';

import 'package:note/commons/fsrs/models.dart';
import 'package:note/commons/fsrs/params.dart';

void main() {
  var p = defaultParameters();
  var card = Card(
    due: DateTime.now(),
    stability: 0,
    difficulty: 0,
    elapsedDays: 0,
    scheduledDays: 0,
    reps: 0,
    lapses: 0,
    state: State.newCard,
    lastReview: DateTime.now(),
  );
  var now = DateTime.now();
  var schedulingCards = p.repeat(card, now);
  print('hello');
  var aCard = schedulingCards[Rating.hard]?.card;
  var aLog = schedulingCards[Rating.hard]?.reviewLog;
  var aCardJson = jsonEncode(aCard?.toJson());
  var aLogJson = jsonEncode(aLog?.toJson());
  print('$aCardJson');
  print('$aLogJson');
  var nCard = Card.fromJson(jsonDecode(aCardJson));
  var nLog = ReviewLog.fromJson(jsonDecode(aLogJson));
  print('test ok...');
}
