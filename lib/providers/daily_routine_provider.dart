import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/exercises.dart';
import '../models/exercise_models.dart';
import 'routine_provider.dart';

/// One auto-generated daily task — either an exercise or a journal entry.
class DailyTask {
  final String id;
  final String title;
  final String subtitle;
  final String category; // 'exercise' | 'journal'
  final ExerciseInfo? exerciseInfo; // non-null for exercise tasks
  bool isCompleted;
  DateTime? completedAt;

  DailyTask({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    this.exerciseInfo,
    this.isCompleted = false,
    this.completedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'category': category,
        'isCompleted': isCompleted,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory DailyTask.fromJson(Map<String, dynamic> json) => DailyTask(
        id: json['id'] as String,
        title: json['title'] as String,
        subtitle: json['subtitle'] as String? ?? '',
        category: json['category'] as String,
        isCompleted: json['isCompleted'] as bool? ?? false,
        completedAt: json['completedAt'] != null
            ? DateTime.tryParse(json['completedAt'] as String)
            : null,
      );
}

/// Business-layer provider that auto-generates exactly 5 tasks per day:
///   • 4 exercises (from the available exercise pool)
///   • 1 journaling entry
///
/// Selection avoids repeating yesterday's exact set where possible.
/// A fresh set regenerates automatically at the next day's local-date change.
///
/// Completion state is driven by each exercise's own finish condition
/// (ExercisePlayerScreen._finishSession) — this provider only tracks state.
class DailyRoutineProvider extends ChangeNotifier {
  static const _prefsKey = 'peacemind_daily_routine';
  static const _lastGenDateKey = 'peacemind_daily_routine_date';

  final RoutineProvider _routineProvider;

  List<DailyTask> _tasks = [];
  String _lastGenDate = '';

  List<DailyTask> get tasks => List.unmodifiable(_tasks);
  bool get allCompleted => _tasks.isNotEmpty && _tasks.every((t) => t.isCompleted);
  int get completedCount => _tasks.where((t) => t.isCompleted).length;
  int get totalCount => _tasks.length;

  DailyRoutineProvider({required RoutineProvider routineProvider})
      : _routineProvider = routineProvider;

  /// Call this on app start and on every resume to check for date change.
  Future<void> ensureTodayRoutine() async {
    final todayStr = _todayString();

    if (_lastGenDate == todayStr && _tasks.isNotEmpty) {
      // Already generated for today — just sync completion state
      _syncCompletionFromHistory();
      return;
    }

    // Date changed (or first load) → regenerate
    await _loadCached();

    if (_lastGenDate == todayStr && _tasks.isNotEmpty) {
      _syncCompletionFromHistory();
      notifyListeners();
      return;
    }

    // Generate fresh set for today
    _generateTodayRoutine();
    _lastGenDate = todayStr;
    await _persist();
    notifyListeners();
  }

  /// Marks a task complete by its exercise ID or journal ID.
  /// Called from ExercisePlayerScreen._finishSession or journal completion.
  void markTaskComplete(String taskId) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;
    if (_tasks[idx].isCompleted) return; // already done

    _tasks[idx].isCompleted = true;
    _tasks[idx].completedAt = DateTime.now();
    _persist();
    notifyListeners();
  }

  /// Map exercise player IDs → daily task IDs for completion sync.
  static const _exerciseIdToTaskId = {
    'box_breathing': 'daily_ex_breathing',
    'grounding': 'daily_ex_grounding',
    'body_scan': 'daily_ex_scan',
    'mind_walking': 'daily_ex_walking',
  };

  /// Public lookup: given an ExerciseInfo.id, returns the corresponding
  /// daily task id, or null if not in today's set.
  static String? exerciseIdToTaskId(String exerciseId) =>
      _exerciseIdToTaskId[exerciseId];

  /// Sync completion state from RoutineProvider's history entries for today.
  void _syncCompletionFromHistory() {
    final todayStart = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    for (final h in _routineProvider.history) {
      if (h.completedAt.isBefore(todayStart)) continue;

      // Check exercise history entries
      final mappedId = _exerciseIdToTaskId[h.routineId];
      if (mappedId != null) {
        final idx = _tasks.indexWhere((t) => t.id == mappedId);
        if (idx != -1 && !_tasks[idx].isCompleted) {
          _tasks[idx].isCompleted = true;
          _tasks[idx].completedAt = h.completedAt;
        }
      }

      // Check journal entries
      if (h.category == 'journal' || h.routineId == 'daily_journal') {
        final idx = _tasks.indexWhere((t) => t.id == 'daily_journal');
        if (idx != -1 && !_tasks[idx].isCompleted) {
          _tasks[idx].isCompleted = true;
          _tasks[idx].completedAt = h.completedAt;
        }
      }
    }
  }

  /// Generate exactly 5 tasks: 4 exercises + 1 journal.
  void _generateTodayRoutine() {
    final yesterdayIds = _loadYesterdayIds();
    final rng = Random();

    // Available exercise pool
    final allExercises = <_ExercisePoolEntry>[
      _ExercisePoolEntry(
        taskId: 'daily_ex_breathing',
        title: 'Box Breathing',
        subtitle: '4-4-4-4 calm breathing',
        info: boxBreathingExercise,
      ),
      _ExercisePoolEntry(
        taskId: 'daily_ex_grounding',
        title: 'Grounding 5-4-3-2-1',
        subtitle: 'Reconnect with your senses',
        info: groundingExercise,
      ),
      _ExercisePoolEntry(
        taskId: 'daily_ex_scan',
        title: 'Body Scan',
        subtitle: 'Release tension head to toe',
        info: bodyScanExercise,
      ),
      _ExercisePoolEntry(
        taskId: 'daily_ex_walking',
        title: 'Mindful Walking',
        subtitle: 'Walk with full awareness',
        info: mindWalkingExercise,
      ),
    ];

    // Shuffle for variety, then try to avoid yesterday's exact set
    allExercises.shuffle(rng);

    // Pick 4 exercises (currently all 4, but with larger pool
    // the shuffle + no-repeat would pick a different subset)
    final selected = allExercises.take(4).toList();

    // If today's selection matches yesterday exactly, rotate one out
    if (yesterdayIds.isNotEmpty) {
      final todayIds = selected.map((e) => e.taskId).toSet();
      if (_setsMatch(todayIds, yesterdayIds.where((id) => id.startsWith('daily_ex_')).toSet())) {
        // Rotate: move first to end
        final first = selected.removeAt(0);
        selected.add(first);
      }
    }

    _tasks = [
      ...selected.map((e) => DailyTask(
            id: e.taskId,
            title: e.title,
            subtitle: e.subtitle,
            category: 'exercise',
            exerciseInfo: e.info,
          )),
      DailyTask(
        id: 'daily_journal',
        title: 'Daily Journal',
        subtitle: 'Write one thing on your mind',
        category: 'journal',
      ),
    ];
  }

  bool _setsMatch(Set<String> a, Set<String> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  /// Reads yesterday's task IDs from SharedPreferences.
  Set<String> _loadYesterdayIds() {
    // We stored the current day's IDs; if date changed, those become "yesterday's"
    return _cachedIds;
  }

  Set<String> _cachedIds = {};

  Future<void> _loadCached() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateStr = prefs.getString(_lastGenDateKey) ?? '';
      final taskStr = prefs.getString(_prefsKey);

      if (dateStr.isNotEmpty && taskStr != null && taskStr.isNotEmpty) {
        final decoded = List<Map<String, dynamic>>.from(
          jsonDecode(taskStr) as List<dynamic>,
        );
        _tasks = decoded.map((e) => DailyTask.fromJson(e)).toList();
        _lastGenDate = dateStr;
        _cachedIds = _tasks.map((t) => t.id).toSet();
      }
    } catch (e) {
      debugPrint('DailyRoutineProvider load error: $e');
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedIds = _tasks.map((t) => t.id).toSet();
      await prefs.setString(_lastGenDateKey, _lastGenDate);
      await prefs.setString(
        _prefsKey,
        jsonEncode(_tasks.map((t) => t.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('DailyRoutineProvider persist error: $e');
    }
  }
}

class _ExercisePoolEntry {
  final String taskId;
  final String title;
  final String subtitle;
  final ExerciseInfo info;

  const _ExercisePoolEntry({
    required this.taskId,
    required this.title,
    required this.subtitle,
    required this.info,
  });
}
