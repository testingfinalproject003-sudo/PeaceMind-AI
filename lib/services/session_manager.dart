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

  /// Daily resume: aaj ka open chat session (new session na bana kar
  /// same session continue karne ke liye).
  Future<String?> findTodayOpenChatSession() =>
      _firebaseService.getTodayOpenChatSession();

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

  Stream<List<Map<String, dynamic>>> listenToMessages({int limit = 50}) {
    if (_currentSessionId == null) {
      return Stream.value([]);
    }
    return _firebaseService.listenToMessages(_currentSessionId!, limit: limit);
  }

  // ============================================================
  // SESSION SUMMARY (AI-Powered)
  // ============================================================

  /// Generates the AI summary for a session, saves it to Firestore,
  /// merges userFacts into the shared memory and updates the overall
  /// summary.
  ///
  /// Returns the shared summary text (topics + insights) so callers can
  /// store it in the Report/History entry — or null when only a fallback
  /// summary could be saved.
  ///
  /// Duplicate guard: if this session was already summarized (e.g. End
  /// Session pressed again after a partial failure, or the stale sweep
  /// re-visiting a closed session), the AI call is skipped entirely so
  /// overall session counts / memory are never double-written.
  Future<String?> generateSessionSummary({
    required int durationMinutes,
    required String? pendingTask,
    // Sweep ke liye explicit session/history — instance state untouched.
    String? sessionId,
    List<Map<String, String>>? history,
  }) async {
    final sid = sessionId ?? _currentSessionId;
    if (sid == null) {
      throw Exception('No active session to summarize.');
    }
    final conversation = history ?? _conversationHistory;

    // Already summarized once — never double-count a session.
    try {
      final existing = await _firebaseService.getSessionSummary(sid);
      if (existing != null) {
        dev.log('ℹ️ Summary already exists for $sid — skipping regeneration');
        final insights = (existing['keyInsights'] ?? '').toString().trim();
        return insights.isEmpty ? null : insights;
      }
    } catch (_) {
      // Read failure — continue and let the save below be idempotent.
    }

    dev.log('📝 Generating session summary...');

    try {
      final summaryData = await _apiService.generateSessionSummary(
        conversationHistory: conversation,
        personalityTag: null,
      );

      dev.log('✅ Summary generated: ${summaryData['keyInsights']}');

      // Calculate average distress from messages
      double averageDistress = 0.0;
      try {
        final messages = await _firebaseService.getSessionMessages(
          sid,
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
        sessionId: sid,
        personalityTag: summaryData['personalityTag'],
        averageDistress: averageDistress,
        techniquesUsed: summaryData['techniquesUsed'],
        topicsDiscussed: summaryData['topicsDiscussed'],
        keyInsights: summaryData['keyInsights'],
        pendingTask: pendingTask,
        durationMinutes: durationMinutes,
        messageCount: conversation.length,
        progress: summaryData['progress'],
        unresolvedConcerns: summaryData['unresolved'],
        whatHelped: summaryData['helped'],
      );
      dev.log('✅ Session summary saved');

      // ── Shared cross-mode memory ──
      // 'userFacts' is only present when the AI extraction succeeded, so
      // fallback summaries never pollute long-term memory.
      String? sharedSummary;
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
          sharedSummary = sharedParts.join(' ');
          await _sessionMemory.saveSummary(
            sessionId: sid,
            summary: sharedSummary,
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
      return sharedSummary;
    } catch (e) {
      dev.log('❌ Summary generation error: $e');
      await _saveFallbackSummary(durationMinutes, pendingTask);
      return null;
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

  // ============================================================
  // STALE SESSION SWEEP (abandoned chat memory recovery)
  // ============================================================

  /// Kal se pehle ki OPEN chat sessions ka memory save karta hai aur sab ko
  /// close karta hai, aur closed sessions ki list return karta hai
  /// (`{id, createdAt, messageCount, summary}`) taake caller unhe Report
  /// history entries bana sake. App kill hone ya din badalne par bina End
  /// ke chhori gayi conversations ka summary + userFacts yahan recover
  /// hote hain, taake NOVA agli baar user ki history jaan sake.
  ///
  /// Cost guard: sirf last-10 open sessions, aur AI summary sirf unhi
  /// sessions ka jo 2+ messages rakhti ho (khaali sessions bas close hoti
  /// hain). Instance state (_currentSessionId) ko touch nahi karta.
  Future<List<Map<String, dynamic>>> sweepStaleChatSessions() async {
    final closedSessions = <Map<String, dynamic>>[];
    try {
      final staleList = await _firebaseService.getStaleOpenChatSessions();
      if (staleList.isEmpty) return closedSessions;

      for (final s in staleList) {
        final id = s['id'] as String;
        try {
          final messages = await _firebaseService.getSessionMessages(id);
          final history = messages.map<Map<String, String>>((msg) {
            return {
              'sender': (msg['sender'] as String?) ?? 'nova',
              'text': (msg['text'] as String?) ?? '',
            };
          }).toList();

          var summaryText = '';
          if (history.length >= 2 && _apiService.isConfigured) {
            final createdAt = DateTime.tryParse(
              (s['createdAt'] as String?) ?? '',
            );
            final minutes = createdAt == null
                ? 0
                : DateTime.now()
                    .difference(createdAt)
                    .inMinutes
                    .clamp(0, 240);
            final summary = await generateSessionSummary(
              durationMinutes: minutes,
              pendingTask: null,
              sessionId: id,
              history: history,
            );
            summaryText = summary ?? '';
          }

          await _firebaseService.closeSession(id);
          closedSessions.add({
            'id': id,
            'createdAt': s['createdAt'],
            'messageCount': history.length,
            'summary': summaryText,
          });
        } catch (e) {
          dev.log('⚠️ Stale session summary failed ($id): $e');
          // Memory fail ho to bhi session leak na ho — close to karo.
          try {
            await _firebaseService.closeSession(id);
          } catch (_) {}
        }
      }
      dev.log('🧹 Swept ${staleList.length} stale chat session(s)');
    } catch (e) {
      dev.log('⚠️ Stale chat sweep error: $e');
    }
    return closedSessions;
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
