import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Shared cross-session memory store used by both Chat and Audio Call modes.
///
/// Both modes read from the same `sessionSummaries` collection before every
/// AI call and write back an updated summary at session end.
///
/// This ensures:
///   • No-Repeat: NOVA never re-asks about something already discussed.
///   • Technique continuity: pending CBT tasks carry across modes.
///   • Personality Profile: same user context regardless of chat vs voice.
class SessionMemoryService {
  SessionMemoryService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get _uid => _auth.currentUser?.uid ?? '';

  static const _defaultSummary =
      'This is a calm support conversation. Keep the focus on what feels most manageable right now.';

  /// Fetches the latest session summary from Firestore.
  /// Shared by chat and audio — same collection, same doc.
  Future<String> fetchLatestSummary() async {
    final uid = _uid;
    if (uid.isEmpty) return _defaultSummary;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('sessionSummaries')
          .orderBy('updatedAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        final summary = (data['summary'] ?? '').toString();
        if (summary.trim().isNotEmpty) return summary;
      }
    } catch (_) {
      // Fallback to default when Firestore is unreachable
    }

    return _defaultSummary;
  }

  /// Saves / updates the session summary.
  /// [sessionId] can be a chat session id or audio call session id —
  /// both write to the same collection so the next session (any mode)
  /// picks up the latest context.
  Future<void> saveSummary({
    required String sessionId,
    required String summary,
  }) async {
    final uid = _uid;
    if (uid.isEmpty || summary.trim().isEmpty) return;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('sessionSummaries')
        .doc(sessionId)
        .set({
          'summary': summary,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }
}
