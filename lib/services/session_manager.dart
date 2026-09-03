// lib/services/session_manager.dart
import 'dart:developer' as dev;

// import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_chat_service.dart';
import 'api_chat_service.dart';
import 'language_detection_service.dart';
import 'session_memory_service.dart';

/// Result returned after sending a message.
class SendMessageResult {
  final String reply;
  final double? distressLevel;
  final String? suggestedExercise;
  final bool speak; // [SPEAK:true] → Urdu reply, auto-trigger TTS

  SendMessageResult({
    required this.reply,
    this.distressLevel,
    this.suggestedExercise,
    this.speak = false,
  });
}

/// Manages the chat session lifecycle and orchestrates communication
/// between Firebase and the AI API.
class SessionManager {
  final FirebaseChatService _firebaseService = FirebaseChatService();
  final ApiChatService _apiService = ApiChatService();
  final SessionMemoryService _sessionMemory = SessionMemoryService();

  String? _currentSessionId;
  List<Map<String, String>> _conversationHistory = [];
  bool _isProcessing = false;

  // ============================================================
  // GETTERS
  // ============================================================

  String? get currentSessionId => _currentSessionId;
  List<Map<String, String>> get conversationHistory =>
      List.unmodifiable(_conversationHistory);
  bool get isProcessing => _isProcessing;

  // ============================================================
  // SESSION LIFECYCLE
  // ============================================================

  Future<String> startNewSession() async {
    if (_currentSessionId != null) {
      await closeSession();
    }
    _currentSessionId = await _firebaseService.createSession();
    _conversationHistory.clear();
    dev.log('🟢 Started new session: $_currentSessionId');
    return _currentSessionId!;
  }

  Future<void> loadSession(String sessionId) async {
    _currentSessionId = sessionId;
    final messages = await _firebaseService.getSessionMessages(sessionId);
    _conversationHistory = messages.map<Map<String, String>>((msg) {
      return {
        'sender': (msg['sender'] as String?) ?? 'nova',
        'text': (msg['text'] as String?) ?? '',
      };
    }).toList();
    dev.log(
      '🟢 Loaded session: $sessionId with ${_conversationHistory.length} messages',
    );
  }

  Future<void> closeSession() async {
    if (_currentSessionId == null) return;
    await _firebaseService.closeSession(_currentSessionId!);
    dev.log('🔒 Session closed: $_currentSessionId');
    _currentSessionId = null;
    _conversationHistory.clear();
  }

  // ============================================================
  // MESSAGE HANDLING
  // ============================================================

  Future<SendMessageResult> sendMessage({
    required String message,
    String? language,
    String? personalityTag,
    String? sessionSummary,
    String? userName,
  }) async {
    if (_isProcessing) {
      throw Exception('Already processing a message. Please wait.');
    }

    if (_currentSessionId == null) {
      await startNewSession();
    }

    _isProcessing = true;

    try {
      // 1. Save user message
      await _firebaseService.saveMessage(
        sessionId: _currentSessionId!,
        sender: 'user',
        text: message,
        language: language ?? 'en',
      );
      _conversationHistory.add({'sender': 'user', 'text': message});

      // 2. Get AI reply with distress and exercise
      dev.log('🤖 Calling API...');
      final aiResponse = await _apiService.sendMessage(
        userMessage: message,
        conversationHistory: _conversationHistory,
        personalityTag: personalityTag,
        sessionSummary: sessionSummary,
        userName: userName,
      );
      dev.log('✅ API reply received');
      dev.log('📊 Distress Level: ${aiResponse.distressLevel}');
      dev.log('🏋️ Suggested Exercise: ${aiResponse.suggestedExercise}');

      // 3. Save AI reply with distress level. Language is detected from the
      // reply text itself so the play button uses the right TTS locale.
      final replyLang = const LanguageDetectionService().detect(
        aiResponse.reply,
      );
      await _firebaseService.saveMessage(
        sessionId: _currentSessionId!,
        sender: 'nova',
        text: aiResponse.reply,
        language: LanguageDetectionService().ttsLocaleFor(replyLang),
        distressLevel: aiResponse.distressLevel,
      );
      _conversationHistory.add({'sender': 'nova', 'text': aiResponse.reply});

      // 4. Return full result
      return SendMessageResult(
        reply: aiResponse.reply,
        distressLevel: aiResponse.distressLevel,
        suggestedExercise: aiResponse.suggestedExercise,
        speak: aiResponse.speak,
      );
    } catch (e) {
      dev.log('❌ Error in sendMessage: $e');
      rethrow;
    } finally {
      _isProcessing = false;
    }
  }

  // ============================================================
  // REAL-TIME LISTENING
  // ============================================================

  Stream<List<Map<String, dynamic>>> listenToMessages() {
    if (_currentSessionId == null) {
      return Stream.value([]);
    }
    return _firebaseService.listenToMessages(_currentSessionId!);
  }

  // ============================================================
  // SESSION SUMMARY (AI-Powered)
  // ============================================================

  Future<void> generateSessionSummary({
    required int durationMinutes,
    required String? pendingTask,
  }) async {
    if (_currentSessionId == null) {
      throw Exception('No active session to summarize.');
    }

    dev.log('📝 Generating session summary...');

    try {
      final summaryData = await _apiService.generateSessionSummary(
        conversationHistory: _conversationHistory,
        personalityTag: null,
      );

      dev.log('✅ Summary generated: ${summaryData['keyInsights']}');

      // Calculate average distress from messages
      double averageDistress = 0.0;
      try {
        final messages = await _firebaseService.getSessionMessages(
          _currentSessionId!,
        );
        final distressValues = messages
            .map((m) => m['distressLevel'] as double?)
            .where((d) => d != null)
            .cast<double>()
            .toList();
        if (distressValues.isNotEmpty) {
          averageDistress =
              distressValues.reduce((a, b) => a + b) / distressValues.length;
        }
      } catch (e) {
        dev.log('⚠️ Could not calculate average distress: $e');
      }

      await _firebaseService.saveSessionSummary(
        sessionId: _currentSessionId!,
        personalityTag: summaryData['personalityTag'],
        averageDistress: averageDistress,
        techniquesUsed: summaryData['techniquesUsed'],
        topicsDiscussed: summaryData['topicsDiscussed'],
        keyInsights: summaryData['keyInsights'],
        pendingTask: pendingTask,
        durationMinutes: durationMinutes,
        messageCount: _conversationHistory.length,
        progress: summaryData['progress'],
        unresolvedConcerns: summaryData['unresolved'],
        whatHelped: summaryData['helped'],
      );
      dev.log('✅ Session summary saved');

      // ── Shared cross-mode memory ──
      // 'userFacts' is only present when the AI extraction succeeded, so
      // fallback summaries never pollute long-term memory.
      if (summaryData.containsKey('userFacts')) {
        final userFacts = List<String>.from(summaryData['userFacts'] ?? []);
        final corrections = List<String>.from(summaryData['corrections'] ?? []);
        if (userFacts.isNotEmpty || corrections.isNotEmpty) {
          await _sessionMemory.mergeUserFacts(
            userFacts,
            corrections: corrections,
          );
        }

        // Concise summary into the shared sessionSummaries store so the
        // next session (chat OR voice) continues from this one.
        final topics = List<String>.from(summaryData['topicsDiscussed'] ?? []);
        final unresolved = (summaryData['unresolved'] ?? '').toString();
        final helped = (summaryData['helped'] ?? '').toString();
        final sharedParts = <String>[
          if (topics.isNotEmpty) 'Topics discussed: ${topics.join(', ')}.',
          (summaryData['keyInsights'] ?? '').toString(),
          if (unresolved.isNotEmpty) 'Unresolved: $unresolved.',
          if (helped.isNotEmpty) 'What helped: $helped.',
        ].where((p) => p.trim().isNotEmpty).toList();

        if (sharedParts.isNotEmpty) {
          await _sessionMemory.saveSummary(
            sessionId: _currentSessionId!,
            summary: sharedParts.join(' '),
          );
        }
      }

      final userId = _firebaseService.currentUserId;
      if (userId != null) {
        await _updateOverallSummary(
          userId: userId,
          summaryData: summaryData,
          averageDistress: averageDistress,
        );
      }
    } catch (e) {
      dev.log('❌ Summary generation error: $e');
      await _saveFallbackSummary(durationMinutes, pendingTask);
    }
  }

  Future<void> _saveFallbackSummary(
    int durationMinutes,
    String? pendingTask,
  ) async {
    if (_currentSessionId == null) return;
    await _firebaseService.saveSessionSummary(
      sessionId: _currentSessionId!,
      personalityTag: null,
      averageDistress: 0.0,
      techniquesUsed: [],
      topicsDiscussed: ['General conversation'],
      keyInsights: 'The user engaged in a supportive conversation.',
      pendingTask: pendingTask,
      durationMinutes: durationMinutes,
      messageCount: _conversationHistory.length,
    );
    dev.log('📝 Fallback summary saved');
  }

  Future<void> _updateOverallSummary({
    required String userId,
    required Map<String, dynamic> summaryData,
    required double averageDistress,
  }) async {
    final overall = await _firebaseService.getOverallSummary(userId);

    // Recurring topics are only topics seen in 2+ sessions — merge
    // this session's topics into the existing counts instead of
    // overwriting them with only the latest session.
    final topicCounts = <String, int>{};
    for (final t in List<String>.from(overall?['recurringTopics'] ?? [])) {
      if (t.toString().trim().isNotEmpty) {
        topicCounts[t.toString()] = (topicCounts[t.toString()] ?? 0) + 1;
      }
    }
    for (final t in List<String>.from(summaryData['topicsDiscussed'] ?? [])) {
      if (t.toString().trim().isNotEmpty) {
        topicCounts[t.toString()] = (topicCounts[t.toString()] ?? 0) + 1;
      }
    }
    final recurringTopics = topicCounts.entries
        .where((e) => e.value >= 2)
        .map((e) => e.key)
        .toList();

    // Same accumulate-then-keep-frequent rule for techniques.
    final techniqueCounts = <String, int>{};
    for (final t in List<String>.from(overall?['mostUsedTechniques'] ?? [])) {
      if (t.toString().trim().isNotEmpty) {
        techniqueCounts[t.toString()] =
            (techniqueCounts[t.toString()] ?? 0) + 1;
      }
    }
    for (final t in List<String>.from(summaryData['techniquesUsed'] ?? [])) {
      if (t.toString().trim().isNotEmpty) {
        techniqueCounts[t.toString()] =
            (techniqueCounts[t.toString()] ?? 0) + 1;
      }
    }
    final mostUsedTechniques = techniqueCounts.entries
        .where((e) => e.value >= 2)
        .map((e) => e.key)
        .toList();

    if (overall != null) {
      await _firebaseService.saveOverallSummary(
        userId: userId,
        personalityStability:
            overall['personalityStability'] ??
            summaryData['personalityTag'] ??
            'General',
        distressTrend: [
          ...List<double>.from(overall['distressTrend'] ?? []),
          averageDistress,
        ],
        mostUsedTechniques: mostUsedTechniques,
        recurringTopics: recurringTopics,
        sessionCount: (overall['sessionCount'] ?? 0) + 1,
      );
    } else {
      await _firebaseService.saveOverallSummary(
        userId: userId,
        personalityStability: summaryData['personalityTag'] ?? 'General',
        distressTrend: [averageDistress],
        mostUsedTechniques: mostUsedTechniques,
        recurringTopics: recurringTopics,
        sessionCount: 1,
      );
    }
    dev.log('📊 Overall summary updated for user: $userId');
  }

  // ============================================================
  // MESSAGE FETCHING
  // ============================================================

  Future<List<Map<String, dynamic>>> fetchMessages() async {
    if (_currentSessionId == null) {
      return [];
    }
    return await _firebaseService.getSessionMessages(_currentSessionId!);
  }

  Future<Map<String, dynamic>?> getSessionSummary() async {
    if (_currentSessionId == null) return null;
    return await _firebaseService.getSessionSummary(_currentSessionId!);
  }

  // ============================================================
  // USER CONTEXT
  // ============================================================

  Future<Map<String, dynamic>?> fetchOverallSummary() async {
    final userId = _firebaseService.currentUserId;
    if (userId == null) {
      dev.log('⚠️ No user ID to fetch overall summary');
      return null;
    }
    return await _firebaseService.getOverallSummary(userId);
  }

  // ============================================================
  // UTILITY
  // ============================================================

  void reset() {
    _currentSessionId = null;
    _conversationHistory.clear();
    _isProcessing = false;
  }
}
