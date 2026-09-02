import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/routine_model.dart';
import '../models/history_model.dart';
import '../services/history_service.dart';
import 'dart:math';

class RoutineProvider extends ChangeNotifier {
  List<Routine> _routines = [];
  List<HistoryEntry> _history = [];
  final _uuid = const Uuid();
  final HistoryService _historyService = HistoryService();

  // Legacy (single-user) keys — migration ke liye
  static const _legacyRoutineKey = 'peacemind_routines';
  static const _legacyHistoryKey = 'peacemind_history';

  String? _boundUid;
  String get _routineKey => 'peacemind_routines_${_boundUid ?? 'guest'}';
  String get _historyKey => 'peacemind_history_${_boundUid ?? 'guest'}';

  List<Routine> get routines => _routines;
  List<HistoryEntry> get history => _history;

  RoutineProvider() {
    _loadData();
  }

  /// AuthProvider user login/logout par ye call karta hai.
  /// User badalne par us user ka data load hota hai (per-user keys)
  /// aur Firestore se history merge ho jati hai.
  Future<void> bindUser(String? uid) async {
    if (_boundUid == uid) return;
    _boundUid = uid;
    await _loadData();
    if (uid != null) {
      await _syncHistoryWithCloud();
    }
    if (hasListeners) notifyListeners();
  }

  /// Cloud history fetch kar ke local se merge karta hai
  /// (union by id — koi duplicate nahi), phir dono taraf save.
  Future<void> _syncHistoryWithCloud() async {
    try {
      final cloudEntries = await _historyService.fetchEntries();
      if (cloudEntries.isEmpty) {
        // Local-only entries cloud par push karo
        for (final entry in _history) {
          await _historyService.saveEntry(entry);
        }
        return;
      }

      final byId = <String, HistoryEntry>{};
      for (final e in _history) {
        byId[e.id] = e;
      }
      var changed = false;
      for (final e in cloudEntries) {
        if (!byId.containsKey(e.id)) {
          byId[e.id] = e;
          changed = true;
        }
      }
      if (changed) {
        _history = byId.values.toList()
          ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
        await _saveHistory();
      }
      // Local-only entries cloud par push karo
      final cloudIds = cloudEntries.map((e) => e.id).toSet();
      for (final entry in _history) {
        if (!cloudIds.contains(entry.id)) {
          await _historyService.saveEntry(entry);
        }
      }
    } catch (e) {
      debugPrint('RoutineProvider cloud sync error: $e');
    }
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    var routineStr = prefs.getString(_routineKey);
    var historyStr = prefs.getString(_historyKey);

    // One-time migration: pehle sab users shared keys use karte the
    if (_boundUid != null &&
        routineStr == null &&
        historyStr == null &&
        prefs.containsKey(_legacyHistoryKey)) {
      routineStr = prefs.getString(_legacyRoutineKey);
      historyStr = prefs.getString(_legacyHistoryKey);
      if (routineStr != null) {
        await prefs.setString(_routineKey, routineStr);
      }
      if (historyStr != null) {
        await prefs.setString(_historyKey, historyStr);
      }
    }

    if (routineStr != null) _routines = Routine.listFromJson(routineStr);
    if (historyStr != null) _history = HistoryEntry.listFromJson(historyStr);
    _history.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    notifyListeners();
  }

  Future<void> _saveRoutines() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_routineKey, Routine.listToJson(_routines));
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_historyKey, HistoryEntry.listToJson(_history));
  }

  /// Public: NOVA call / chat jaisi bahar ki activities history mein
  /// add karne ke liye. Local + Firestore dono mein save hota hai.
  void addHistoryEntry(HistoryEntry entry) {
    _history.add(entry);
    _history.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    _saveHistory();
    _historyService.saveEntry(entry);
    notifyListeners();
  }

  // ── Today's routines ──
  List<Routine> getTodayRoutines() {
    final now = DateTime.now();
    final weekday = now.weekday - 1; // 0=Monday
    return _routines.where((r) => r.days[weekday]).toList()
      ..sort((a, b) => a.time.compareTo(b.time));
  }

  // ── Next upcoming routine ──
  Routine? getNextRoutine() {
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;
    final todayRoutines = getTodayRoutines().where((r) => !r.isCompleted).toList();

    Routine? next;
    int minDiff = 24 * 60;
    for (var r in todayRoutines) {
      final parts = r.time.split(':');
      final rMinutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);
      final diff = rMinutes - currentMinutes;
      if (diff >= 0 && diff < minDiff) {
        minDiff = diff;
        next = r;
      }
    }
    return next;
  }

  void addRoutine({
    required String title,
    required String category,
    required String time,
    required List<bool> days,
    String? coverImage,
  }) {
    _routines.add(Routine(
      id: _uuid.v4(),
      title: title,
      category: category,
      time: time,
      days: days,
      coverImage: coverImage,
    ));
    _saveRoutines();
    notifyListeners();
  }

  void updateRoutine(Routine updated) {
    final idx = _routines.indexWhere((r) => r.id == updated.id);
    if (idx != -1) {
      _routines[idx] = updated;
      _saveRoutines();
      notifyListeners();
    }
  }

  void deleteRoutine(String id) {
    _routines.removeWhere((r) => r.id == id);
    _saveRoutines();
    notifyListeners();
  }

  /// Home screen ke built-in exercise tasks ke friendly titles
  String _taskTitleFor(String id) {
    switch (id) {
      case 'ex_breathing':
        return 'Breathing Exercise';
      case 'ex_grounding':
        return 'Grounding Exercise';
      case 'ex_scan':
        return 'Body Scan';
      case 'ex_walking':
        return 'Walking Meditation';
      default:
        return 'Wellbeing Task';
    }
  }

  void completeRoutine(String id, int moodScore, {String? notes}) {
    final idx = _routines.indexWhere((r) => r.id == id);

    HistoryEntry entry;

    if (idx != -1) {
      final routine = _routines[idx];
      routine.isCompleted = true;
      routine.completedAt = DateTime.now();
      routine.moodScore = moodScore;

      entry = HistoryEntry(
        id: _uuid.v4(),
        routineId: routine.id,
        routineTitle: routine.title,
        category: routine.category,
        completedAt: DateTime.now(),
        moodScore: moodScore,
        notes: notes,
      );
      _saveRoutines();
    } else {
      // Home screen ke built-in exercise tasks routines list mein
      // nahi hote — magar unki history zaroor save hoti hai.
      final isExercise = id.startsWith('ex_');
      entry = HistoryEntry(
        id: _uuid.v4(),
        routineId: id,
        routineTitle: _taskTitleFor(id),
        category: isExercise ? 'exercise' : 'task',
        completedAt: DateTime.now(),
        moodScore: moodScore,
        notes: notes,
      );
    }

    _history.add(entry);

    _saveHistory();
    _historyService.saveEntry(entry); // Firebase backup
    notifyListeners();
  }

  void completeExercise({
    required String exerciseId,
    required String exerciseTitle,
    required Duration duration,
    required int cycles,
  }) {
    final entry = HistoryEntry(
      id: _uuid.v4(),
      routineId: exerciseId,
      routineTitle: exerciseTitle,
      category: 'exercise',
      completedAt: DateTime.now(),
      moodScore: 80,
      notes:
          'Completed in ${duration.inMinutes}m ${duration.inSeconds % 60}s ($cycles cycles)',
    );
    _history.add(entry);
    _saveHistory();
    _historyService.saveEntry(entry); // Firebase backup
    notifyListeners();
  }

  void resetDailyRoutines() {
    for (var r in _routines) {
      r.isCompleted = false;
      r.completedAt = null;
      r.moodScore = null;
    }
    _saveRoutines();
    notifyListeners();
  }

  // ── History helpers ──
  List<HistoryEntry> getHistoryForLastDays(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _history.where((h) => h.completedAt.isAfter(cutoff)).toList();
  }

  int getCurrentStreak() {
    if (_history.isEmpty) return 0;
    final sorted = _history.map((h) => DateTime(h.completedAt.year, h.completedAt.month, h.completedAt.day))
      .toSet().toList()..sort((a, b) => b.compareTo(a));

    int streak = 1;
    for (int i = 0; i < sorted.length - 1; i++) {
      if (sorted[i].difference(sorted[i+1]).inDays == 1) {
        streak++;
      } else {
        break;
      }
    }
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    if (sorted.isNotEmpty && sorted.first != todayDate && sorted.first != todayDate.subtract(const Duration(days: 1))) {
      return 0;
    }
    return streak;
  }

  Map<String, int> getCategoryCounts() {
    final map = <String, int>{};
    for (var h in _history) {
      map[h.category] = (map[h.category] ?? 0) + 1;
    }
    return map;
  }

  Map<DateTime, int> getDailyCompletionCounts() {
    final map = <DateTime, int>{};
    for (var h in _history) {
      final day = DateTime(h.completedAt.year, h.completedAt.month, h.completedAt.day);
      map[day] = (map[day] ?? 0) + 1;
    }
    return map;
  }

  // ── Optional: Manual dummy data (call from debug menu if needed) ──
  Future<void> generateDummyData() async {
    // Only call this from a debug button, NOT in constructor
    final now = DateTime.now();
    final random = Random();

    _routines.clear();
    _history.clear();

    _routines.addAll([
      Routine(
        id: 'r1', title: 'Morning Check-in', category: 'morning', time: '08:00',
        days: [true, true, true, true, true, false, false],
        coverImage: 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=400&q=80',
      ),
      Routine(
        id: 'r2', title: 'Box Breathing', category: 'afternoon', time: '14:00',
        days: [true, true, true, true, true, true, true],
      ),
      Routine(
        id: 'r3', title: 'Evening Journal', category: 'evening', time: '20:00',
        days: [true, true, true, true, true, true, true],
        coverImage: 'https://images.unsplash.com/photo-1519834785169-98be25ec3f84?w=400&q=80',
      ),
    ]);

    for (int day = 0; day < 14; day++) {
      final date = now.subtract(Duration(days: day));
      final sessions = random.nextInt(3) + 1;
      for (int s = 0; s < sessions; s++) {
        _history.add(HistoryEntry(
          id: 'h_${day}_$s',
          routineId: 'r${random.nextInt(3) + 1}',
          routineTitle: ['Morning Check-in','Box Breathing','Evening Journal'][random.nextInt(3)],
          category: ['morning','afternoon','evening'][random.nextInt(3)],
          completedAt: date.add(Duration(hours: 7 + random.nextInt(14))),
          moodScore: [20, 40, 60, 80, 100][random.nextInt(5)],
          notes: random.nextBool() ? ['Felt calm','Very anxious','Much better','Focused','Relaxed'][random.nextInt(5)] : null,
        ));
      }
    }
    _history.sort((a, b) => b.completedAt.compareTo(a.completedAt));

    await _saveRoutines();
    await _saveHistory();
    notifyListeners();
  }
}