// lib/providers/chat_provider.dart
import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import '../models/history_model.dart';
import 'routine_provider.dart';
import '../services/session_manager.dart';
import '../services/session_memory_service.dart';
import '../services/speech_to_text_service.dart';
import '../services/language_detection_service.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider({RoutineProvider? routineProvider})
    : _routineProvider = routineProvider;

  /// Report/History entries (local + Firestore) likhne ke liye — app-level
  /// provider; null hone par entries skip ho jati hain (tests etc.).
  final RoutineProvider? _routineProvider;

  final SessionManager _sessionManager = SessionManager();
  final SessionMemoryService _sessionMemory = SessionMemoryService();
  final SpeechToTextService _speechService = SpeechToTextService();
  final LanguageDetectionService _langDetector =
      const LanguageDetectionService();

  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _error;
  String? _currentSessionId;
  bool _isSessionActive = false;

  // ── Daily session + pagination state ──
  DateTime? _sessionDay; // kis din ka session active hai

  /// Din badalne par active session auto-close (End Session na daba ho).
  Timer? _dayCheckTimer;
  int _messageLimit = 50;
  bool _hasMoreMessages = false;
  bool _isLoadingOlder = false;
  bool _isInitialLoad = true;

  // User context for AI
  String? _personalityTag;
  String? _overallSummaryText;
  String? _userName;

  /// Profile name from the existing user profile (Firestore / Firebase Auth).
  String? get userName => _userName;

  // ============================================================
  // 🔥 EXERCISE SUGGESTION STATE (ADD THESE)
  // ============================================================
  String? _pendingExerciseId;
  DateTime? _lastSuggestionTime;
  static const Duration _exerciseCooldown = Duration(minutes: 3);

  // Stream listener — typed so the stream callback receives
  // List<Map<String, dynamic>> (dynamic .map().toList() → List<dynamic>
  // crash hota tha aur bubbles kabhi render nahi hote the).
  Stream<List<Map<String, dynamic>>>? _messageStream;
  StreamSubscription<List<Map<String, dynamic>>>? _messageSubscription;

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
  bool get isLoadingOlder => _isLoadingOlder;
  bool get hasMoreMessages => _hasMoreMessages;
  bool get isInitialLoad => _isInitialLoad;

  // ============================================================
  // 🔥 NEW GETTER (ADD THIS)
  // ============================================================
  String? get pendingExerciseId => _pendingExerciseId;

  // ============================================================
  // SESSION MANAGEMENT
  // ============================================================

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _resetPaginationState() {
    _messageLimit = 50;
    _hasMoreMessages = false;
    _isLoadingOlder = false;
    _isInitialLoad = true;
  }

  Future<void> initialize({String? sessionId}) async {
    _setLoading(true);
    _error = null;

    try {
      final now = DateTime.now();

      // Active session + same day (e.g. exercise se wapas aaye ya
      // screen dobara khula) — SAME session continue, kuch reset nahi.
      if (_isSessionActive && _currentSessionId != null) {
        if (_sessionDay != null && _isSameDay(_sessionDay!, now)) {
          _startMessageListener(); // idempotent — already active to skip
          _startDayCheck();
          dev.log('🟢 Continuing active session: $_currentSessionId');
          return;
        }

        // Day changed — End Session na daba ho to bhi purane session ka
        // memory + Report entry save karo, phir quietly close.
        try {
          await _closeCurrentSession(endedAt: now);
        } catch (e) {
          dev.log('⚠️ Day-rollover summary/close error: $e');
        }
      }

      // App-restart gap: kal se pehle ki OPEN sessions Firestore mein
      // pending reh jati hain (app kill / bina End Session ke exit) — unka
      // memory save karke close karo, warna AI wo conversations kabhi
      // nahi jaan paata. (In-process rollover upar handle ho chuka hai.)
      // Auto-closed (swept) sessions ki Report entries — local + Firestore.
      _recordSweptSessions(await _sessionManager.sweepStaleChatSessions());

      await _loadUserContext();

      // Daily resume: aaj ka open session continue karo (app restart /
      // same-day reopen / exercise se wapas), warna naya session banao.
      await _openSession(sessionId: sessionId);
      _startDayCheck();
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
      if (_isSessionActive && _currentSessionId != null) {
        // Purane session ka summary + Report entry save karke close karo.
        await _closeCurrentSession(endedAt: DateTime.now());
      }
      _stopMessageListener();
      _currentSessionId = await _sessionManager.startNewSession();
      _isSessionActive = true;
      _sessionDay = DateTime.now();
      _resetPaginationState();
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
      _sessionDay = DateTime.now();
      _resetPaginationState();
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

  /// Manual End Session — summary + shared memory + Report entry sab
  /// turant save hote hain. Closed sessions kabhi resume nahi hote, isliye
  /// same day dobara khulne par NAYA session banta hai.
  Future<void> endSession({
    required int durationMinutes,
    String? pendingTask,
  }) async {
    if (!_isSessionActive || _currentSessionId == null) return;

    _setLoading(true);
    _error = null;

    try {
      await _closeCurrentSession(
        endedAt: DateTime.now(),
        durationMinutes: durationMinutes,
        pendingTask: pendingTask,
      );

      // Memory refresh — agli session ko updated summary/userFacts
      // milengi (chat AUR voice call dono same memory padhte hain).
      await _loadUserContext();

      notifyListeners();
      dev.log('🟢 Session ended');
    } catch (e) {
      _error = 'Failed to end session: $e';
    } finally {
      _setLoading(false);
    }
  }

  // ============================================================
  // SESSION CLOSE + REPORT ENTRY (shared by all end paths)
  // ============================================================

  /// Active session ka AI summary generate karke close karta hai aur
  /// Report/History entry (local + Firestore) record karta hai. Manual
  /// End Session, day-rollover, auto-close — sab yahi path use karte
  /// hain, is liye session kabhi duplicate record nahi hota.
  Future<void> _closeCurrentSession({
    required DateTime endedAt,
    int? durationMinutes,
    String? pendingTask,
  }) async {
    final endingId = _currentSessionId;
    if (endingId == null) return;

    final history = List<Map<String, String>>.from(
      _sessionManager.conversationHistory,
    );
    final userTurns = history.where((m) => m['sender'] == 'user').length;
    final lastUserText = history.lastWhere(
      (m) => m['sender'] == 'user',
      orElse: () => const <String, String>{},
    )['text'];

    String? summary;
    try {
      if (history.length >= 2) {
        final started = _sessionDay ?? endedAt;
        summary = await _sessionManager.generateSessionSummary(
          durationMinutes:
              durationMinutes ??
              endedAt.difference(started).inMinutes.clamp(0, 240),
          pendingTask: pendingTask,
        );
      }
      await _sessionManager.closeSession();
    } catch (e) {
      dev.log('⚠️ Session close error ($endingId): $e');
      // Offline fail — session open rahe to agli sweep recover karegi.
      try {
        await _sessionManager.closeSession();
      } catch (_) {}
    }

    _stopMessageListener();
    _resetPaginationState();
    _messages.clear();
    _currentSessionId = null;
    _isSessionActive = false;
    _sessionDay = null;
    _dayCheckTimer?.cancel();

    _recordChatHistory(
      sessionId: endingId,
      completedAt: endedAt,
      messageCount: history.length,
      userTurns: userTurns,
      summary: summary,
      snippet: lastUserText,
    );
  }

  /// Aaj ka open session resume karo, warna naya banao. Exercise se
  /// wapas aane par SAME session continue hota hai (yahi resume hota hai).
  Future<void> _openSession({String? sessionId}) async {
    if (sessionId != null && sessionId.isNotEmpty) {
      await _sessionManager.loadSession(sessionId);
      _currentSessionId = sessionId;
      dev.log('🟢 Loaded existing session: $sessionId');
    } else {
      final openId = await _sessionManager.findTodayOpenChatSession();
      if (openId != null) {
        await _sessionManager.loadSession(openId);
        _currentSessionId = openId;
        dev.log('🟢 Resumed today session: $openId');
      } else {
        _currentSessionId = await _sessionManager.startNewSession();
        dev.log('🟢 Created new session: $_currentSessionId');
      }
    }
    _sessionDay = DateTime.now();
    _isSessionActive = true;
    _resetPaginationState();
    _startMessageListener();
  }

  /// Report/History entry record karta hai — RoutineProvider idempotent
  /// hai (same session id dobara add nahi hota) aur local
  /// (SharedPreferences) + Firestore dono mein save karta hai.
  void _recordChatHistory({
    required String sessionId,
    required DateTime completedAt,
    required int messageCount,
    int? userTurns,
    String? summary,
    String? snippet,
  }) {
    final provider = _routineProvider;
    if (provider == null) return;
    if (messageCount < 2) return; // khaali session — report tile nahi

    var trimmedSummary = (summary ?? '').trim();
    if (trimmedSummary.length > 140) {
      trimmedSummary = '${trimmedSummary.substring(0, 140)}...';
    }
    var trimmedSnippet = (snippet ?? '').trim();
    if (trimmedSnippet.length > 90) {
      trimmedSnippet = '${trimmedSnippet.substring(0, 90)}...';
    }

    final countLabel = userTurns != null
        ? '$userTurns messages'
        : '$messageCount messages';
    final notes = [
      countLabel,
      if (trimmedSummary.isNotEmpty)
        trimmedSummary
      else if (trimmedSnippet.isNotEmpty)
        trimmedSnippet,
    ].join(' — ');

    provider.addHistoryEntry(
      HistoryEntry(
        id: sessionId,
        routineId: sessionId,
        routineTitle: 'NOVA Chat Session',
        category: 'chat',
        completedAt: completedAt,
        moodScore: null,
        notes: notes,
      ),
    );
    dev.log('📋 Chat history entry recorded: $sessionId');
  }

  /// Sweep se auto-close hui (abandoned) sessions ki Report entries.
  void _recordSweptSessions(List<Map<String, dynamic>> swept) {
    for (final s in swept) {
      final count = (s['messageCount'] as int?) ?? 0;
      if (count < 2) continue;
      final created = DateTime.tryParse((s['createdAt'] as String?) ?? '');
      _recordChatHistory(
        sessionId: s['id'] as String,
        completedAt: created ?? DateTime.now(),
        messageCount: count,
        summary: (s['summary'] as String?) ?? '',
      );
    }
  }

  // ============================================================
  // DAY ROLLOVER (auto-close at midnight)
  // ============================================================

  /// Din badalne par active session khud-ba-khud close/save ho jaye —
  /// End Session na daba ho to bhi. Lightweight local check (har minute),
  /// Firestore sirf tab chhoota hai jab din sach mein badla ho.
  void _startDayCheck() {
    _dayCheckTimer?.cancel();
    _dayCheckTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      final day = _sessionDay;
      if (!_isSessionActive || day == null) return;
      final now = DateTime.now();
      if (_isSameDay(day, now)) return;
      dev.log('🌗 Day changed — auto-closing chat session');
      _autoRolloverToNewDay();
    });
  }

  Future<void> _autoRolloverToNewDay() async {
    try {
      await _closeCurrentSession(endedAt: DateTime.now());
      _recordSweptSessions(await _sessionManager.sweepStaleChatSessions());
      await _loadUserContext();
      await _openSession();
      _startDayCheck();
      notifyListeners();
    } catch (e) {
      dev.log('⚠️ Auto day-rollover error: $e');
    }
  }

  /// Voice call ke baad shared memory (summary/userFacts) dobara load
  /// karo — chat aur call same long-term memory use karte hain.
  Future<void> refreshUserContext() async {
    await _loadUserContext();
    notifyListeners();
  }

  // ============================================================
  // MESSAGE HANDLING
  // ============================================================

  Future<void> sendMessage({required String text, String? language}) async {
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
      dev.log(
        '📤 Sending message: ${text.substring(0, text.length > 20 ? 20 : text.length)}...',
      );

      final result = await _sessionManager.sendMessage(
        message: text.trim(),
        language: language ?? 'en',
        personalityTag: _personalityTag,
        sessionSummary: _overallSummaryText,
        userName: _userName,
      );

      dev.log('✅ Message sent successfully');
      // NOTE: reloadMessages() call hataya — Firestore snapshot stream
      // khud new messages emit karta hai, dobara pura conversation
      // reload karne ki zaroorat nahi (no flicker / duplicate reload).

      // ── Urdu replies ([SPEAK:true]) are spoken automatically; English
      // replies are not. Fire-and-forget so the input is never blocked.
      if (result.speak) {
        final ttsLocale = _langDetector.ttsLocaleFor(
          _langDetector.detect(result.reply),
        );
        unawaited(_speechService.speak(result.reply, locale: ttsLocale));
      }

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

  void _checkAndTriggerExercise(
    double? distressLevel,
    String? suggestedExercise,
  ) {
    if (distressLevel == null || distressLevel <= 0.7) {
      dev.log(
        'ℹ️ Distress level ${distressLevel ?? 'null'} — no exercise needed.',
      );
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
        dev.log(
          '⏳ Exercise cooldown active. ${remaining.inSeconds} seconds remaining.',
        );
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
      // Profile name — same priority as AuthProvider (Firestore first).
      _userName = await _sessionMemory.fetchUserName();

      final summary = await _sessionManager.fetchOverallSummary();
      if (summary != null) {
        _personalityTag = summary['personalityStability'] as String?;

        final topics =
            (summary['recurringTopics'] as List?)?.join(', ') ??
            'various topics';
        final techniques =
            (summary['mostUsedTechniques'] as List?)?.join(', ') ??
            'various techniques';
        final sessionCount = summary['sessionCount'] ?? 0;

        if (sessionCount > 0) {
          _overallSummaryText =
              'This user has had $sessionCount previous sessions. '
              'Recurring topics include: $topics. '
              'Previously used techniques: $techniques.';
        } else {
          _overallSummaryText = 'New user. No prior sessions.';
        }
      } else {
        _personalityTag = null;
        _overallSummaryText = 'New user. No prior sessions.';
        dev.log('👤 No overall summary found for user.');
      }

      // ── Shared cross-mode memory (userFacts + latest chat/voice session) ──
      final facts = await _sessionMemory.fetchUserFacts();
      if (facts.isNotEmpty) {
        _overallSummaryText =
            '$_overallSummaryText\n\nKnown facts about the user (use naturally, never re-ask):\n- ${facts.join('\n- ')}';
      }

      final sharedSummary = await _sessionMemory.fetchLatestSummary();
      if (sharedSummary != SessionMemoryService.defaultSummary) {
        _overallSummaryText =
            '$_overallSummaryText\n\nLatest session (chat or voice): $sharedSummary';
      }

      dev.log('👤 Personality Tag: $_personalityTag');
      dev.log('📚 Overall Summary: $_overallSummaryText');
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
    // Already listening with same limit — duplicate subscription na banao.
    if (_messageSubscription != null) {
      dev.log('ℹ️ Listener already active');
      return;
    }
    _restartMessageListener();
  }

  /// Cancel + fresh subscribe with current [_messageLimit]
  /// (pagination limit badalne par bhi yahi use hota hai).
  void _restartMessageListener() {
    if (_currentSessionId == null) return;
    _stopMessageListener();

    dev.log('🟢 Listening (limit=$_messageLimit) session: $_currentSessionId');

    _messageStream = _sessionManager.listenToMessages(limit: _messageLimit);
    _messageSubscription = _messageStream?.listen(
      (messages) {
        dev.log('📩 Received ${messages.length} messages from Firestore');

        _isInitialLoad = false;
        _isLoadingOlder = false;
        // Desc order (newest first) — reverse ListView ke saath index 0
        // bottom (newest) par rehta hai, older messages upar append hoti hain.
        _hasMoreMessages = messages.length >= _messageLimit;
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
        _isInitialLoad = false;
        _isLoadingOlder = false;
        _error = 'Failed to listen to messages: $error';
        notifyListeners();
      },
      onDone: () {
        dev.log('🔴 Stream closed');
      },
    );
  }

  /// User upar scroll karta hai → older messages ka next page load.
  /// Listener bade limit ke saath re-subscribe hota hai.
  Future<void> loadOlderMessages() async {
    if (!_hasMoreMessages || _isLoadingOlder || _currentSessionId == null) {
      return;
    }
    _isLoadingOlder = true;
    notifyListeners();
    _messageLimit += 50;
    _restartMessageListener();
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
      // Asc → desc reverse: stream ke order (newest first) se consistent,
      // warna replace hone par chat order flip ho jata.
      _messages = messages
          .map((msg) {
            return {
              'id': msg['id'] ?? '',
              'sender': msg['sender'] ?? '',
              'text': msg['text'] ?? '',
              'timestamp': msg['timestamp'],
              'language': msg['language'] ?? 'en',
              'distressLevel': msg['distressLevel'],
            };
          })
          .toList()
          .reversed
          .toList();
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
    _dayCheckTimer?.cancel();
    _sessionManager.reset();
    _messages.clear();
    _currentSessionId = null;
    _isSessionActive = false;
    _sessionDay = null;
    _resetPaginationState();
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
    _dayCheckTimer?.cancel();
    super.dispose();
  }
}
