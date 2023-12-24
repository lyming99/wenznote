const scoreArray = [Rating.easy, Rating.good, Rating.hard, Rating.again];

enum State {
  newCard,
  learning,
  review,
  relearning;

  static State fromJson(String? json) {
    if (json == State.newCard.name) {
      return State.newCard;
    }

    if (json == State.learning.name) {
      return State.learning;
    }

    if (json == State.review.name) {
      return State.review;
    }

    if (json == State.relearning.name) {
      return State.relearning;
    }

    return State.newCard;
  }
}

enum Rating {
  again,
  hard,
  good,
  easy;

  static Rating fromJson(String? json) {
    if (json == Rating.again.name) {
      return Rating.again;
    }
    if (json == Rating.hard.name) {
      return Rating.hard;
    }
    if (json == Rating.hard.name) {
      return Rating.hard;
    }
    if (json == Rating.hard.name) {
      return Rating.hard;
    }
    return Rating.again;
  }
}

class Card {
  DateTime due;

  double stability;

  double difficulty;

  double elapsedDays;

  double scheduledDays;

  double reps;

  double lapses;

  State state;

  DateTime lastReview;

  Card({
    required this.due,
    required this.stability,
    required this.difficulty,
    required this.elapsedDays,
    required this.scheduledDays,
    required this.reps,
    required this.lapses,
    required this.state,
    required this.lastReview,
  });

  Card copyWith({
    DateTime? due,
    double? stability,
    double? difficulty,
    double? elapsedDays,
    double? scheduledDays,
    double? reps,
    double? lapses,
    State? state,
    DateTime? lastReview,
  }) {
    return Card(
      due: due ?? this.due,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      elapsedDays: elapsedDays ?? this.elapsedDays,
      scheduledDays: scheduledDays ?? this.scheduledDays,
      reps: reps ?? this.reps,
      lapses: lapses ?? this.lapses,
      state: state ?? this.state,
      lastReview: lastReview ?? this.lastReview,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "due": this.due.toIso8601String(),
      "stability": this.stability,
      "difficulty": this.difficulty,
      "elapsedDays": this.elapsedDays,
      "scheduledDays": this.scheduledDays,
      "reps": this.reps,
      "lapses": this.lapses,
      "state": this.state.name,
      "lastReview": this.lastReview.toIso8601String(),
    };
  }

  factory Card.fromJson(Map<String, dynamic> json) {
    return Card(
      due: DateTime.parse(json["due"]),
      stability: json["stability"],
      difficulty: json["difficulty"],
      elapsedDays: json["elapsedDays"],
      scheduledDays: json["scheduledDays"],
      reps: (json["reps"]),
      lapses: (json["lapses"]),
      state: State.fromJson(json["state"]),
      lastReview: DateTime.parse(json["lastReview"]),
    );
  }
//
}

class ReviewLog {
  Rating rating;

  double scheduledDays;

  double elapsedDays;

  DateTime review;

  State state;

  ReviewLog({
    required this.rating,
    required this.scheduledDays,
    required this.elapsedDays,
    required this.review,
    required this.state,
  });

  Map<String, dynamic> toJson() {
    return {
      "rating": this.rating.name,
      "scheduledDays": this.scheduledDays,
      "elapsedDays": this.elapsedDays,
      "review": this.review.toIso8601String(),
      "state": this.state.name,
    };
  }

  factory ReviewLog.fromJson(Map<String, dynamic> json) {
    return ReviewLog(
      rating: Rating.fromJson(json["rating"]),
      scheduledDays: (json["scheduledDays"]),
      elapsedDays: (json["elapsedDays"]),
      review: DateTime.parse(json["review"]),
      state: State.fromJson(json["state"]),
    );
  }
//
}

class SchedulingInfo {
  Card card;
  ReviewLog reviewLog;

  SchedulingInfo({
    required this.card,
    required this.reviewLog,
  });

  factory SchedulingInfo.fromJson(Map<String, dynamic> json) {
    return SchedulingInfo(
      card: Card.fromJson(json["card"]),
      reviewLog: ReviewLog.fromJson(json["reviewLog"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "card": this.card.toJson(),
      "reviewLog": this.reviewLog.toJson(),
    };
  }
}

class SchedulingCards {
  Card again;
  Card hard;
  Card good;
  Card easy;

  SchedulingCards({
    required this.again,
    required this.hard,
    required this.good,
    required this.easy,
  });

  void updateState(State state) {
    switch (state) {
      case State.newCard:
        again.state = State.learning;
        hard.state = State.learning;
        good.state = State.learning;
        easy.state = State.review;
        again.lapses += 1;
        break;
      case State.learning:
      case State.relearning:
        again.state = state;
        hard.state = state;
        good.state = State.review;
        easy.state = State.review;
        break;

      case State.review:
        again.state = State.relearning;
        hard.state = State.learning;
        good.state = State.learning;
        easy.state = State.review;
        again.lapses += 1;
        break;
    }
  }

  void schedule(DateTime now, double hardInterval, double goodInterval,
      double easyInterval) {
    again.scheduledDays = 0;
    hard.scheduledDays = hardInterval;
    good.scheduledDays = goodInterval;
    easy.scheduledDays = easyInterval;
    again.due = now.add(const Duration(minutes: 5));
    hard.due =
        now.add(Duration(seconds: (24 * 60 * 60 * hardInterval).toInt()));
    good.due =
        now.add(Duration(seconds: (24 * 60 * 60 * goodInterval).toInt()));
    easy.due =
        now.add(Duration(seconds: (24 * 60 * 60 * easyInterval).toInt()));
  }

  Map<Rating, SchedulingInfo> recordLog(Card card, DateTime now) {
    return {
      Rating.again: SchedulingInfo(
          card: again,
          reviewLog: ReviewLog(
            rating: Rating.again,
            scheduledDays: again.scheduledDays,
            elapsedDays: card.elapsedDays,
            review: now,
            state: card.state,
          )),
      Rating.hard: SchedulingInfo(
          card: hard,
          reviewLog: ReviewLog(
            rating: Rating.hard,
            scheduledDays: hard.scheduledDays,
            elapsedDays: card.elapsedDays,
            review: now,
            state: card.state,
          )),
      Rating.good: SchedulingInfo(
          card: good,
          reviewLog: ReviewLog(
            rating: Rating.good,
            scheduledDays: good.scheduledDays,
            elapsedDays: card.elapsedDays,
            review: now,
            state: card.state,
          )),
      Rating.easy: SchedulingInfo(
          card: easy,
          reviewLog: ReviewLog(
            rating: Rating.easy,
            scheduledDays: easy.scheduledDays,
            elapsedDays: card.elapsedDays,
            review: now,
            state: card.state,
          )),
    };
  }
}
