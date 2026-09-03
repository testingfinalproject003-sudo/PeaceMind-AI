// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // Create a new session
  Future<String> createSession() async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    final docRef = await _firestore.collection('sessions').add({
      'userId': userId,
      'channel': 'chat',
      'status': 'open',
      'createdAt': FieldValue.serverTimestamp(),
      'lastActivityAt': FieldValue.serverTimestamp(),
      'messageCount': 0,
    });

    return docRef.id;
  }

  // Save a message
  Future<void> saveMessage({
    required String sessionId,
    required String sender, // 'user' or 'nova'
    required String text,
    String? language,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    await _firestore
        .collection('sessions')
        .doc(sessionId)
        .collection('messages')
        .add({
      'sender': sender,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'language': language ?? 'en',
    });

    // Update message count
    await _firestore.collection('sessions').doc(sessionId).update({
      'messageCount': FieldValue.increment(1),
      'lastActivityAt': FieldValue.serverTimestamp(),
    });
  }

  // Listen to messages in real-time
  Stream<List<Map<String, dynamic>>> listenToMessages(String sessionId) {
    return _firestore
        .collection('sessions')
        .doc(sessionId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'sender': data['sender'] ?? '',
          'text': data['text'] ?? '',
          'timestamp': data['timestamp'],
          'language': data['language'] ?? 'en',
        };
      }).toList();
    });
  }

  // Get session history
  Future<List<Map<String, dynamic>>> getSessionHistory(String sessionId) async {
    final snapshot = await _firestore
        .collection('sessions')
        .doc(sessionId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'sender': data['sender'] ?? '',
        'text': data['text'] ?? '',
        'timestamp': data['timestamp'],
        'language': data['language'] ?? 'en',
      };
    }).toList();
  }

  // Close session
  Future<void> closeSession(String sessionId) async {
    await _firestore.collection('sessions').doc(sessionId).update({
      'status': 'closed',
      'closedAt': FieldValue.serverTimestamp(),
    });
  }
}