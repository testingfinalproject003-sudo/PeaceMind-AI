import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechToTextService {
  SpeechToTextService({FlutterTts? flutterTts, stt.SpeechToText? speechToText})
      : _flutterTts = flutterTts ?? FlutterTts(),
        _speechToText = speechToText ?? stt.SpeechToText();

  final FlutterTts _flutterTts;
  final stt.SpeechToText _speechToText;

  bool _isInitialized = false;
  bool _isListening = false;
  String? _lastError;

  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;
  String? get lastError => _lastError;

  Future<bool> initialize() async {
    final isWeb = kIsWeb;
    if (isWeb) {
      _isInitialized = false;
      _lastError = 'Speech input is not available in this browser.';
      return false;
    }

    try {
      final available = await _speechToText.initialize(
        onError: (error) {
          _lastError = error.errorMsg.isEmpty
              ? 'Speech recognition is unavailable.'
              : error.errorMsg;
        },
        onStatus: (status) {
          _isListening = status == 'listening';
        },
      );

      _isInitialized = available;
      if (available) {
        await _configureTts();
      }
      return available;
    } catch (_) {
      _isInitialized = false;
      _lastError = 'Speech recognition is unavailable on this device.';
      return false;
    }
  }

  Future<void> _configureTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> listen({
    required void Function(SpeechRecognitionResult result) onResult,
    required void Function(String message) onError,
    String localeId = 'en-US',
  }) async {
    final isWeb = kIsWeb;
    if (isWeb || !_isInitialized) {
      onError('Speech input is not available on this browser.');
      return;
    }

    try {
      _lastError = null;
      _isListening = true;
      await _speechToText.listen(
        onResult: onResult,
        listenOptions: stt.SpeechListenOptions(
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 4),
          localeId: localeId,
          cancelOnError: true,
          partialResults: true,
        ),
      );
    } catch (_) {
      _isListening = false;
      onError('Unable to start microphone listening.');
    }
  }

  Future<void> stopListening() async {
    if (!_isInitialized) {
      _isListening = false;
      return;
    }
    try {
      await _speechToText.stop();
    } catch (_) {
      _lastError = 'Unable to stop microphone listening.';
    }
    _isListening = false;
  }

  Future<void> speak(String text, {String locale = 'en-US'}) async {
    final message = text.trim();
    if (message.isEmpty) {
      return;
    }

    try {
      await _flutterTts.stop();
      await _flutterTts.setLanguage(locale);
      await _flutterTts.speak(message);
    } catch (_) {
      _lastError = 'Voice response is unavailable.';
    }
  }
}
