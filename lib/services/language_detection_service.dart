/// Detects the user's language from their text input.
///
/// Supports Urdu, Punjabi, and English. Hindi is explicitly excluded —
/// if the text looks like Hindi (Devanagari), it falls back to English.
///
/// The same detection result drives:
///   • NOVA's reply language (chat + audio call system prompt)
///   • TTS locale selection for spoken responses
///   • STT locale hint for speech recognition
class LanguageDetectionService {
  const LanguageDetectionService();

  /// Returns one of 'ur', 'pa', 'en'.
  ///
  /// Detection heuristic:
  ///   • Arabic-script characters (Urdu)  → 'ur'
  ///   • Gurmukhi-script characters (Punjabi) → 'pa'
  ///   • Devanagari (Hindi) → 'en'  (Hindi is never used)
  ///   • Otherwise → 'en'
  String detect(String text) {
    final clean = text.trim();
    if (clean.isEmpty) return 'en';

    int arabicCount = 0;
    int gurmukhiCount = 0;
    int devanagariCount = 0;
    int latinCount = 0;

    for (final rune in clean.runes) {
      if (_isArabic(rune)) {
        arabicCount++;
      } else if (_isGurmukhi(rune)) {
        gurmukhiCount++;
      } else if (_isDevanagari(rune)) {
        devanagariCount++;
      } else if (_isLatin(rune)) {
        latinCount++;
      }
    }

    // Roman Urdu detection: Latin script but Urdu-specific keywords present
    if (latinCount > 0 && arabicCount == 0 && gurmukhiCount == 0) {
      if (_looksLikeRomanUrdu(clean)) return 'ur';
      return 'en';
    }

    // Urdu (Arabic script) — highest priority
    if (arabicCount > 0 && arabicCount >= gurmukhiCount) return 'ur';

    // Punjabi (Gurmukhi script)
    if (gurmukhiCount > 0) return 'pa';

    // Devanagari detected → treat as English (Hindi is never used)
    if (devanagariCount > 0) return 'en';

    return 'en';
  }

  /// BCP-47 locale tag for TTS, matching detected language.
  String ttsLocaleFor(String langCode) {
    switch (langCode) {
      case 'ur':
        return 'ur-PK';
      case 'pa':
        return 'pa-IN';
      default:
        return 'en-US';
    }
  }

  /// STT locale hint for speech recognition.
  String sttLocaleFor(String langCode) {
    switch (langCode) {
      case 'ur':
        return 'ur-PK';
      case 'pa':
        return 'pa-IN';
      default:
        return 'en-US';
    }
  }

  /// Language label for the NOVA system prompt.
  String promptLanguageName(String langCode) {
    switch (langCode) {
      case 'ur':
        return 'Urdu';
      case 'pa':
        return 'Punjabi';
      default:
        return 'English';
    }
  }

  // ── Unicode range checks ──

  bool _isArabic(int rune) =>
      (rune >= 0x0600 && rune <= 0x06FF) ||
      (rune >= 0x0750 && rune <= 0x077F) ||
      (rune >= 0xFB50 && rune <= 0xFDFF) ||
      (rune >= 0xFE70 && rune <= 0xFEFF);

  bool _isGurmukhi(int rune) => rune >= 0x0A00 && rune <= 0x0A7F;

  bool _isDevanagari(int rune) => rune >= 0x0900 && rune <= 0x097F;

  bool _isLatin(int rune) =>
      (rune >= 0x0041 && rune <= 0x005A) || // A-Z
      (rune >= 0x0061 && rune <= 0x007A);   // a-z

  /// Roman Urdu keyword heuristic — common Urdu words written in Latin script.
  bool _looksLikeRomanUrdu(String text) {
    final lower = text.toLowerCase();
    const romanUrduMarkers = {
      'kya', 'hai', 'hain', 'kaise', 'kaisa', 'kaisi',
      'mujhe', 'tum', 'aap', 'mein', 'hum', 'woh', 'yeh',
      'nahi', 'bhai', 'yaar', 'acha', 'theek', 'shukriya',
      'karo', 'raha', 'rahi', 'gaya', 'gayi', 'hua', 'hui',
      'hoon', 'hoga', 'hogi', 'kar', 'karke', 'ke', 'ki',
      'ko', 'se', 'par', 'pe', 'tak',
    };
    final words = lower.split(RegExp(r'\s+'));
    int matchCount = 0;
    for (final w in words) {
      if (romanUrduMarkers.contains(w.replaceAll(RegExp(r'[^a-z]'), ''))) {
        matchCount++;
      }
    }
    // If 20%+ of words are Roman Urdu markers, treat as Urdu
    return words.isNotEmpty && (matchCount / words.length) >= 0.20;
  }
}
