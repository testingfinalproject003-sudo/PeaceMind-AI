// lib/services/session_manager.dart
import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_chat_service.dart';
import 'api_chat_service.dart';

/// Result returned after sending a message.
class SendMessageResult {
  final String reply;
  final double? distressLevel;
  final String? suggestedExercise;

  SendMessageResult({
    required this.reply,
    this.distressLevel,
    this.suggestedExercise,
  });
}

/// Manages the chat session lifecycle and orchestrates communication
/// between Firebase and the AI API.
class SessionManager {
  final FirebaseChatService _firebaseService = FirebaseChatService();
  final ApiChatService _apiService = ApiChatService();

  String? _currentSessionId;
  List<Map<String, String>> _conversationHistory = [];
  bool _isProcessing = false;

  // ============================================================
  // GETTERS
  // ============================================================

  String? get currentSessionId => _currentSessionId;
  List<Map<String, String>> get conversationHistory => List.unmodifiable(_conversationHistory);
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
    dev.log('🟢 Loaded session: $sessionId with ${_conversationHistory.length} messages');
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
      );
      dev.log('✅ API reply received');
      dev.log('📊 Distress Level: ${aiResponse.distressLevel}');
      dev.log('🏋️ Suggested Exercise: ${aiResponse.suggestedExercise}');

      // 3. Save AI reply with distress level
      await _firebaseService.saveMessage(
        sessionId: _currentSessionId!,
        sender: 'nova',
        text: aiResponse.reply,
        language: language ?? 'en',
        distressLevel: aiResponse.distressLevel,
      );
      _conversationHistory.add({
        'sender': 'nova',
        'text': aiResponse.reply,
      });

      // 4. Return full result
      return SendMessageResult(
        reply: aiResponse.reply,
        distressLevel: aiResponse.distressLevel,
        suggestedExercise: aiResponse.suggestedExercise,
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
        final messages = await _firebaseService.getSessionMessages(_currentSessionId!);
        final distressValues = messages
            .map((m) => m['distressLevel'] as double?)
            .where((d) => d != null)
            .cast<double>()
            .toList();
        if (distressValues.isNotEmpty) {
          averageDistress = distressValues.reduce((a, b) => a + b) / distressValues.length;
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
      );
      dev.log('✅ Session summary saved');

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

  Future<void> _saveFallbackSummary(int durationMinutes, String? pendingTask) async {
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

    if (overall != null) {
      await _firebaseService.saveOverallSummary(
        userId: userId,
        personalityStability: overall['personalityStability'] ?? summaryData['personalityTag'] ?? 'General',
        distressTrend: [
          ...List<double>.from(overall['distressTrend'] ?? []),
          averageDistress,
        ],
        mostUsedTechniques: summaryData['techniquesUsed'],
        recurringTopics: summaryData['topicsDiscussed'],
        sessionCount: (overall['sessionCount'] ?? 0) + 1,
      );
    } else {
      await _firebaseService.saveOverallSummary(
        userId: userId,
        personalityStability: summaryData['personalityTag'] ?? 'General',
        distressTrend: [averageDistress],
        mostUsedTechniques: summaryData['techniquesUsed'],
        recurringTopics: summaryData['topicsDiscussed'],
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