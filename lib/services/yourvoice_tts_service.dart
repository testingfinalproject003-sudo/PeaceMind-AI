import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Cloud-based TTS service using the YourVoic API for natural, human-like
/// voice synthesis — primarily for Urdu narration where on-device Google
/// TTS voices sound robotic.
///
/// Reads YOUR_VOICE_API_KEY and TTS_MODEL from the project .env file
/// (already loaded via flutter_dotenv in main.dart).  Falls back silently
/// to null when the API is unreachable so callers can drop to device TTS.
///
/// YourVoic API contract:
///   Endpoint : POST https://yourvoic.com/api/v1/tts/generate
///   Auth     : X-API-Key header
///   Body     : `{ "text", "voice", "language", "model" }`
///   Response : raw MP3 bytes
///   Voices   : `GET /api/v1/voices?language=<locale>`
class YourVoiceTtsService {
  YourVoiceTtsService._();
  static final YourVoiceTtsService instance = YourVoiceTtsService._();

  static const _baseUrl = 'https://yourvoic.com/api/v1';

  /// Default voice name — a warm, calm female voice suitable for guided
  /// meditation.  The name localises per language on YourVoic's side.
  static const String defaultVoice = 'Rachel';

  /// Synthesise [text] in the given [language] locale (e.g. 'ur-PK')
  /// and return raw MP3 bytes, or `null` on failure.
  Future<Uint8List?> synthesize(
    String text, {
    String language = 'ur-PK',
    String? voice,
  }) async {
    final apiKey = dotenv.env['YOUR_VOICE_API_KEY'] ?? '';
    final model = dotenv.env['TTS_MODEL'] ?? 'rapid-flash';
    if (apiKey.isEmpty) {
      debugPrint('[YourVoic] YOUR_VOICE_API_KEY missing in .env');
      return null;
    }

    final uri = Uri.parse('$_baseUrl/tts/generate');

    try {
      final response = await http
          .post(
        uri,
        headers: {
          'X-API-Key': apiKey,
          'Content-Type': 'application/json',
          'Accept': 'audio/mpeg',
        },
        body: jsonEncode({
          'text': text,
          'voice': voice ?? defaultVoice,
          'language': language,
          'model': model,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      }

      debugPrint(
        '[YourVoic] HTTP ${response.statusCode}: '
        '${response.body.substring(0, response.body.length.clamp(0, 200))}',
      );
      return null;
    } catch (e) {
      debugPrint('[YourVoic] synthesize error: $e');
      return null;
    }
  }
}
