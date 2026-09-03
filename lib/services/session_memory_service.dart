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

  static const defaultSummary =
      'This is a calm support conversation. Keep the focus on what feels most manageable right now.';

  /// Max number of durable user facts kept in memory (keeps prompts small).
  static const int _maxUserFacts = 30;

  /// Fetches the latest session summary from Firestore.
  /// Shared by chat and audio — same collection, same doc.
  Future<String> fetchLatestSummary() async {
    final uid = _uid;
    if (uid.isEmpty) return defaultSummary;

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

    return defaultSummary;
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

  // ============================================================
  // STRUCTURED USER FACTS (shared long-term memory)
  // ============================================================

  /// Fetches durable facts about the user (name, age/life stage, studies,
  /// interests, relationships, recurring concerns, goals, what helped...).
  /// Returns an empty list when nothing has been stored yet.
  Future<List<String>> fetchUserFacts() async {
    final uid = _uid;
    if (uid.isEmpty) return const [];

    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('memory')
          .doc('userFacts')
          .get();

      if (doc.exists && doc.data() != null) {
        final facts = List.from(doc.data()!['facts'] ?? const []);
        return facts
            .map((f) => f.toString().trim())
            .where((f) => f.isNotEmpty)
            .toList();
      }
    } catch (_) {
      // Offline / permission issues — return empty rather than failing.
    }

    return const [];
  }

  /// Merges newly extracted facts into the stored list.
  /// [corrections] holds previously stored facts that the user has now
  /// changed or corrected — they are removed before merging so memory
  /// stays accurate instead of accumulating contradictions.
  /// Duplicates (case-insensitive) are skipped and the list is capped so
  /// prompts stay concise.
  Future<void> mergeUserFacts(
    List<String> newFacts, {
    List<String> corrections = const [],
  }) async {
    final uid = _uid;
    final cleaned = newFacts
        .map((f) => f.trim())
        .where((f) => f.isNotEmpty)
        .toList();
    if (uid.isEmpty || (cleaned.isEmpty && corrections.isEmpty)) return;

    final existing = await fetchUserFacts();

    // Drop outdated facts: match by shared keywords so a differently
    // worded restatement of the old fact still replaces it.
    var merged = existing;
    if (corrections.isNotEmpty) {
      final correctionWords = <String>{};
      for (final c in corrections) {
        correctionWords.addAll(_significantWords(c));
      }
      merged = existing.where((fact) {
        final factWords = _significantWords(fact);
        if (factWords.isEmpty) return true;
        final overlap = factWords.where(correctionWords.contains).length;
        // A stored fact is outdated only if it clearly describes the
        // same subject the user corrected (2+ shared keywords, or an
        // exact/substring match).
        final lower = fact.toLowerCase();
        final direct = corrections.any(
            (c) => lower.contains(c.toLowerCase()) || c.toLowerCase().contains(lower));
        return !direct && overlap < 2;
      }).toList();
    }

    final mergedLower = merged.map((f) => f.toLowerCase()).toSet();
    for (final fact in cleaned) {
      if (merged.length >= _maxUserFacts) break;
      if (mergedLower.contains(fact.toLowerCase())) continue;
      mergedLower.add(fact.toLowerCase());
      merged.add(fact);
    }

    if (merged.isEmpty) return;

    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('memory')
          .doc('userFacts')
          .set({
            'facts': merged,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    } catch (_) {
      // Non-fatal: memory merge failure must not break session end.
    }
  }

  /// Lowercased keywords of length > 2 for fact-matching (stop words ignored).
  static Set<String> _significantWords(String text) {
    const stopWords = {'the', 'and', 'for', 'with', 'was', 'has', 'had',
        'her', 'his', 'she', 'him', 'who', 'that', 'this', 'not', 'are'};
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 2 && !stopWords.contains(w))
        .toSet();
  }

  /// Fetches the user's profile name, preferring the Firestore `users` doc
  /// (same priority as AuthProvider) and falling back to the Firebase Auth
  /// display name. Returns null when no name is available.
  Future<String?> fetchUserName() async {
    final fbName = _auth.currentUser?.displayName?.trim() ?? '';

    final uid = _uid;
    if (uid.isNotEmpty) {
      try {
        final doc = await _firestore.collection('users').doc(uid).get();
        final fsName = (doc.data()?['name'] ?? '').toString().trim();
        if (fsName.isNotEmpty) return fsName;
      } catch (_) {
        // Fall through to the Firebase Auth name.
      }
    }

    return fbName.isNotEmpty ? fbName : null;
  }

  /// Builds the memory context string given to NOVA: latest session summary
  /// plus known user facts. Used by both chat and audio call modes so they
  /// share the same long-term memory.
  Future<String> buildMemoryContext() async {
    final summary = await fetchLatestSummary();
    final facts = await fetchUserFacts();
    if (facts.isEmpty) return summary;

    return '$summary\n\nKnown facts about the user (use naturally, never re-ask):\n- ${facts.join('\n- ')}';
  }
}