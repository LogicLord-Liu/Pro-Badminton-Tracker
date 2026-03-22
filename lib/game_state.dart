class ScoreState {
  final String id;
  final int sA;
  final int sB;
  final int dA;
  final int dB;
  final bool isAServing;
  final bool isDoubles;
  final int setNumber;
  final int setScoreA;
  final int setScoreB;

  ScoreState({
    required this.id,
    required this.sA,
    required this.sB,
    required this.dA,
    required this.dB,
    required this.isAServing,
    required this.isDoubles,
    required this.setNumber,
    required this.setScoreA,
    required this.setScoreB,
  });

  ScoreState copyWith({
    int? sA,
    int? sB,
    int? setScoreA,
    int? setScoreB,
  }) {
    return ScoreState(
      id: id,
      sA: sA ?? this.sA,
      sB: sB ?? this.sB,
      dA: dA,
      dB: dB,
      isAServing: isAServing,
      isDoubles: isDoubles,
      setNumber: setNumber,
      setScoreA: setScoreA ?? this.setScoreA,
      setScoreB: setScoreB ?? this.setScoreB,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'a': sA,
    'b': sB,
    'da': dA,
    'db': dB,
    'srv': isAServing ? 1 : 0,
    'dbl': isDoubles ? 1 : 0,
    'sn': setNumber,
    'sa': setScoreA,
    'sb': setScoreB,
  };

  factory ScoreState.fromJson(Map<String, dynamic> json) {
    return ScoreState(
      id: json['id'],
      sA: json['a'],
      sB: json['b'],
      dA: json['da'],
      dB: json['db'],
      isAServing: json['srv'] == 1,
      isDoubles: json['dbl'] == 1,
      setNumber: json['sn'],
      setScoreA: json['sa'],
      setScoreB: json['sb'],
    );
  }
}

class SetGroup {
  final int setNumber;
  final List<ScoreState> points; // 局内点位，时间正序 [0-0, 1-0, 1-1...]
  final int setScoreA;
  final int setScoreB;
  final bool isFinished;

  final Map<String, bool> aWonMap = {};
  final Map<String, bool> bWonMap = {};

  SetGroup({
    required this.setNumber,
    required this.points,
    required this.setScoreA,
    required this.setScoreB,
    required this.isFinished,
  }) {
    _precomputeWinners();
  }

  void _precomputeWinners() {
    for (int i = 0; i < points.length; i++) {
      final current = points[i];
      if (i > 0) {
        final prev = points[i - 1];
        aWonMap[current.id] = current.sA > prev.sA;
        bWonMap[current.id] = current.sB > prev.sB;
      } else {
        aWonMap[current.id] = current.sA > 0;
        bWonMap[current.id] = current.sB > 0;
      }
    }
  }
}
