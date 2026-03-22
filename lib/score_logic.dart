import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_state.dart';

class ScoreController extends ChangeNotifier {
  static const String _storageKey = 'badminton_match_history';
  static const String _playersAKey = 'players_a_names';
  static const String _playersBKey = 'players_b_names';

  List<ScoreState> _history = [];
  int matchType = 3;
  bool isDoubles = false;
  final GlobalKey exportBoundaryKey = GlobalKey();

  List<String> playersA = ["TEAM A"];
  List<String> playersB = ["TEAM B"];
  String get displayNameA => playersA.join(" / ");
  String get displayNameB => playersB.join(" / ");

  int currentScoreA = 0;
  int currentScoreB = 0;
  int setsA = 0;
  int setsB = 0;
  int currentSet = 1;
  bool isAServing = true;

  bool _intervalProcessedInCurrentSet = false;
  bool _showingIntervalHint = false;

  bool _isMatchFinished = false;
  bool get isMatchFinished => _isMatchFinished;

  List<ScoreState> get history => _history;
  bool get canUndo => _history.isNotEmpty;

  int get winThreshold => (matchType / 2).ceil();

  List<SetGroup> _groupedHistoryCache = [];
  List<SetGroup> get groupedHistory => _groupedHistoryCache;

  bool get isInterval => _showingIntervalHint;
  bool get hasReachedWinTarget =>
      setsA >= winThreshold || setsB >= winThreshold;

  Timer? _intervalTimer;
  int _remainingSeconds = 0;
  int get remainingSeconds => _remainingSeconds;
  bool get isTimerRunning => _intervalTimer != null;

  String get intervalText {
    if (_isMatchFinished) return "MATCH FINISHED";
    if (isTimerRunning) {
      String type = (currentScoreA == 11 || currentScoreB == 11)
          ? "INTERVAL"
          : "SET REST";
      return "$type: $_remainingSeconds S";
    }
    if (_showingIntervalHint) return "11 POINTS - INTERVAL";
    if (currentScoreA == 0 && currentScoreB == 0 && currentSet > 1) {
      return "SET END - REST";
    }
    return "";
  }

  ScoreController() {
    _loadFromLocal();
  }

  void _startIntervalTimer(int seconds) {
    _stopIntervalTimer();
    _remainingSeconds = seconds;
    _showingIntervalHint = true;

    _intervalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        stopIntervalManually();
      }
    });
    notifyListeners();
  }

  void stopIntervalManually() {
    _stopIntervalTimer();
    _showingIntervalHint = false;
    _intervalProcessedInCurrentSet = true;
    notifyListeners();
  }

  void _stopIntervalTimer() {
    _intervalTimer?.cancel();
    _intervalTimer = null;
    _remainingSeconds = 0;
  }

  Future<void> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      playersA = prefs.getStringList(_playersAKey) ?? ["TEAM A"];
      playersB = prefs.getStringList(_playersBKey) ?? ["TEAM B"];
      final String? jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        _history = decoded.map((e) => ScoreState.fromJson(e)).toList();

        if (_history.isNotEmpty) {
          final last = _history.last;
          currentScoreA = last.sA;
          currentScoreB = last.sB;
          isAServing = last.isAServing;
          currentSet = last.setNumber;
          setsA = last.setScoreA;
          setsB = last.setScoreB;
          isDoubles = last.isDoubles;

          _isMatchFinished = (setsA >= winThreshold || setsB >= winThreshold);
          _intervalProcessedInCurrentSet =
              (currentScoreA > 11 || currentScoreB > 11);

          _updateGroupedHistory();
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("Storage Load Error: $e");
    }
  }

  Future<void> saveToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_history.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  void _updateGroupedHistory() {
    if (_history.isEmpty && currentScoreA == 0 && currentScoreB == 0) {
      _groupedHistoryCache = [];
      return;
    }

    Map<int, List<ScoreState>> map = {};
    for (var p in _history) {
      map.putIfAbsent(p.setNumber, () => []).add(p);
    }
    if (!map.containsKey(currentSet)) map[currentSet] = [];

    _groupedHistoryCache = map.entries
        .map((e) {
          int sA = e.key == currentSet
              ? currentScoreA
              : (e.value.isEmpty ? 0 : e.value.last.sA);
          int sB = e.key == currentSet
              ? currentScoreB
              : (e.value.isEmpty ? 0 : e.value.last.sB);
          return SetGroup(
            setNumber: e.key,
            points: e.value.toList(),
            setScoreA: sA,
            setScoreB: sB,
            isFinished: e.key < currentSet || _isMatchFinished,
          );
        })
        .toList()
        .reversed
        .toList();
  }

  bool get _isSetEnded {
    if (_isMatchFinished) return false;
    if (currentScoreA == 0 && currentScoreB == 0) return false;

    return (currentScoreA >= 21 || currentScoreB >= 21) &&
            (currentScoreA - currentScoreB).abs() >= 2 ||
        currentScoreA == 30 ||
        currentScoreB == 30;
  }

  bool get canModifyScore =>
      !_isMatchFinished && !_isSetEnded && !isTimerRunning;

  void updateScore(bool isA, int delta) {
    if (_isMatchFinished) return;

    // 间歇计时期间，禁止加分和减分操作
    if (isTimerRunning) return;

    if (!canModifyScore && delta > 0) return;

    if (_showingIntervalHint && delta > 0) {
      _showingIntervalHint = false;
      _intervalProcessedInCurrentSet = true;
    }

    if (delta < 0) {
      if (isA && currentScoreA <= 0) return;
      if (!isA && currentScoreB <= 0) return;

      if (isA) {
        currentScoreA += delta;
      } else {
        currentScoreB += delta;
      }

      if (_history.isNotEmpty) {
        isAServing = _history.last.isAServing;
      }

      if (currentScoreA < 11 && currentScoreB < 11) {
        _intervalProcessedInCurrentSet = false;
        _showingIntervalHint = false;
      } else if (currentScoreA == 11 || currentScoreB == 11) {
        _intervalProcessedInCurrentSet = false;
        _showingIntervalHint = true;
      } else {
        _intervalProcessedInCurrentSet = true;
        _showingIntervalHint = false;
      }

      _updateGroupedHistory();
      saveToLocal();
      notifyListeners();
      return;
    }

    // 加分逻辑
    if (isA) {
      currentScoreA += delta;
      isAServing = true;
    } else {
      currentScoreB += delta;
      isAServing = false;
    }

    // 检查 11 分间歇 (BWF 规则：60秒)
    if (!_intervalProcessedInCurrentSet &&
        (currentScoreA == 11 || currentScoreB == 11)) {
      HapticFeedback.heavyImpact();
      _startIntervalTimer(60);
    }

    if (currentScoreA < 11 && currentScoreB < 11) {
      _intervalProcessedInCurrentSet = false;
      _showingIntervalHint = false;
    }

    _history.add(
      ScoreState(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        sA: currentScoreA,
        sB: currentScoreB,
        dA: isA ? delta : 0,
        dB: !isA ? delta : 0,
        isAServing: isAServing,
        isDoubles: isDoubles,
        setNumber: currentSet,
        setScoreA: setsA,
        setScoreB: setsB,
      ),
    );

    _checkSetOver();
    _updateGroupedHistory();
    saveToLocal();
    notifyListeners();
  }

  void _checkSetOver() {
    int sA = currentScoreA;
    int sB = currentScoreB;
    bool setOver = false;

    if (sA == 30 || sB == 30) {
      setOver = true;
    } else if ((sA >= 21 || sB >= 21) && (sA - sB).abs() >= 2) {
      setOver = true;
    }

    if (setOver) {
      if (sA > sB) {
        setsA++;
      } else {
        setsB++;
      }

      if (setsA >= winThreshold || setsB >= winThreshold) {
        _isMatchFinished = true;
      } else {
        currentSet++;
        currentScoreA = 0;
        currentScoreB = 0;
        isAServing = sA > sB;
        _intervalProcessedInCurrentSet = false;
        _showingIntervalHint = false;
        // 局间休息 (BWF 规则：120秒)
        _startIntervalTimer(120);
      }
    }
  }

  void undo() {
    if (_history.isEmpty) return;

    if (isTimerRunning) {
      _stopIntervalTimer();
    }

    _history.removeLast();

    if (_history.isEmpty) {
      resetAll();
    } else {
      final last = _history.last;
      currentScoreA = last.sA;
      currentScoreB = last.sB;
      isAServing = last.isAServing;
      currentSet = last.setNumber;
      setsA = last.setScoreA;
      setsB = last.setScoreB;
      _isMatchFinished = false;

      if (currentScoreA < 11 && currentScoreB < 11) {
        _intervalProcessedInCurrentSet = false;
        _showingIntervalHint = false;
      } else if (currentScoreA == 11 || currentScoreB == 11) {
        _intervalProcessedInCurrentSet = false;
        _showingIntervalHint = true;
      } else {
        _intervalProcessedInCurrentSet = true;
        _showingIntervalHint = false;
      }
    }

    _updateGroupedHistory();
    saveToLocal();
    notifyListeners();
  }

  void resetAll() {
    _stopIntervalTimer();

    _history = [];
    currentScoreA = 0;
    currentScoreB = 0;
    setsA = 0;
    setsB = 0;
    currentSet = 1;
    isAServing = true;
    _isMatchFinished = false;

    _groupedHistoryCache = [];

    saveToLocal();
    notifyListeners();
  }

  void resetCurrentSet() {
    if (_isMatchFinished) return;
    _stopIntervalTimer();
    currentScoreA = 0;
    currentScoreB = 0;
    _intervalProcessedInCurrentSet = false;
    _showingIntervalHint = false;
    saveToLocal();
    notifyListeners();
  }

  void switchMode(bool doubles) {
    isDoubles = doubles;
    if (isDoubles) {
      if (playersA.length < 2) playersA.add("PLAYER 2");
      if (playersB.length < 2) playersB.add("PLAYER 2");
    } else {
      playersA = [playersA.first];
      playersB = [playersB.first];
    }
    saveToLocal();
    notifyListeners();
  }

  void setMatchType(int type) {
    matchType = type;
    resetAll();
  }

  void toggleServing() {
    if (_isMatchFinished || !canModifyScore) return;
    isAServing = !isAServing;
    saveToLocal();
    notifyListeners();
  }

  void jumpToHistory(int index) {
    if (index < 0 || index >= _history.length) return;
    _stopIntervalTimer();
    _history = _history.sublist(0, index + 1);
    final target = _history.last;

    currentScoreA = target.sA;
    currentScoreB = target.sB;
    isAServing = target.isAServing;
    currentSet = target.setNumber;
    setsA = target.setScoreA;
    setsB = target.setScoreB;
    _isMatchFinished = false;

    if (currentScoreA < 11 && currentScoreB < 11) {
      _intervalProcessedInCurrentSet = false;
      _showingIntervalHint = false;
    } else if (currentScoreA == 11 || currentScoreB == 11) {
      _intervalProcessedInCurrentSet = false;
      _showingIntervalHint = true;
    } else {
      _intervalProcessedInCurrentSet = true;
      _showingIntervalHint = false;
    }

    _updateGroupedHistory();
    saveToLocal();
    notifyListeners();
  }

  void updatePlayerName(bool isA, int index, String name) async {
    if (isA) {
      if (index >= 0 && index < playersA.length) playersA[index] = name;
    } else {
      if (index >= 0 && index < playersB.length) playersB[index] = name;
    }
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.setStringList(_playersAKey, playersA),
        prefs.setStringList(_playersBKey, playersB),
        saveToLocal(),
      ]);
    } catch (e) {
      debugPrint("Save Name Error: $e");
    }
  }

  void deleteHistoryPoint(String id) {
    int index = _history.indexWhere((h) => h.id == id);
    if (index == -1) return;

    final removedPoint = _history.removeAt(index);
    final removedSetNumber = removedPoint.setNumber;

    if (removedSetNumber == currentSet) {
      int currentSetTotalA = 0;
      int currentSetTotalB = 0;
      for (var point in _history) {
        if (point.setNumber == currentSet) {
          currentSetTotalA += point.dA;
          currentSetTotalB += point.dB;
        }
      }

      currentScoreA = currentSetTotalA;
      currentScoreB = currentSetTotalB;

      if (_history.isNotEmpty && _history.last.setNumber == currentSet) {
        isAServing = _history.last.isAServing;
      } else {
        isAServing = removedPoint.setScoreA > removedPoint.setScoreB;
      }

      if (currentScoreA < 11 && currentScoreB < 11) {
        _intervalProcessedInCurrentSet = false;
        _showingIntervalHint = false;
      } else if (currentScoreA == 11 || currentScoreB == 11) {
        _intervalProcessedInCurrentSet = false;
        _showingIntervalHint = true;
      } else {
        _intervalProcessedInCurrentSet = true;
        _showingIntervalHint = false;
      }
    }

    _isMatchFinished = false;

    _updateGroupedHistory();
    saveToLocal();
    notifyListeners();
  }

  void skipInterval() {
    if (isInterval) {
      stopIntervalManually();
    }
  }

  @override
  void dispose() {
    _intervalTimer?.cancel();
    super.dispose();
  }
}