// lib/services/api_chat_service.dart
import 'dart:convert';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Response from the AI containing the reply text, distress level, and optional exercise suggestion.
class AiResponse {
  final String reply;
  final double? distressLevel;
  final String? suggestedExercise; // e.g., 'box_breathing', 'grounding', etc.

  AiResponse({
    required this.reply,
    this.distressLevel,
    this.suggestedExercise,
  });
}

/// Service responsible for communicating with OpenRouter API.
/// Handles chat messages, distress scoring, exercise suggestions, and session summaries.
class ApiChatService {
  static const String _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';

  /// API key from environment variables.
  String get _apiKey {
    final key = dotenv.env['OPENROUTER_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('OPENROUTER_API_KEY not found in .env file.');
    }
    return key;
  }

  // Regular expression to extract distress score from AI response.
  static final RegExp _distressRegex = RegExp(
    r'\[DISTRESS_SCORE:\s*([0-9.]+)\]',
    caseSensitive: false,
  );

  // Regular expression to extract suggested exercise from AI response.
  static final RegExp _exerciseRegex = RegExp(
    r'\[SUGGESTED_EXERCISE:\s*([a-zA-Z_]+)\]',
    caseSensitive: false,
  );

  /// Build the system prompt with personality and session context.
  String _buildSystemPrompt({
    String? personalityTag,
    String? sessionSummary,
  }) {
    return '''
You are NOVA, a warm, calm, and supportive AI companion for PeaceMind AI. You are a **warm friend**, not a therapist. Your tone is gentle, caring, and conversational. You use emojis sparingly and only when natural.

**Your style:**
- Validate the user's feelings with **one short, genuine sentence**.
- Ask thoughtful questions to get to know the user (especially in first conversations).
- Keep replies warm, simple, and human-like.
- Adapt slightly to the user's personality (only subtle differences).

**Exercises you can suggest:**
If the user's distress level is above 0.7, suggest ONE of these exercises at the end of your reply:
- `box_breathing` – for anxiety, panic, racing heart
- `grounding` – for racing thoughts, overthinking
- `mindful_walking` – for restlessness, feeling stuck
- `body_scan` – for feeling disconnected, numbness
- `journaling` – for processing thoughts and feelings

**Important format rules:**
1. At the very end of your reply, add `[DISTRESS_SCORE: X.X]` (0.0 to 1.0) based on the user's emotional state.
2. If distress > 0.7, also add `[SUGGESTED_EXERCISE: exercise_id]` immediately after the distress score.
3. Example: "... I'm here for you. [DISTRESS_SCORE: 0.8] [SUGGESTED_EXERCISE: box_breathing]"
4. Do not include any text after these tags.
''';
  }

  /// Send a message to the AI and get a reply with distress score and optional exercise suggestion.
  Future<AiResponse> sendMessage({
    required String userMessage,
    required List<Map<String, String>> conversationHistory,
    String? personalityTag,
    String? sessionSummary,
  }) async {
    final messages = <Map<String, String>>[
      {
        'role': 'system',
        'content': _buildSystemPrompt(
          personalityTag: personalityTag,
          sessionSummary: sessionSummary,
        ),
      },
    ];

    for (final msg in conversationHistory) {
      final role = msg['sender'] == 'user' ? 'user' : 'assistant';
      messages.add({'role': role, 'content': msg['text'] ?? ''});
    }

    messages.add({'role': 'user', 'content': userMessage});

    final requestBody = {
      'model': 'qwen/qwen-plus',
      'messages': messages,
      'temperature': 0.7,
      'max_tokens': 800,
      'top_p': 0.9,
    };

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_apiKey}',
          'HTTP-Referer': 'https://peacemind.ai',
          'X-Title': 'PeaceMind AI',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception('API Error: ${errorData['error']?['message'] ?? response.body}');
      }

      final data = jsonDecode(response.body);
      String reply = data['choices']?[0]?['message']?['content'] ?? '';

      // Extract distress level
      double? distressLevel;
      final distressMatch = _distressRegex.firstMatch(reply);
      if (distressMatch != null) {
        distressLevel = double.tryParse(distressMatch.group(1)!);
        reply = reply.replaceAll(_distressRegex, '').trim();
      }

      // Extract suggested exercise
      String? suggestedExercise;
      final exerciseMatch = _exerciseRegex.firstMatch(reply);
      if (exerciseMatch != null) {
        suggestedExercise = exerciseMatch.group(1);
        reply = reply.replaceAll(_exerciseRegex, '').trim();
        dev.log('🏋️ AI Suggested Exercise: $suggestedExercise');
      }

      dev.log('📊 Distress Level: $distressLevel');
      return AiResponse(
        reply: reply,
        distressLevel: distressLevel,
        suggestedExercise: suggestedExercise,
      );
    } catch (e) {
      dev.log('❌ API Error: $e');
      rethrow;
    }
  }

  /// Generate a rich session summary from the conversation history.
  Future<Map<String, dynamic>> generateSessionSummary({
    required List<Map<String, String>> conversationHistory,
    required String? personalityTag,
  }) async {
    if (conversationHistory.isEmpty) {
      return {
        'topicsDiscussed': ['General conversation'],
        'techniquesUsed': [],
        'keyInsights': 'The user engaged in a supportive conversation.',
        'personalityTag': personalityTag ?? 'General',
      };
    }

    final historyText = conversationHistory.map((msg) {
      return '${msg['sender']}: ${msg['text']}';
    }).join('\n');

    final prompt = '''
You are the summarization engine for PeaceMind AI. Analyze the following conversation and generate a structured summary.

Conversation:
${historyText}

Return ONLY a valid JSON object with these EXACT keys:
{
  "topics": ["topic1", "topic2"],
  "techniques": ["technique1", "technique2"],
  "insight": "A one-sentence, meaningful insight about the user's emotional state or progress.",
  "personality": "Anxious/Overthinker | Highly Analytical/Logical | Perfectionist | General"
}

Do not include any other text, markdown, or explanation outside the JSON object.
''';

    final messages = [
      {'role': 'system', 'content': 'You are a structured data extractor. Only return valid JSON.'},
      {'role': 'user', 'content': prompt},
    ];

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_apiKey}',
          'HTTP-Referer': 'https://peacemind.ai',
          'X-Title': 'PeaceMind AI',
        },
        body: jsonEncode({
          'model': 'qwen/qwen-plus',
          'messages': messages,
          'temperature': 0.3,
          'max_tokens': 300,
          'top_p': 0.9,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('Summary API Error: ${response.body}');
      }

      final data = jsonDecode(response.body);
      final content = data['choices']?[0]?['message']?['content'] ?? '{}';

      // Safely parse JSON (handle code blocks if any)
      String jsonString = content;
      final codeBlockMatch = RegExp(r'```json\s*({.*?})\s*```', dotAll: true).firstMatch(content);
      if (codeBlockMatch != null) {
        jsonString = codeBlockMatch.group(1)!;
      }

      final summaryData = jsonDecode(jsonString) as Map<String, dynamic>;

      return {
        'topicsDiscussed': List<String>.from(summaryData['topics'] ?? ['General conversation']),
        'techniquesUsed': List<String>.from(summaryData['techniques'] ?? []),
        'keyInsights': summaryData['insight'] ?? 'The user engaged in a supportive conversation.',
        'personalityTag': summaryData['personality'] ?? personalityTag ?? 'General',
      };
    } catch (e) {
      dev.log('❌ Summary generation error: $e');
      // Fallback summary
      return {
        'topicsDiscussed': ['General conversation'],
        'techniquesUsed': [],
        'keyInsights': 'The user engaged in a supportive conversation.',
        'personalityTag': personalityTag ?? 'General',
      };
    }
  }
}