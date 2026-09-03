import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/journal_entry.dart';

/// Journal entries ko Firestore mein `users/{uid}/journal` collection
/// mein save karta hai aur wapas fetch karta hai. Offline fail hone par
/// silently chup rehta hai — local (SharedPreferences) data safe rehta hai.
class JournalService {
  JournalService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get _uid => _auth.currentUser?.uid ?? '';

  /// Ek journal entry cloud par save karo (best-effort).
  Future<void> saveEntry(JournalEntry entry) async {
    final uid = _uid;
    if (uid.isEmpty) return;
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('journal')
          .doc(entry.id)
          .set(<String, dynamic>{
        ...entry.toJson(),
        'createdAt': entry.createdAt.toIso8601String(),
        'savedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('JournalService saveEntry error: $e');
    }
  }

  /// Cloud se saari journal entries laao (newest first).
  Future<List<JournalEntry>> fetchEntries() async {
    final uid = _uid;
    if (uid.isEmpty) return [];
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('journal')
          .get();

      final entries = <JournalEntry>[];
      for (final doc in snapshot.docs) {
        final entry = JournalEntry.fromFirestore(doc.data());
        if (entry != null) entries.add(entry);
      }
      entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return entries;
    } catch (e) {
      debugPrint('JournalService fetchEntries error: $e');
      return [];
    }
  }
}
