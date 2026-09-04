import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/journal_entry.dart';
import '../services/journal_service.dart';

/// Journal state manager — entries SharedPreferences (offline) aur
/// Firestore (cloud) dono mein save hote hain. User login/logout par
/// data automatically uske account ke hisaab se reload hota hai.
class JournalProvider extends ChangeNotifier {
  JournalProvider({JournalService? service})
      : _service = service ?? JournalService();

  final JournalService _service;

  static const _prefsKey = 'peacemind_journal';

  List<JournalEntry> _entries = [];
  String? _loadedUid;
  bool _isLoading = false;

  List<JournalEntry> get entries => List.unmodifiable(_entries);
  bool get isLoading => _isLoading;

  /// Journal screen khulte waqt call hota hai. Ek hi user ke liye
  /// sirf pehli dafa load hota hai.
  Future<void> ensureLoaded() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (_loadedUid == uid) return;
    _loadedUid = uid;
    _isLoading = true;
    notifyListeners();

    // 1. Local first (fast)
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_prefsKey);
      if (str != null && str.isNotEmpty) {
        final decoded =
            List<Map<String, dynamic>>.from(jsonDecode(str) as List<dynamic>);
        _entries = decoded.map((e) => JournalEntry.fromJson(e)).toList();
      } else {
        _entries = [];
      }
    } catch (e) {
      debugPrint('JournalProvider load error: $e');
    }

    // 2. Cloud merge (union by id — koi duplicate nahi)
    final cloud = await _service.fetchEntries();
    if (cloud.isNotEmpty) {
      final byId = <String, JournalEntry>{
        for (final e in _entries) e.id: e,
      };
      var changed = false;
      for (final e in cloud) {
        if (!byId.containsKey(e.id)) {
          byId[e.id] = e;
          changed = true;
        }
      }
      _entries = byId.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Local-only entries cloud par push karo
      final cloudIds = cloud.map((e) => e.id).toSet();
      for (final e in _entries) {
        if (!cloudIds.contains(e.id)) _service.saveEntry(e);
      }
      if (changed) await _saveLocal();
    }

    _entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _isLoading = false;
    notifyListeners();
  }

  /// Nayi entry save karo — local + Firestore dono mein.
  Future<JournalEntry> addEntry({
    required String positive,
    required String negative,
    required String letGo,
    required String mood,
  }) async {
    final entry = JournalEntry(
      id: const Uuid().v4(),
      createdAt: DateTime.now(),
      positive: positive,
      negative: negative,
      letGo: letGo,
      mood: mood,
    );

    _entries.insert(0, entry);
    notifyListeners();
    await _saveLocal();
    _service.saveEntry(entry); // Firebase backup
    return entry;
  }

  Future<void> _saveLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefsKey,
        jsonEncode(_entries.map((e) => e.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('JournalProvider persist error: $e');
    }
  }
}
