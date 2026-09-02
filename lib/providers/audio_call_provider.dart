import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../logic/audio_call_session_logic.dart';
import '../models/audio_call_session_model.dart';
import '../models/history_model.dart';
import '../services/audio_call_service.dart';
import '../services/language_detection_service.dart';
import '../services/session_memory_service.dart';
import '../services/speech_to_text_service.dart';
import 'routine_provider.dart';

class SafetyDetector {
  static bool evaluate(String text) {
    final cleanText = text.trim().toLowerCase();
    if (cleanText.isEmpty) {
      return true;
    }

    final unsafePatterns = <String>{
      'i want to die',
      'kill myself',
      'suicide',
      'self harm',
      'hurt myself',
      'end my life',
      'i can\'t go on',
      'no reason to live',
      'i want to disappear',
      'i am going to kill',
      'i am going to hurt myself',
      'i want to hurt myself',
    };

    for (final pattern in unsafePatterns) {
      if (cleanText.contains(pattern)) {
        return false;
      }
    }

    return true;
  }
}

class AudioCallProvider extends ChangeNotifier {
  AudioCallProvider({
    AudioCallService? service,
    SpeechToTextService? speechService,
    SessionMemoryService? sessionMemory,
    this.routineProvider,
  })  : _audioCallService = service ?? AudioCallService(),
        _speechToTextService = speechService ?? SpeechToTextService(),
        _sessionMemory = sessionMemory ?? SessionMemoryService();

  final AudioCallService _audioCallService;
  final SpeechToTextService _speechToTextService;
  final SessionMemoryService _sessionMemory;
  final RoutineProvider? routineProvider;
  final LanguageDetectionService _langDetector = const LanguageDetectionService();

  AudioCallState _state = AudioCallState.idle;
  String _statusText = 'Listening...';
  String _lastTranscript = '';
  String _lastNovaResponse = '';
  bool _panicVisible = false;
  bool _isBusy = false;
  bool _sttUnavailable = false;
  bool _isListening = false;
  final String _sessionId = const Uuid().v4();
  String _sessionSummary = '';
  String _lastSubmittedTranscript = '';

  /// Current detected language code ('en', 'ur', 'pa')
  String _detectedLang = 'en';
  String get detectedLang => _detectedLang;

  /// Whether the user opted into manual tap-to-speak mode.
  /// Default is false = continuous VAD listening.
  bool _manualTapMode = false;
  bool get manualTapMode => _manualTapMode;

  /// Full transcript log for session replay from history.
  final List<Map<String, dynamic>> _sessionTranscript = [];
  List<Map<String, dynamic>> get sessionTranscript =>
      List.unmodifiable(_sessionTranscript);

  /// Session kab shuru hua + kitni baar user bola
  /// (endCall par history entry banati hai).
  DateTime? _sessionStartTime;
  int _turnCount = 0;
  bool _historySaved = false;

  AudioCallState get state => _state;
  String get statusText => _statusText;
  String get lastTranscript => _lastTranscript;
  String get lastNovaResponse => _lastNovaResponse;
  bool get panicVisible => _panicVisible;
  bool get isBusy => _isBusy;
  bool get isListening => _isListening;
  bool get sttUnavailable => _sttUnavailable;
  String get sessionId => _sessionId;
  String get sessionSummary => _sessionSummary;

  Future<void> initialize() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _statusText = 'Sign in to start the call';
      _state = AudioCallState.error;
      notifyListeners();
      return;
    }

    if (kIsWeb) {
      _sttUnavailable = true;
      _statusText = 'Speech input is not available in this browser.';
      _state = AudioCallState.error;
      notifyListeners();
      return;
    }

    final available = await _speechToTextService.initialize();
    if (!available) {
      _sttUnavailable = true;
      _statusText = 'Microphone access is unavailable.';
      _state = AudioCallState.error;
      notifyListeners();
      return;
    }

    _sessionSummary = await _sessionMemory.fetchLatestSummary();
    _sessionStartTime = DateTime.now();
    _turnCount = 0;
    _historySaved = false;
    _sessionTranscript.clear();
    _detectedLang = 'en';

    // Default: continuous VAD listening — auto-start
    _statusText = 'Listening...';
    _state = AudioCallState.idle;
    notifyListeners();

    // Auto-start listening (VAD mode, not manual tap)
    if (!_manualTapMode) {
      _startContinuousListening();
    }
  }

  /// Toggle between continuous VAD and manual tap-to-speak.
  void toggleManualTapMode() {
    _manualTapMode = !_manualTapMode;
    if (_manualTapMode) {
      // Switching to manual: stop continuous listening
      _speechToTextService.stopListening();
      _statusText = 'Tap to speak';
      _state = AudioCallState.idle;
      _isListening = false;
    } else {
      // Switching to VAD: auto-start listening
      _statusText = 'Listening...';
      _state = AudioCallState.idle;
      _startContinuousListening();
    }
    notifyListeners();
  }

  /// Internal: starts STT with current locale for continuous VAD.
  void _startContinuousListening() {
    if (_state == AudioCallState.ending || _state == AudioCallState.ended) return;
    final locale = _langDetector.sttLocaleFor(_detectedLang);
    _beginListening(localeId: locale);
  }

  Future<void> startListening() async {
    final locale = _langDetector.sttLocaleFor(_detectedLang);
    await _beginListening(localeId: locale);
  }

  Future<void> _beginListening({String localeId = 'en-US'}) async {
    if (_state == AudioCallState.processing ||
        _state == AudioCallState.novaSpeaking ||
        _state == AudioCallState.ending ||
        _state == AudioCallState.ended) {
      return;
    }

    final safeState = AudioCallSessionLogic.applyTransition(
      _state,
      AudioCallState.connecting,
    );
    _state = safeState;
    _statusText = 'Connecting...';
    notifyListeners();

    if (kIsWeb) {
      _sttUnavailable = true;
      _statusText = 'STT is unavailable on the web. Use text fallback.';
      _state = AudioCallState.error;
      notifyListeners();
      return;
    }

    final available = await _speechToTextService.initialize();
    if (!available) {
      _sttUnavailable = true;
      _statusText = 'Please allow microphone access.';
      _state = AudioCallState.error;
      notifyListeners();
      return;
    }

    final nextState = AudioCallSessionLogic.applyTransition(
      _state,
      AudioCallState.listening,
    );
    _state = nextState;
    _isListening = true;
    _statusText = 'Listening...';
    notifyListeners();

    await _speechToTextService.listen(
      localeId: localeId,
      onResult: (result) async {
        final words = result.recognizedWords.trim();
        if (words.isEmpty) {
          // VAD: silence detected — restart listening loop
          if (!_manualTapMode &&
              _state == AudioCallState.listening) {
            _startContinuousListening();
          }
          return;
        }

        if (result.finalResult) {
          _lastTranscript = words;
          _statusText = 'Processing...';
          _state = AudioCallState.processing;
          notifyListeners();
          await handleRecognizedTranscript(words);
        }
      },
      onError: (message) {
        _statusText = message;
        _state = AudioCallState.error;
        _isListening = false;
        notifyListeners();
      },
    );
  }

  Future<void> handleRecognizedTranscript(String transcript) async {
    final cleanText = transcript.trim();
    if (cleanText.isEmpty) {
      _statusText = 'No speech detected';
      _state = AudioCallState.idle;
      _isListening = false;
      notifyListeners();
      return;
    }

    if (_lastSubmittedTranscript == cleanText) {
      _state = AudioCallState.listening;
      _statusText = 'Listening...';
      notifyListeners();
      return;
    }

    _lastSubmittedTranscript = cleanText;
    _turnCount++;

    // ── Rule 1: Auto-detect language per utterance ──
    _detectedLang = _langDetector.detect(cleanText);
    final langName = _langDetector.promptLanguageName(_detectedLang);
    final ttsLocale = _langDetector.ttsLocaleFor(_detectedLang);

    final safe = SafetyDetector.evaluate(cleanText);
    if (!safe) {
      _panicVisible = true;
      _state = AudioCallState.paused;
      _statusText = 'Safety check active';
      await _audioCallService.saveCrisisMessage(
        sessionId: _sessionId,
        transcript: cleanText,
      );
      await _speechToTextService.speak(
        'I am here with you. Please take a slow breath and focus on one safe thing around you. I am going to help you settle and stay safe.',
        locale: ttsLocale,
      );
      notifyListeners();
      return;
    }

    _isBusy = true;
    _statusText = 'Processing...';
    notifyListeners();

    final response = await _audioCallService.callNova(
      cleanText,
      _sessionSummary,
      detectedLang: langName,
    );
    if (response == null || response.trim().isEmpty) {
      _state = AudioCallState.error;
      _statusText = 'Network issue. Please try again.';
      _isBusy = false;
      notifyListeners();
      return;
    }

    final now = DateTime.now();
    final session = AudioCallSessionModel(
      id: _sessionId,
      userId: FirebaseAuth.instance.currentUser?.uid ?? '',
      state: AudioCallState.listening,
      sessionSummary: _sessionSummary,
      lastTranscript: cleanText,
      lastNovaResponse: response,
      messageCount: 2,
      createdAt: now,
      updatedAt: now,
    );

    // ── Append to session transcript for replay ──
    _sessionTranscript.add({
      'role': 'user',
      'text': cleanText,
      'time': DateTime.now().toIso8601String(),
    });

    await _audioCallService.saveMessage(
      sessionId: _sessionId,
      text: cleanText,
      role: 'user',
      source: 'audio_call',
    );
    await _audioCallService.saveMessage(
      sessionId: _sessionId,
      text: response,
      role: 'nova',
      source: 'audio_call',
    );
    await _audioCallService.saveSession(session);

    _sessionTranscript.add({
      'role': 'nova',
      'text': response,
      'time': DateTime.now().toIso8601String(),
    });

    _lastTranscript = cleanText;
    _lastNovaResponse = response;
    _state = AudioCallState.novaSpeaking;
    _statusText = 'NOVA speaking...';
    notifyListeners();

    await _speechToTextService.speak(response, locale: ttsLocale);

    // After NOVA finishes speaking, auto-restart listening (VAD mode)
    _state = AudioCallState.listening;
    _statusText = 'Listening...';
    _isBusy = false;
    _isListening = true;
    notifyListeners();

    await _speechToTextService.stopListening();

    // Continuous VAD: auto-restart listening loop
    if (!_manualTapMode) {
      _startContinuousListening();
    }
  }

  Future<void> resolvePanic() async {
    _panicVisible = false;
    _statusText = 'Listening...';
    _state = AudioCallState.idle;
    notifyListeners();
    // Resume VAD listening after panic resolution
    if (!_manualTapMode) {
      _startContinuousListening();
    }
  }

  Future<void> endCall() async {
    _state = AudioCallState.ending;
    _statusText = 'Ending session...';
    notifyListeners();

    final finalSummary = _lastTranscript.isNotEmpty
        ? 'User shared: $_lastTranscript. NOVA response: $_lastNovaResponse.'
        : _sessionSummary;

    // Rule 3: save summary to shared cross-session memory store
    await _sessionMemory.saveSummary(
      sessionId: _sessionId,
      summary: finalSummary,
    );

    // ── Save transcript blob for history replay ──
    await _audioCallService.saveSessionTranscript(
      sessionId: _sessionId,
      transcript: _sessionTranscript,
    );

    // ── History mein session save karo (duration + snippet) ──
    _saveCallHistory();

    _state = AudioCallState.ended;
    _statusText = 'Session ended';
    await _speechToTextService.stopListening();
    notifyListeners();
  }

  /// NOVA call ko RoutineProvider ke history (local + Firestore)
  /// mein 'audio' category ke sath entry bana deta hai.
  void _saveCallHistory() {
    if (_historySaved) return;
    final provider = routineProvider;
    if (provider == null) return;
    if (_sessionStartTime == null || _turnCount == 0) return;

    _historySaved = true;

    final duration = DateTime.now().difference(_sessionStartTime!);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    // Snippet: user ka aakhri khayal (max 90 chars, ek line)
    var snippet = _lastTranscript.trim();
    if (snippet.length > 90) snippet = '${snippet.substring(0, 90)}...';

    provider.addHistoryEntry(HistoryEntry(
      id: _sessionId,
      routineId: _sessionId,
      routineTitle: 'NOVA Voice Session',
      category: 'audio',
      completedAt: DateTime.now(),
      moodScore: null,
      notes: '${minutes}m ${seconds}s · $_turnCount turns — $snippet',
    ));
  }

  Future<void> resetForNextTurn() async {
    _lastSubmittedTranscript = '';
    _state = AudioCallState.idle;
    _statusText = _manualTapMode ? 'Tap to speak' : 'Listening...';
    _isListening = false;
    notifyListeners();
    // Auto-restart VAD if in continuous mode
    if (!_manualTapMode) {
      _startContinuousListening();
    }
  }
}
