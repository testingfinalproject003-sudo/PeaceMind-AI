import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/history_model.dart';

/// Har completed activity (routine, exercise, NOVA voice call) ko
/// Firestore mein `users/{uid}/history` collection mein save karta hai
/// aur wapas fetch karta hai. Offline fail hone par silently chup rehta
/// hai — local (SharedPreferences) data hamesha safe rehta hai.
class HistoryService {
  HistoryService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get _uid => _auth.currentUser?.uid ?? '';

  /// Ek history entry cloud par save karo (best-effort).
  Future<void> saveEntry(HistoryEntry entry) async {
    final uid = _uid;
    if (uid.isEmpty) return;
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('history')
          .doc(entry.id)
          .set(<String, dynamic>{
        ...entry.toJson(),
        'completedAt': entry.completedAt.toIso8601String(),
        'savedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('HistoryService saveEntry error: $e');
    }
  }

  /// Cloud se saari history entries laao (newest first).
  Future<List<HistoryEntry>> fetchEntries() async {
    final uid = _uid;
    if (uid.isEmpty) return [];
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('history')
          .get();

      final entries = <HistoryEntry>[];
      for (final doc in snapshot.docs) {
        final entry = _entryFromDoc(doc.data());
        if (entry != null) entries.add(entry);
      }
      entries.sort((a, b) => b.completedAt.compareTo(a.completedAt));
      return entries;
    } catch (e) {
      debugPrint('HistoryService fetchEntries error: $e');
      return [];
    }
  }

  HistoryEntry? _entryFromDoc(Map<String, dynamic> data) {
    try {
      return HistoryEntry.fromJson(<String, dynamic>{
        'id': data['id'],
        'routineId': data['routineId'],
        'routineTitle': data['routineTitle'],
        'category': data['category'],
        'completedAt': data['completedAt'],
        'moodScore': data['moodScore'],
        'notes': data['notes'],
      });
    } catch (e) {
      debugPrint('HistoryService parse error: $e');
      return null;
    }
  }
}
