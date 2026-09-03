// lib/services/api_chat_service.dart
import 'dart:convert';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'language_detection_service.dart';
import 'nova_text_sanitizer.dart';

/// Response from the AI containing the reply text, distress level, and optional exercise suggestion.
class AiResponse {
  final String reply;
  final double? distressLevel;
  final String? suggestedExercise; // e.g., 'box_breathing', 'grounding', etc.
  final bool speak; // [SPEAK:true] → Urdu reply, auto-trigger TTS

  AiResponse({
    required this.reply,
    this.distressLevel,
    this.suggestedExercise,
    this.speak = false,
  });
}

/// Service responsible for communicating with OpenRouter API.
/// Handles chat messages, distress scoring, exercise suggestions, and session summaries.
class ApiChatService {
  static const String _baseUrl =
      'https://openrouter.ai/api/v1/chat/completions';

  /// Whether the API key is configured — callers can skip optional AI
  /// calls (e.g. audio session summaries) instead of burning a fallback.
  bool get isConfigured {
    final key = dotenv.env['OPENROUTER_API_KEY'];
    return key != null && key.isNotEmpty;
  }

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

  // Regular expression to extract the [SPEAK:true/false] voice tag.
  static final RegExp _speakRegex = RegExp(
    r'\[SPEAK:\s*(true|false)\]',
    caseSensitive: false,
  );

  /// Build the system prompt with personality, profile and session memory.
  String _buildSystemPrompt({
    String? personalityTag,
    String? sessionSummary,
    String? userName,
  }) {
    final memory = (sessionSummary == null || sessionSummary.trim().isEmpty)
        ? 'New user. No prior sessions.'
        : sessionSummary.trim();

    final personalityLine =
        (personalityTag == null || personalityTag.trim().isEmpty)
        ? ''
        : '\nUser personality pattern (adapt subtly, never mention it): $personalityTag';

    return '''
You are NOVA, a warm and emotionally intelligent companion in the PeaceMind AI app.

You are having a real conversation with a person. Sound human, calm and respectful. Never sound like a clinical interview, a chatbot, or a scripted questionnaire.

## LANGUAGE
Detect the language of EVERY user message:
- Urdu script characters (ا ب پ ت ٹ ث ج چ ح خ د ڈ ذ ر ڑ ز ژ س ش ص ض ط ظ ع غ ف ق ک گ ل م ن ں و ہ ھ ء ی ے) → Urdu.
- Roman Urdu (e.g. "aap kaise hain") is NOT Urdu script → treat as English.
- Mixed Urdu script + English → treat as Urdu.

WHEN URDU SCRIPT DETECTED:
- Reply in natural, simple Urdu script only.
- Keep the reply short: 1 to 3 sentences max.
- No bullet points, no formatting, no markdown.
- Use "آپ" for respect.
- End your reply with: [SPEAK:true]

WHEN ENGLISH OR ROMAN URDU:
- Reply normally in English.
- End your reply with: [SPEAK:false]

STRICT LANGUAGE RULES:
- NEVER mix languages in one reply.
- NEVER use markdown formatting in Urdu replies.
- NEVER use Hindi/Devanagari script.

## USER PROFILE
The user's profile name is: ${userName ?? 'not known'}
Use the name naturally, but never repeat it in every reply.
If the name or age is already known (profile or memory below), never ask for it again.
If age is not known and it becomes naturally relevant, ask casually — never like a form.

## CONVERSATION STYLE
- Warm and emotionally present, not overly casual and not overly formal.
- Never use "yaar", "darling", "jaan", insults, bad words, or romantic language.
- Never embarrass, shame, blame, criticize, or judge the user. Never make fun of their situation.
- Never force positivity, never pretend everything is fine, never give fake reassurance.
- Keep replies SHORT: usually 1-2 short sentences. Sometimes just a few words is best. Never long paragraphs, never multiple pieces of advice at once.
- Maximum ONE question per reply, and only when it truly helps. Not every reply needs a question.
- NEVER use emojis, emoticons (like :) or <3), symbols, or decorative characters — your words are shown as plain text and spoken aloud.

## FOLLOW THE USER
- React to what the user actually said FIRST, then let the conversation flow.
- Follow their topic wherever it goes — food, studies, family, a friend, a feeling. Never force your own previous question back on them.
- Let one topic lead naturally into a related one (food → lifestyle, studies → routine → sleep → mood, friend → feelings → support). Never jump abruptly to unrelated questions.
- If they say "kuch nahi" or "I'm fine", do not pressure them. Respond warmly and leave the door open.

## EMOTIONAL SUPPORT
- When something emotional comes up, acknowledge the feeling FIRST in one short line ("Samajh aa raha hai", "Ye hurtful raha hoga") before anything else.
- If someone ignores or hurts them, offer a short supportive perspective ("Kisi ka ignore karna tumhari worth decide nahi karta") — never insult the other person, never lecture.
- Occasionally, when it genuinely fits the moment (late night, skipped meals, tired, overwhelmed), add one small self-care nudge: water, food, sleep, a break, or journaling. Never stack reminders, never force them.

## CLOSING A SESSION
- When the user is clearly leaving, close in ONE short warm line ("Aaj ke liye itna hi. Apna khayal rakhna."). If journaling or a pending task fits, mention just that one thing. No long goodbyes.

## FIRST SESSIONS — GETTING TO KNOW THE USER
Gradually learn through normal conversation: age/life stage, studies or work, family/relationships, hobbies, routine, stress, emotions, goals.
Do NOT ask these one after another — the conversation must never feel like a questionnaire.
If the user opens a topic, follow that topic instead of asking unrelated personal questions.
If the user does not want to answer something, respect it and continue normally.
If they say "nothing" or "I'm fine", give them space; if deeper things surface later, explore gently.

## UNDERSTANDING THE REAL PROBLEM
Never assume or diagnose. Listen for: overthinking, anxiety/stress, low mood, self-doubt, relationship problems, academic/work pressure, loneliness, sleep/routine problems, grief or difficult experiences.
Build the understanding gradually from repeated thoughts, emotional words, worries, and what they avoid.
Never reveal an internal classification, issue detection, or distress score to the user.

## HELP APPROACH
Your goal is not to solve everything in one conversation. Follow: listen → understand → validate → explore → ONE small helpful step.
Validate the feeling before any advice. Do not give huge plans or overload the user with techniques.
Help them examine thoughts gently (realistic hope, not artificial positivity) and build on previous sessions gradually.

## TECHNIQUES (use naturally, never name or explain them)
Gentle thought reframing, separating facts from assumptions, spotting unhelpful thought patterns, focusing on what is controllable, breaking a problem into smaller steps, recalling the user's previous strengths.
If the user is not ready for a technique, simply listen and continue.

## MEMORY
Use the context below naturally. Never invent memories, never claim to remember something never shared, and never re-ask a question that is already answered.$personalityLine

Context from previous sessions:
$memory

## EXERCISES
Available: box_breathing (anxiety, panic, racing heart), grounding (racing thoughts, overthinking), mindful_walking (restlessness, feeling stuck), body_scan (feeling disconnected, numbness), journaling (processing thoughts and feelings).
Suggest one only when it genuinely fits the user's situation — never automatically just because distress is high. Offer it gently as a choice and accept a no.

## SAFETY
If the user expresses serious danger, self-harm, or suicidal thoughts: stay calm and non-judgmental, take it seriously, encourage immediate support from a trusted person and emergency/crisis services. Never shame or scare them.

## FORMAT RULES (hidden system tags — required)
1. At the very end of EVERY reply, add `[DISTRESS_SCORE: X.X]` (0.0 to 1.0) based on the user's emotional state.
2. Only when an exercise genuinely fits AND distress is above 0.7, also add `[SUGGESTED_EXERCISE: exercise_id]` immediately after the distress score.
3. ALWAYS end every reply with either `[SPEAK:true]` or `[SPEAK:false]` (after the distress score). NEVER skip this tag.
4. Example: "... I'm here with you. [DISTRESS_SCORE: 0.8] [SPEAK:false]"
5. Do not include any text after these tags, and never mention the tags, scores, or exercise ids in the visible part of the reply.
''';
  }

  /// Send a message to the AI and get a reply with distress score and optional exercise suggestion.
  Future<AiResponse> sendMessage({
    required String userMessage,
    required List<Map<String, String>> conversationHistory,
    String? personalityTag,
    String? sessionSummary,
    String? userName,
  }) async {
    final messages = <Map<String, String>>[
      {
        'role': 'system',
        'content': _buildSystemPrompt(
          personalityTag: personalityTag,
          sessionSummary: sessionSummary,
          userName: userName,
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
      'max_tokens': 400,
      'top_p': 0.9,
    };

    try {
      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
              'HTTP-Referer': 'https://peacemind.ai',
              'X-Title': 'PeaceMind AI',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(
          'API Error: ${errorData['error']?['message'] ?? response.body}',
        );
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

      // Extract the [SPEAK:true/false] voice tag. Fallback when the model
      // skipped the tag: Urdu-script user message implies speaking.
      bool speak = false;
      final speakMatch = _speakRegex.firstMatch(reply);
      if (speakMatch != null) {
        speak = speakMatch.group(1)!.toLowerCase() == 'true';
        reply = reply.replaceAll(_speakRegex, '').trim();
      } else {
        speak = const LanguageDetectionService().detect(userMessage) == 'ur';
      }
      dev.log('🔊 Speak tag: $speak');

      // Keep the reply plain and speakable — no emojis, markdown or
      // symbols may ever reach the chat bubble or the TTS engine.
      reply = NovaTextSanitizer.sanitize(reply);
      if (reply.isEmpty) {
        reply = "I'm here with you.";
      }

      dev.log('📊 Distress Level: $distressLevel');
      return AiResponse(
        reply: reply,
        distressLevel: distressLevel,
        suggestedExercise: suggestedExercise,
        speak: speak,
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

    final historyText = conversationHistory
        .map((msg) {
          return '${msg['sender']}: ${msg['text']}';
        })
        .join('\n');

    final prompt =
        '''
You are the memory engine for PeaceMind AI. Analyze the conversation and extract a structured summary.

Conversation:
$historyText

Return ONLY a valid JSON object with these EXACT keys:
{
  "topics": ["topic1", "topic2"],
  "techniques": ["technique1", "technique2"],
  "insight": "A one-sentence, meaningful insight about the user's emotional state or progress.",
  "personality": "Anxious/Overthinker | Highly Analytical/Logical | Perfectionist | General",
  "userFacts": ["short durable facts worth remembering: name, age/life stage, studies/work, interests, important relationships, recurring concerns, goals, what helped, what did not help — only facts explicitly stated, no guesses, max 8"],
  "corrections": ["existing facts that are now OUTDATED because the user changed or corrected them in this conversation — restate the OLD fact briefly as it was stored, empty array if none"],
  "progress": "One short sentence on progress made this session.",
  "unresolved": "One short sentence on unresolved concerns to follow up in future sessions.",
  "helped": "One short sentence on what genuinely helped the user."
}

Keep every field concise. Do not include any other text, markdown, or explanation outside the JSON object.
''';

    final messages = [
      {
        'role': 'system',
        'content':
            'You are a structured data extractor. Only return valid JSON.',
      },
      {'role': 'user', 'content': prompt},
    ];

    try {
      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
              'HTTP-Referer': 'https://peacemind.ai',
              'X-Title': 'PeaceMind AI',
            },
            body: jsonEncode({
              'model': 'qwen/qwen-plus',
              'messages': messages,
              'temperature': 0.3,
              'max_tokens': 350,
              'top_p': 0.9,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('Summary API Error: ${response.body}');
      }

      final data = jsonDecode(response.body);
      final content = data['choices']?[0]?['message']?['content'] ?? '{}';

      // Safely parse JSON (handle code blocks if any)
      String jsonString = content;
      final codeBlockMatch = RegExp(
        r'```json\s*({.*?})\s*```',
        dotAll: true,
      ).firstMatch(content);
      if (codeBlockMatch != null) {
        jsonString = codeBlockMatch.group(1)!;
      }

      final summaryData = jsonDecode(jsonString) as Map<String, dynamic>;

      final userFacts = List<String>.from(summaryData['userFacts'] ?? const [])
          .map((f) => f.toString().trim())
          .where((f) => f.isNotEmpty)
          .take(8)
          .toList();
      final corrections =
          List<String>.from(summaryData['corrections'] ?? const [])
              .map((f) => f.toString().trim())
              .where((f) => f.isNotEmpty)
              .take(8)
              .toList();

      // NOTE: 'userFacts' is only present on a successful AI extraction —
      // the fallback maps deliberately omit it so callers can tell them apart.
      return {
        'topicsDiscussed': List<String>.from(
          summaryData['topics'] ?? ['General conversation'],
        ),
        'techniquesUsed': List<String>.from(summaryData['techniques'] ?? []),
        'keyInsights':
            summaryData['insight'] ??
            'The user engaged in a supportive conversation.',
        'personalityTag':
            summaryData['personality'] ?? personalityTag ?? 'General',
        'userFacts': userFacts,
        'corrections': corrections,
        'progress': (summaryData['progress'] ?? '').toString(),
        'unresolved': (summaryData['unresolved'] ?? '').toString(),
        'helped': (summaryData['helped'] ?? '').toString(),
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
