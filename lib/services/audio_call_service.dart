import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/audio_call_session_model.dart';

class AudioCallService {
  AudioCallService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get _uid => _auth.currentUser?.uid ?? '';

  Future<String> fetchSessionSummary() async {
    final uid = _uid;
    if (uid.isEmpty) {
      return 'This is a calm voice support conversation. Keep the focus on what feels most manageable right now.';
    }

    try {
      final summaryDoc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('sessionSummaries')
          .orderBy('updatedAt', descending: true)
          .limit(1)
          .get();

      if (summaryDoc.docs.isNotEmpty) {
        final data = summaryDoc.docs.first.data();
        final summary = (data['summary'] ?? '').toString();
        if (summary.trim().isNotEmpty) {
          return summary;
        }
      }
    } catch (_) {
      // Fallback to a safe default summary when Firestore is unavailable.
    }

    return 'This is a calm voice support conversation. Keep the focus on what feels most manageable right now.';
  }

  Future<void> saveSession(AudioCallSessionModel session) async {
    final uid = _uid;
    if (uid.isEmpty) {
      return;
    }

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('audioCallSessions')
        .doc(session.id)
        .set(session.toJson(), SetOptions(merge: true));
  }

  Future<void> saveMessage({
    required String sessionId,
    required String text,
    required String role,
    required String source,
  }) async {
    final uid = _uid;
    final cleanText = text.trim();
    if (uid.isEmpty || cleanText.isEmpty) {
      return;
    }

    await _firestore.collection('users').doc(uid).collection('chatMessages').add({
      'sessionId': sessionId,
      'text': cleanText,
      'role': role,
      'source': source,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> saveSessionSummary({
    required String sessionId,
    required String summary,
  }) async {
    final uid = _uid;
    if (uid.isEmpty || summary.trim().isEmpty) {
      return;
    }

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

  Future<void> saveCrisisMessage({
    required String sessionId,
    required String transcript,
  }) async {
    final uid = _uid;
    if (uid.isEmpty || transcript.trim().isEmpty) {
      return;
    }

    await _firestore.collection('users').doc(uid).collection('chatMessages').add({
      'sessionId': sessionId,
      'text': transcript,
      'role': 'user',
      'source': 'audio_call',
      'safetyFlag': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Saves the full transcript log for a session so it can be replayed
  /// from the History / Report screen.
  Future<void> saveSessionTranscript({
    required String sessionId,
    required List<Map<String, dynamic>> transcript,
  }) async {
    final uid = _uid;
    if (uid.isEmpty || transcript.isEmpty) return;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('audioCallSessions')
        .doc(sessionId)
        .set({
          'transcript': transcript,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  /// Builds the NOVA system prompt with language-aware instructions.
  ///
  /// [detectedLang] is the human-readable language name
  /// ('Urdu', 'Punjabi', 'English') from LanguageDetectionService.
  String buildNovaPrompt(String sessionSummary, {String detectedLang = 'English'}) {
    return 'You are NOVA, a calm and supportive audio companion. '
        'You MUST reply only in $detectedLang. '
        'Never use Hindi in any form. '
        'Keep each reply short (2-4 sentences max), warm, and natural. '
        'No filler phrases, no long explanations, no markdown, no headers, no bullet points. '
        'Use at most one CBT technique in a single reply. '
        'Never say "What\'s wrong?". '
        'Never reveal a distress score. '
        'Stay non-clinical and encouraging. '
        'Context summary: $sessionSummary';
  }

  Future<String?> callNova(String userText, String sessionSummary, {String detectedLang = 'English'}) async {
    final apiKey = dotenv.env['OPENROUTER_API_KEY'] ?? '';
    final baseUrl = dotenv.env['OPENROUTER_BASE_URL'] ?? 'https://openrouter.ai/api/v1';
    final model = dotenv.env['OPENROUTER_MODEL'] ?? 'qwen/qwen-plus';

    if (apiKey.isEmpty || model.isEmpty) {
      return null;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': model,
        'messages': [
          {'role': 'system', 'content': buildNovaPrompt(sessionSummary, detectedLang: detectedLang)},
          {'role': 'user', 'content': userText},
        ],
      }),
    );

    if (response.statusCode != 200) {
      return null;
    }

    try {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      if (content is String && content.trim().isNotEmpty) {
        return content.trim();
      }
    } catch (_) {
      return null;
    }

    return null;
  }
}
