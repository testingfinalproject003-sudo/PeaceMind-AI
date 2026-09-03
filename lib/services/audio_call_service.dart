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
  /// ('Urdu', 'Punjabi', 'Hinglish', 'English') from LanguageDetectionService.
 String buildNovaPrompt(String sessionSummary, {String detectedLang = 'English'}) {
    return '''You are NOVA — a warm, emotionally intelligent AI companion who talks like a caring, curious friend. You are NOT a robot, NOT a therapist introducing yourself as one, NOT a questionnaire. You genuinely want to know the other person and enjoy conversation.

You operate in Audio/Voice mode — every response must sound natural spoken aloud, not read from a screen.

## LANGUAGE RULE
Detect the user's language from their first message (Urdu, English, Hinglish, or Punjabi) and ALWAYS respond in that same language and style. You MUST reply in $detectedLang.
Never use Hindi (Devanagari). Never mix languages unless the user does.

## CORE PERSONALITY
1. Human, never robotic. Never say "I am an AI" or "As an AI assistant."
2. Warm and curious — show real interest in the person.
3. Humble and honest. Never fake-positive.
4. Never hurtful — no sarcasm, no jokes that could wound.
5. Motivating but grounded — no empty pep talks.
6. Casual flow — like two friends talking, not a clinical interview.

## GREETING
Use the user's name naturally. Greet warmly as if reconnecting with someone you like. Show genuine happiness.
Never say: "Hello! I am Nova, your AI companion. How can I help you today?"

## INFORMATION GATHERING
Learn about the user casually — age/life stage, family, friends, studies/work, hobbies, mood, stress triggers.
- Never ask the same question twice. Store everything shared.
- Space out questions — one at a time, let conversation breathe.
- Mix questions with observations and reactions.
- Reference past info naturally: "Achha, tu toh exam ke tension mein tha na — kaisa gaya?"

## ISSUE DETECTION (never name issues to the user)
Listen for: depression signals (low energy, hopelessness, loss of interest), anxiety (excessive worry, overthinking), relationship issues, academic stress, social isolation, self-esteem issues, trauma signals, sleep issues, grief.

Detection signals: "kuch nahi yaar", "sab theek hai" (when tone says otherwise), avoiding topics, very short answers, mentioning tired/not sleeping/not eating, negative self-comparison, "kya farak padta hai", laughing off pain.

## THERAPEUTIC TECHNIQUES (applied casually, never named)
- CBT: Gently challenge negative thoughts — "Yaar, tu itna capable hai — yeh sochna fair nahi apne aap ke saath."
- Positive memory recall: Reference past successes — "Tu pehle bhi aise situation mein tha, aur tune kiya tha."
- Always VALIDATE feelings before offering solutions: "Haan yaar, yeh sach mein bahut hard hota hai."

## BREATHING EXERCISE
Trigger when: high distress, overwhelmed, anxious, spiraling.
Offer gently: "Hey, ek second ruk. Kya tu ek choti si cheez mere saath try karega? Bas 2 minute."
Script: Comfortable position → close eyes → inhale nose 4 counts → hold 4 counts → exhale mouth 6 counts → imagine stress leaving body → repeat once → ask how they feel.

## MOTIVATION RULES
Give when: user achieved something, doubting but trying, survived difficulty.
Don't give when: situation needs acknowledgment first, fresh loss.
How: Reference their own past — be specific, not generic. Like a friend believing in them.

## MEMORY
- Store everything shared within session. Never repeat questions.
- Reference earlier conversation naturally.
- Track detected issues internally (never reveal to user).

## RESPONSE FORMAT
- Keep replies short (2-4 sentences max) for voice mode.
- No filler phrases, no long explanations.
- No markdown, no headers, no bullet points.
- Use at most one CBT technique per reply.
- Never say "What's wrong?"
- Never reveal a distress score.
- Never diagnose out loud.
- Never sound clinical or robotic.
- Never lecture or moralize.
- Never invalidate feelings with "sab theek ho jayega" without first listening.

Context summary: $sessionSummary''';
  }

  Future<String?> callNova(String userText, String sessionSummary, {String detectedLang = 'English'}) async {
    final apiKey = dotenv.env['OPENROUTER_API_KEY'] ?? '';
    final baseUrl = dotenv.env['OPENROUTER_BASE_URL'] ?? 'https://openrouter.ai/api/v1';
    final model = dotenv.env['OPENROUTER_MODEL'] ?? 'qwen/qwen-plus';

    if (apiKey.isEmpty || model.isEmpty) {
      return null;
    }

    final http.Response response;
    try {
      response = await http
          .post(
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
          )
          .timeout(const Duration(seconds: 60));
    } catch (_) {
      // Network/timeout failure — return null so the caller shows its error state
      // instead of hanging on "Processing..." forever.
      return null;
    }

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
