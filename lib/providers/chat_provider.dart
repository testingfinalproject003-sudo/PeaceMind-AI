// lib/providers/chat_provider.dart
import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import '../services/session_manager.dart';

class ChatProvider extends ChangeNotifier {
  final SessionManager _sessionManager = SessionManager();

  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _error;
  String? _currentSessionId;
  bool _isSessionActive = false;

  // User context for AI
  String? _personalityTag;
  String? _overallSummaryText;

  // ============================================================
  // 🔥 EXERCISE SUGGESTION STATE (ADD THESE)
  // ============================================================
  String? _pendingExerciseId;
  DateTime? _lastSuggestionTime;
  static const Duration _exerciseCooldown = Duration(minutes: 3);

  // Stream listener
  Stream? _messageStream;
  StreamSubscription? _messageSubscription;

  // ============================================================
  // GETTERS
  // ============================================================

  List<Map<String, dynamic>> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get error => _error;
  String? get currentSessionId => _currentSessionId;
  bool get isSessionActive => _isSessionActive;
  String? get personalityTag => _personalityTag;
  String? get overallSummaryText => _overallSummaryText;

  // ============================================================
  // 🔥 NEW GETTER (ADD THIS)
  // ============================================================
  String? get pendingExerciseId => _pendingExerciseId;

  // ============================================================
  // SESSION MANAGEMENT
  // ============================================================

  Future<void> initialize({String? sessionId}) async {
    _setLoading(true);
    _error = null;

    try {
      await _loadUserContext();

      if (sessionId != null && sessionId.isNotEmpty) {
        await _sessionManager.loadSession(sessionId);
        _currentSessionId = sessionId;
        _isSessionActive = true;
        dev.log('🟢 Loaded existing session: $sessionId');
      } else {
        _currentSessionId = await _sessionManager.startNewSession();
        _isSessionActive = true;
        dev.log('🟢 Created new session: $_currentSessionId');
      }

      _startMessageListener();
    } catch (e) {
      _error = 'Failed to initialize chat: $e';
      _isSessionActive = false;
      dev.log('❌ Initialize error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> startNewSession() async {
    if (_isLoading) return;

    _setLoading(true);
    _error = null;

    try {
      _stopMessageListener();
      _currentSessionId = await _sessionManager.startNewSession();
      _isSessionActive = true;
      _messages.clear();
      _startMessageListener();
      notifyListeners();
      dev.log('🟢 Started new session: $_currentSessionId');
    } catch (e) {
      _error = 'Failed to start new session: $e';
      _isSessionActive = false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadSession(String sessionId) async {
    if (_isLoading) return;

    _setLoading(true);
    _error = null;

    try {
      _stopMessageListener();
      await _sessionManager.loadSession(sessionId);
      _currentSessionId = sessionId;
      _isSessionActive = true;
      _messages.clear();
      _startMessageListener();
      notifyListeners();
      dev.log('🟢 Loaded session: $sessionId');
    } catch (e) {
      _error = 'Failed to load session: $e';
      _isSessionActive = false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> endSession({
    required int durationMinutes,
    String? pendingTask,
  }) async {
    if (!_isSessionActive || _currentSessionId == null) return;

    _setLoading(true);
    _error = null;

    try {
      await _sessionManager.generateSessionSummary(
        durationMinutes: durationMinutes,
        pendingTask: pendingTask,
      );

      await _sessionManager.closeSession();
      _isSessionActive = false;
      _currentSessionId = null;
      _stopMessageListener();
      _messages.clear();
      notifyListeners();
      dev.log('🟢 Session ended');
    } catch (e) {
      _error = 'Failed to end session: $e';
    } finally {
      _setLoading(false);
    }
  }

  // ============================================================
  // MESSAGE HANDLING
  // ============================================================

  Future<void> sendMessage({
    required String text,
    String? language,
  }) async {
    if (_isSending || text.trim().isEmpty) {
      dev.log('⚠️ Cannot send: isSending=$_isSending');
      return;
    }
    if (!_isSessionActive) {
      _error = 'No active session. Please start a new session.';
      notifyListeners();
      return;
    }

    _isSending = true;
    _error = null;
    notifyListeners();

    try {
      dev.log('📤 Sending message: ${text.substring(0, text.length > 20 ? 20 : text.length)}...');

      final result = await _sessionManager.sendMessage(
        message: text.trim(),
        language: language ?? 'en',
        personalityTag: _personalityTag,
        sessionSummary: _overallSummaryText,
      );

      dev.log('✅ Message sent successfully');
      await reloadMessages();

      // 🔥 Check if we should suggest an exercise
      _checkAndTriggerExercise(result.distressLevel, result.suggestedExercise);

    } catch (e) {
      _error = 'Failed to send message: $e';
      dev.log('❌ Send message error: $e');
      notifyListeners();
    } finally {
      _isSending = false;
      dev.log('🔄 isSending set to false');
      notifyListeners();
    }
  }

  // ============================================================
  // 🔥 EXERCISE SUGGESTION LOGIC (ADD THESE)
  // ============================================================

  void _checkAndTriggerExercise(double? distressLevel, String? suggestedExercise) {
    if (distressLevel == null || distressLevel <= 0.7) {
      dev.log('ℹ️ Distress level ${distressLevel ?? 'null'} — no exercise needed.');
      return;
    }

    if (suggestedExercise == null || suggestedExercise.isEmpty) {
      dev.log('ℹ️ No exercise suggested by AI.');
      return;
    }

    // Cooldown check (3 minutes)
    if (_lastSuggestionTime != null) {
      final timeSinceLast = DateTime.now().difference(_lastSuggestionTime!);
      if (timeSinceLast < _exerciseCooldown) {
        final remaining = _exerciseCooldown - timeSinceLast;
        dev.log('⏳ Exercise cooldown active. ${remaining.inSeconds} seconds remaining.');
        return;
      }
    }

    dev.log('🏋️ Triggering exercise suggestion: $suggestedExercise');
    _pendingExerciseId = suggestedExercise;
    _lastSuggestionTime = DateTime.now();
    notifyListeners();
  }

  // ============================================================
  // 🔥 NEW METHOD (ADD THIS)
  // ============================================================
  void clearPendingExercise() {
    if (_pendingExerciseId != null) {
      dev.log('🧘 Cleared pending exercise: $_pendingExerciseId');
      _pendingExerciseId = null;
      notifyListeners();
    }
  }

  // ============================================================
  // USER CONTEXT LOADING
  // ============================================================

  Future<void> _loadUserContext() async {
    try {
      final summary = await _sessionManager.fetchOverallSummary();
      if (summary != null) {
        _personalityTag = summary['personalityStability'] as String?;

        final topics = (summary['recurringTopics'] as List?)?.join(', ') ?? 'various topics';
        final techniques = (summary['mostUsedTechniques'] as List?)?.join(', ') ?? 'various techniques';
        final sessionCount = summary['sessionCount'] ?? 0;

        if (sessionCount > 0) {
          _overallSummaryText =
              'This user has had $sessionCount previous sessions. '
              'Recurring topics include: $topics. '
              'Previously used techniques: $techniques.';
        } else {
          _overallSummaryText = 'New user. No prior sessions.';
        }

        dev.log('👤 Personality Tag: $_personalityTag');
        dev.log('📚 Overall Summary: $_overallSummaryText');
      } else {
        _personalityTag = null;
        _overallSummaryText = 'New user. No prior sessions.';
        dev.log('👤 No overall summary found for user.');
      }
    } catch (e) {
      dev.log('❌ Error loading user context: $e');
      _personalityTag = null;
      _overallSummaryText = 'New user. No prior sessions.';
    }
  }

  // ============================================================
  // REAL-TIME LISTENING
  // ============================================================

  void _startMessageListener() {
    if (_currentSessionId == null) {
      dev.log('❌ Cannot start listener: no session ID');
      return;
    }
    if (_messageSubscription != null) {
      dev.log('ℹ️ Listener already active');
      return;
    }

    dev.log('🟢 Starting message listener for session: $_currentSessionId');

    _messageStream = _sessionManager.listenToMessages();
    _messageSubscription = _messageStream?.listen(
      (messages) {
        dev.log('📩 Received ${messages.length} messages from Firestore');

        _messages = messages.map((msg) {
          return {
            'id': msg['id'] ?? '',
            'sender': msg['sender'] ?? '',
            'text': msg['text'] ?? '',
            'timestamp': msg['timestamp'],
            'language': msg['language'] ?? 'en',
            'distressLevel': msg['distressLevel'],
          };
        }).toList();

        dev.log('✅ UI updated with ${_messages.length} messages');
        notifyListeners();
      },
      onError: (error) {
        dev.log('❌ Stream error: $error');
        _error = 'Failed to listen to messages: $error';
        notifyListeners();
      },
      onDone: () {
        dev.log('🔴 Stream closed');
      },
    );
  }

  void _stopMessageListener() {
    if (_messageSubscription != null) {
      dev.log('🛑 Stopping message listener');
      _messageSubscription?.cancel();
      _messageSubscription = null;
      _messageStream = null;
    }
  }

  // ============================================================
  // MESSAGE FETCHING
  // ============================================================

  Future<void> reloadMessages() async {
    if (_currentSessionId == null) {
      dev.log('❌ No active session to reload');
      return;
    }

    try {
      dev.log('🔄 Reloading messages...');
      final messages = await _sessionManager.fetchMessages();
      _messages = messages.map((msg) {
        return {
          'id': msg['id'] ?? '',
          'sender': msg['sender'] ?? '',
          'text': msg['text'] ?? '',
          'timestamp': msg['timestamp'],
          'language': msg['language'] ?? 'en',
          'distressLevel': msg['distressLevel'],
        };
      }).toList();
      dev.log('✅ Reloaded ${_messages.length} messages');
      notifyListeners();
    } catch (e) {
      dev.log('❌ Reload error: $e');
      _error = 'Failed to reload messages: $e';
      notifyListeners();
    }
  }

  // ============================================================
  // UTILITY
  // ============================================================

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _stopMessageListener();
    _sessionManager.reset();
    _messages.clear();
    _currentSessionId = null;
    _isSessionActive = false;
    _isLoading = false;
    _isSending = false;
    _error = null;
    _pendingExerciseId = null;
    _lastSuggestionTime = null;
    notifyListeners();
  }

  // ============================================================
  // PRIVATE HELPERS
  // ============================================================

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // ============================================================
  // DISPOSAL
  // ============================================================

  @override
  void dispose() {
    _stopMessageListener();
    super.dispose();
  }
}