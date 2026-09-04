import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Garden data ko Firestore mein `users/{uid}/garden` document
/// mein save karta hai aur wapas fetch karta hai.
/// Offline fail hone par silently chup rehta hai — local data safe rehta hai.
class GardenService {
  GardenService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get _uid => _auth.currentUser?.uid ?? '';

  /// Cloud se garden data fetch karo. Returns null on failure.
  Future<Map<String, int>?> fetchGardenData() async {
    final uid = _uid;
    if (uid.isEmpty) return null;
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('garden')
          .doc('state')
          .get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          return {
            'treeCount': (data['treeCount'] ?? 0) as int,
            'streak': (data['streak'] ?? 0) as int,
            'totalTrees': (data['totalTrees'] ?? 0) as int,
          };
        }
      }
    } catch (e) {
      debugPrint('GardenService fetchGardenData error: $e');
    }
    return null;
  }

  /// Garden data cloud par save karo (best-effort).
  Future<void> saveGardenData({
    required int treeCount,
    required int streak,
    required int totalTrees,
  }) async {
    final uid = _uid;
    if (uid.isEmpty) return;
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('garden')
          .doc('state')
          .set({
        'treeCount': treeCount,
        'streak': streak,
        'totalTrees': totalTrees,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('GardenService saveGardenData error: $e');
    }
  }
}
