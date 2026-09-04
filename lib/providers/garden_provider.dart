import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/garden_service.dart';

/// Cross-screen garden state manager.
///
/// Both the HomeScreen garden widget and the ExercisePlayerScreen
/// read/write through this single provider so tree growth is
/// consistent regardless of where an exercise or task completes.
///
/// Persists to SharedPreferences (offline) AND Firestore (cloud sync).
class GardenProvider extends ChangeNotifier {
  GardenProvider({GardenService? service})
      : _service = service ?? GardenService();

  final GardenService _service;

  static const int totalSlots = 12;
  static const String _treeCountKey = 'garden_tree_count';
  static const String _gardenStreakKey = 'garden_streak';
  static const String _totalTreesKey = 'garden_total_trees';

  int _treeCount = 0;
  int _gardenStreak = 0;
  int _totalTrees = 0;
  bool _isLoading = false;

  /// True while a grow animation is in progress (prevents double-taps).
  bool _isGrowing = false;

  /// Index of the most recently grown tree slot (0-based).
  /// -1 when no tree has been grown yet this session.
  int _lastGrownIndex = -1;

  int get treeCount => _treeCount;
  int get gardenStreak => _gardenStreak;
  int get totalTrees => _totalTrees;
  int get remainingSlots => totalSlots - _treeCount;
  int get lastGrownIndex => _lastGrownIndex;
  bool get isLoading => _isLoading;
  bool get isGrowing => _isGrowing;

  // =========================================================================
  // LOAD
  // =========================================================================

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    // 1. Read local first (fast) — UI turant render hota hai,
    //    skeleton/spinner ka wait sirf is fast read tak limited hai.
    try {
      final prefs = await SharedPreferences.getInstance();
      _treeCount = (prefs.getInt(_treeCountKey) ?? 0).clamp(0, totalSlots);
      _gardenStreak = prefs.getInt(_gardenStreakKey) ?? 0;
      _totalTrees = prefs.getInt(_totalTreesKey) ?? 0;
    } catch (_) {}

    _isLoading = false;
    notifyListeners();

    // 2. Cloud merge background mein chalta hai — offline/timeout par
    //    5s tak spinner dikhana zaroori nahi tha.
    //    Timeout: offline par Firestore hang ho sakta hai.
    final cloud = await _service.fetchGardenData().timeout(
      const Duration(seconds: 5),
      onTimeout: () => null,
    );
    if (cloud != null) {
      final cTree = (cloud['treeCount'] ?? 0).clamp(0, totalSlots);
      final cStreak = cloud['streak'] ?? 0;
      final cTotal = cloud['totalTrees'] ?? 0;
      var changed = false;
      if (cTree > _treeCount) {
        _treeCount = cTree;
        changed = true;
      }
      if (cStreak > _gardenStreak) {
        _gardenStreak = cStreak;
        changed = true;
      }
      if (cTotal > _totalTrees) {
        _totalTrees = cTotal;
        changed = true;
      }
      if (changed) {
        // Cloud values badi hon to local overwrite karo (persist bhi).
        await _save();
        notifyListeners();
      }
    }
  }

  // =========================================================================
  // GROW TREE — call from any screen after exercise / task completion
  // =========================================================================

  Future<void> growTree() async {
    // NOTE: _isLoading check hata diya — agar cloud load abhi chal raha
    // ho to bhi tree grow hona chahiye (save baad mein ho jata hai).
    if (_isGrowing) return;
    _isGrowing = true;

    _treeCount++;
    _totalTrees++;
    _lastGrownIndex = _treeCount - 1;
    notifyListeners();
    await _save();

    // Full garden → streak++ and reset slots
    if (_treeCount >= totalSlots) {
      await Future.delayed(const Duration(milliseconds: 1200));
      _gardenStreak++;
      _treeCount = 0;
      notifyListeners();
      await _save();
    }

    _isGrowing = false;
  }

  // =========================================================================
  // SAVE
  // =========================================================================

  Future<void> _save() async {
    // Local
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_treeCountKey, _treeCount);
      await prefs.setInt(_gardenStreakKey, _gardenStreak);
      await prefs.setInt(_totalTreesKey, _totalTrees);
    } catch (_) {}

    // Cloud
    await _service.saveGardenData(
      treeCount: _treeCount,
      streak: _gardenStreak,
      totalTrees: _totalTrees,
    );
  }

  // =========================================================================
  // RESET
  // =========================================================================

  Future<void> resetGarden() async {
    _treeCount = 0;
    _gardenStreak = 0;
    _totalTrees = 0;
    notifyListeners();
    await _save();
  }
}
