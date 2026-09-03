// lib/services/firebase_chat_service.dart
import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service responsible for all Firebase Firestore operations related to chat.
class FirebaseChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🔥 TEMPORARY — Hardcoded user UID for testing.
  String? get currentUserId {
    return _auth.currentUser?.uid;
  }

  // ============================================================
  // PRIVATE HELPERS
  // ============================================================

  CollectionReference<Map<String, dynamic>> _getSessionCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('session');
  }

  CollectionReference<Map<String, dynamic>> _getMessagesCollection(
    String userId,
    String sessionId,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('session')
        .doc(sessionId)
        .collection('messages');
  }

  // ============================================================
  // SESSION METHODS
  // ============================================================

  Future<String> createSession({String channel = 'chat'}) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated.');
    dev.log('🟢 Creating session for user: $userId');

    final docRef = await _getSessionCollection(userId).add({
      'userId': userId,
      'channel': channel,
      'status': 'open',
      'createdAt': FieldValue.serverTimestamp(),
      'lastActivityAt': FieldValue.serverTimestamp(),
      'messageCount': 0,
    });
    dev.log('✅ Session created: ${docRef.id}');
    return docRef.id;
  }

  Future<void> closeSession(String sessionId) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated.');
    await _getSessionCollection(userId).doc(sessionId).update({
      'status': 'closed',
      'closedAt': FieldValue.serverTimestamp(),
    });
    dev.log('🔒 Session closed: $sessionId');
  }

  Future<List<Map<String, dynamic>>> getUserSessions({int limit = 20}) async {
    final userId = currentUserId;
    if (userId == null) return [];
    final snapshot = await _getSessionCollection(userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        ...?data,
        'createdAt': (data['createdAt'] as Timestamp?)?.toDate().toIso8601String(),
        'closedAt': (data['closedAt'] as Timestamp?)?.toDate().toIso8601String(),
      };
    }).toList();
  }

  // ============================================================
  // MESSAGE METHODS
  // ============================================================

  Future<void> saveMessage({
    required String sessionId,
    required String sender,
    required String text,
    String? language,
    double? distressLevel,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated.');

    await _getMessagesCollection(userId, sessionId).add({
      'sender': sender,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'language': language ?? 'en',
      'distressLevel': distressLevel,
    });

    await _getSessionCollection(userId).doc(sessionId).update({
      'messageCount': FieldValue.increment(1),
      'lastActivityAt': FieldValue.serverTimestamp(),
    });
    dev.log('💬 Message saved from $sender');
  }

  // ✅ KEEP THIS ONE — it takes a sessionId parameter
  Future<List<Map<String, dynamic>>> getSessionMessages(String sessionId) async {
    final userId = currentUserId;
    if (userId == null) return [];

    final snapshot = await _getMessagesCollection(userId, sessionId)
        .orderBy('timestamp', descending: false)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'sender': data['sender'] ?? '',
        'text': data['text'] ?? '',
        'timestamp': (data['timestamp'] as Timestamp?)?.toDate().toIso8601String(),
        'language': data['language'] ?? 'en',
        'distressLevel': data['distressLevel'],
      };
    }).toList();
  }

  // 🔥 REMOVED the duplicate method — only one getSessionMessages exists.

  Stream<List<Map<String, dynamic>>> listenToMessages(String sessionId) {
    final userId = currentUserId;
    if (userId == null) {
      dev.log('❌ No user, returning empty stream');
      return Stream.value([]);
    }
    return _getMessagesCollection(userId, sessionId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'sender': data['sender'] ?? '',
          'text': data['text'] ?? '',
          'timestamp': (data['timestamp'] as Timestamp?)?.toDate().toIso8601String(),
          'language': data['language'] ?? 'en',
          'distressLevel': data['distressLevel'],
        };
      }).toList();
    });
  }

  // ============================================================
  // SESSION SUMMARY
  // ============================================================

  Future<void> saveSessionSummary({
    required String sessionId,
    required String? personalityTag,
    required double averageDistress,
    required List<String> techniquesUsed,
    required List<String> topicsDiscussed,
    required String keyInsights,
    required String? pendingTask,
    required int durationMinutes,
    required int messageCount,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated.');
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('sessionSummary')
        .doc(sessionId)
        .set({
      'sessionId': sessionId,
      'userId': userId,
      'personalityTag': personalityTag,
      'averageDistress': averageDistress,
      'techniquesUsed': techniquesUsed,
      'topicsDiscussed': topicsDiscussed,
      'keyInsights': keyInsights,
      'pendingTask': pendingTask,
      'durationMinutes': durationMinutes,
      'messageCount': messageCount,
      'createdAt': FieldValue.serverTimestamp(),
      'endedAt': FieldValue.serverTimestamp(),
    });
    dev.log('📝 Session summary saved for $sessionId');
  }

  Future<Map<String, dynamic>?> getSessionSummary(String sessionId) async {
    final userId = currentUserId;
    if (userId == null) return null;
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('sessionSummary')
        .doc(sessionId)
        .get();
    if (!doc.exists) return null;
    final data = doc.data();
    return {
      ...?data,
      'createdAt': (data?['createdAt'] as Timestamp?)?.toDate().toIso8601String(),
      'endedAt': (data?['endedAt'] as Timestamp?)?.toDate().toIso8601String(),
    };
  }

  // ============================================================
  // OVERALL SUMMARY
  // ============================================================

  Future<void> saveOverallSummary({
    required String userId,
    required String personalityStability,
    required List<double> distressTrend,
    required List<String> mostUsedTechniques,
    required List<String> recurringTopics,
    required int sessionCount,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('overallSummary')
        .doc(userId)
        .set({
      'userId': userId,
      'personalityStability': personalityStability,
      'distressTrend': distressTrend,
      'mostUsedTechniques': mostUsedTechniques,
      'recurringTopics': recurringTopics,
      'sessionCount': sessionCount,
      'lastUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    dev.log('📊 Overall summary saved for $userId');
  }

  Future<Map<String, dynamic>?> getOverallSummary(String userId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('overallSummary')
        .doc(userId)
        .get();
    if (!doc.exists) return null;
    final data = doc.data();
    return {
      ...?data,
      'lastUpdatedAt': (data?['lastUpdatedAt'] as Timestamp?)?.toDate().toIso8601String(),
    };
  }
}