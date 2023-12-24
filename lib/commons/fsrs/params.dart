import 'dart:math' as math;

import 'package:note/commons/fsrs/models.dart';

class Parameters {
  double requestRetention;

  double maximumInterval;

  double easyBonus;

  double hardFactor;

  Weights weights;

  Parameters({
    required this.requestRetention,
    required this.maximumInterval,
    required this.easyBonus,
    required this.hardFactor,
    required this.weights,
  });

  void initDS(SchedulingCards cards) {
    cards.again.difficulty = initDifficulty(Rating.again);
    cards.again.stability = initStability(Rating.again);
    cards.hard.difficulty = initDifficulty(Rating.hard);
    cards.hard.stability = initStability(Rating.hard);
    cards.good.difficulty = initDifficulty(Rating.good);
    cards.good.stability = initStability(Rating.good);
    cards.easy.difficulty = initDifficulty(Rating.easy);
    cards.easy.stability = initStability(Rating.easy);
  }

  void nextDS(SchedulingCards cards, double lastD, double lastS,
      double retrievability) {
    cards.again.difficulty = nextDifficulty(lastD, Rating.again);
    cards.again.stability =
        nextForgetStability(cards.again.difficulty, lastS, retrievability);
    cards.hard.difficulty = nextDifficulty(lastD, Rating.hard);
    cards.hard.stability =
        nextRecallStability(cards.hard.difficulty, lastS, retrievability);
    cards.good.difficulty = nextDifficulty(lastD, Rating.good);
    cards.good.stability =
        nextRecallStability(cards.good.difficulty, lastS, retrievability);
    cards.easy.difficulty = nextDifficulty(lastD, Rating.easy);
    cards.easy.stability =
        nextRecallStability(cards.easy.difficulty, lastS, retrievability);
  }

  double initStability(Rating rating) {
    return math.max(0.1, weights[0] + weights[1] * rating.index);
  }

  double initDifficulty(Rating rating) {
    return constrainDifficulty(weights[2] + weights[3] * (rating.index - 2));
  }

  double constrainDifficulty(double d) {
    return math.min(math.max(d, 1), 10);
  }

  double nextInterval(double s) {
    var newInterval = s * math.log(requestRetention) / math.log(0.9);
    return math.max(math.min(newInterval.roundToDouble(), maximumInterval), 1);
  }

  double nextDifficulty(double d, Rating rating) {
    var nextD = d + weights[4] * (rating.index - 2);
    return constrainDifficulty(meanReversion(weights[2], nextD));
  }

  double meanReversion(double init, double current) {
    return weights[5] * init + (1 - weights[5]) * current;
  }

  double nextRecallStability(double d, double s, double r) {
    return s *
        (1 +
            math.exp(weights[6]) *
                (11 - d) *
                math.pow(s, weights[7]) *
                (math.exp((1 - r) * weights[8]) - 1));
  }

  double nextForgetStability(double d, double s, double r) {
    return weights[9] *
        math.pow(d, weights[10]) *
        math.pow(s, weights[11]) *
        math.exp((1 - r) * weights[12]);
  }

  Map<Rating, SchedulingInfo> repeat(Card card, DateTime now) {
    if (card.state == State.newCard) {
      card.elapsedDays = 0;
    } else {
      card.elapsedDays = ((now.millisecondsSinceEpoch -
                  card.lastReview.millisecondsSinceEpoch) /
              1000 /
              60 /
              60 ~/
              24)
          .toDouble();
    }
    card.lastReview = now;
    card.reps += 1;
    var s = SchedulingCards(
      again: card.copyWith(),
      hard: card.copyWith(),
      good: card.copyWith(),
      easy: card.copyWith(),
    );
    s.updateState(card.state);
    switch (card.state) {
      case State.newCard:
        initDS(s);
        s.again.due = now.add(const Duration(minutes: 1));
        s.hard.due = now.add(const Duration(minutes: 5));
        s.good.due = now.add(const Duration(minutes: 10));
        var easyInterval = nextInterval(s.easy.stability * easyBonus);
        s.easy.scheduledDays = easyInterval;
        s.easy.due = now.add(Duration(days: easyInterval.toInt()));
        break;
      case State.learning:
      case State.relearning:
        var hardInterval = 0.0;
        var goodInterval = nextInterval(s.good.stability);
        var easyInterval = math.max(
            nextInterval(s.easy.stability * easyBonus), goodInterval + 1);
        s.schedule(now, hardInterval, goodInterval, easyInterval);
        break;

      case State.review:
        var interval = card.elapsedDays.toDouble();
        var lastD = card.difficulty;
        var lastS = card.stability;
        var retrievability = math.exp(math.log(0.9) * interval / lastS);
        nextDS(s, lastD, lastS, retrievability);

        var hardInterval = nextInterval(lastS * hardFactor);
        var goodInterval = nextInterval(s.good.stability);
        hardInterval = math.min(hardInterval, goodInterval);
        goodInterval = math.max(goodInterval, hardInterval + 1);
        var easyInterval = math.max(
            nextInterval(s.easy.stability * easyBonus), goodInterval + 1);
        s.schedule(now, hardInterval, goodInterval, easyInterval);
        break;
    }
    return s.recordLog(card, now);
  }
}

typedef Weights = List<double>;

Parameters defaultParameters() {
  return Parameters(
    requestRetention: 0.9,
    maximumInterval: 36500,
    easyBonus: 1.3,
    hardFactor: 1.2,
    weights: defaultWeights(),
  );
}

Weights defaultWeights() {
  return [1, 1, 5, -0.5, -0.5, 0.2, 1.4, -0.12, 0.8, 2, -0.2, 0.2, 1];
}
