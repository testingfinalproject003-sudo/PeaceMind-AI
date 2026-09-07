// lib/utils/routine_cover_resolver.dart
import '../models/routine_model.dart';

/// Routine/task type ke hisaab se cover image auto-select karta hai.
/// Kisi bhi routine ke liye manual `coverImage` assignment zaroori nahi —
/// id/title/category se matching asset mil jata hai.
///
/// Priority: manual coverImage (URL) > auto asset match > null
/// (null = existing gradient fallback UI mein, koi break nahi hota).
class RoutineCoverResolver {
  RoutineCoverResolver._();

  /// Built-in exercise tasks (home screen `ex_*`) aur Daily-5 task ids →
  /// Exercise screen ke hi existing cover assets reuse hote hain.
  static const Map<String, String> _idCovers = {
    'ex_breathing': 'assets/images/box_breathing_cover.png',
    'ex_grounding': 'assets/images/grounding_cover.png',
    'ex_scan': 'assets/images/body_scan_cover.png',
    'ex_walking': 'assets/images/mindful_walking_cover.png',
    'daily_ex_breathing': 'assets/images/box_breathing_cover.png',
    'daily_ex_grounding': 'assets/images/grounding_cover.png',
    'daily_ex_scan': 'assets/images/body_scan_cover.png',
    'daily_ex_walking': 'assets/images/mindful_walking_cover.png',
    'daily_journal': 'assets/images/journal.jpg',
  };

  /// Matching asset path, ya null (safe fallback → gradient).
  static String? resolveAsset(Routine routine) {
    // Manual cover set hai → auto override nahi karna.
    if (routine.coverImage != null && routine.coverImage!.isNotEmpty) {
      return null;
    }

    final id = routine.id.toLowerCase();
    final idCover = _idCovers[id];
    if (idCover != null) return idCover;

    final title = routine.title.toLowerCase();

    // Journal → existing Journal image
    if (_hasAny(title, const ['journal', 'diary', 'gratitude', 'reflect']) ||
        id.contains('journal')) {
      return 'assets/images/journal.jpg';
    }

    // Exercise titles → Exercise screen covers
    if (title.contains('breathing')) {
      return 'assets/images/box_breathing_cover.png';
    }
    if (title.contains('grounding')) {
      return 'assets/images/grounding_cover.png';
    }
    if (title.contains('body scan')) {
      return 'assets/images/body_scan_cover.png';
    }
    if (_hasAny(title, const ['walking', 'walk'])) {
      return 'assets/images/mindful_walking_cover.png';
    }

    // New daily-life assets — keywords widen kiye taake common titles
    // ("Fajr", "Morning Walk", "Time with kids"...) bhi match hon.
    if (_hasAny(title, const [
      'pray', 'prayer', 'namaz', 'salah', 'dua', 'quran', 'fajr',
      'zohar', 'zuhr', 'asr', 'maghrib', 'isha', 'tasbih', 'tasbeeh',
      'dhikr', 'zikr',
    ])) {
      return 'assets/images/pray.jpg';
    }
    if (_hasAny(title, const [
      'family', 'kids', 'children', 'parents', 'mother', 'father',
      'brother', 'sister',
    ])) {
      return 'assets/images/family.png';
    }
    if (_hasAny(title, const ['morning', 'sunrise', 'wake up', 'early']) ||
        routine.category == 'morning') {
      return 'assets/images/morning.jpg';
    }

    return null;
  }

  static bool _hasAny(String text, List<String> keys) =>
      keys.any(text.contains);
}
