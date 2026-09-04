// lib/services/nova_text_sanitizer.dart

/// Removes everything that cannot be spoken aloud naturally.
///
/// NOVA's replies must never contain emojis, emoticons, markdown or other
/// decorative characters: chat bubbles stay clean and TTS only ever
/// receives plain spoken words. The system prompts already forbid these —
/// this class is the code-level guarantee behind them, shared by the chat
/// pipeline (ApiChatService / AudioPlayerWidget) and the voice call
/// pipeline (AudioCallService / SpeechToTextService).
class NovaTextSanitizer {
  const NovaTextSanitizer._();

  /// Markdown links — only the visible label is speakable.
  static final RegExp _markdownLinkRegex = RegExp(r'\[([^\]]+)\]\([^)]*\)');

  /// Bare URLs — never speakable.
  static final RegExp _urlRegex = RegExp(r'https?://\S+');

  /// Line-level markdown: headings, blockquotes, bullets, numbered lists.
  static final RegExp _lineMarkdownRegex = RegExp(
    r'^[ \t]*(?:#{1,6}[ \t]+|>[ \t]?|[-*+][ \t]+|\d{1,2}[.)][ \t]+)',
    multiLine: true,
  );

  /// Text emoticons such as :) :D ;) :( :/ =) xD <3 ^_^ o.O
  /// The 8- and x-families keep their leading boundary character so
  /// normal text like "relax)", "0.8]" or "1998)" is never touched.
  static final RegExp _emoticonRegex = RegExp(
    r"(?:[:;=][\-'^oO*]?[\)\]\(\[dDpP/}{@|\\*]"
    r"|(^|\s)8[\-'^oO*]?[\)\]\(\[dDpP/}{@|\\*]"
    r"|(^|[^\w])[xX][\-']?[dDpP\)\]\(]"
    r"|</?3|\^_\^|o\.O|O\.o)",
  );

  /// The shrug kaomoji — removed as one token before its runes are filtered.
  static final RegExp _shrugRegex = RegExp(r'̄?\\?_?\(ツ\)_?/?̄?');

  /// Remaining markdown decoration characters.
  static final RegExp _markdownCharsRegex = RegExp(r'[*_~`|#]+');

  /// Returns [input] reduced to plain, speakable text.
  static String sanitize(String input) {
    if (input.isEmpty) return input;

    var text = input
        .replaceAllMapped(_markdownLinkRegex, (m) => m.group(1) ?? '')
        .replaceAll(_urlRegex, '')
        .replaceAll(_lineMarkdownRegex, '')
        .replaceAll(_shrugRegex, '')
        .replaceAllMapped(_emoticonRegex, (m) => m.group(1) ?? '');

    text = _stripUnspeakableRunes(text).replaceAll(_markdownCharsRegex, '');

    return _tidy(text);
  }

  /// Drops emoji / symbol / format runes that have no spoken form while
  /// keeping all real text (Urdu, Punjabi and Latin scripts included).
  static String _stripUnspeakableRunes(String text) {
    final buffer = StringBuffer();
    for (final rune in text.runes) {
      if (_isSpeakable(rune)) {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString();
  }

  static bool _isSpeakable(int rune) {
    // Strip control characters, keeping tab / newline / carriage return.
    if (rune < 0x20) {
      return rune == 0x09 || rune == 0x0A || rune == 0x0D;
    }
    if (rune == 0x7F) return false;

    switch (rune) {
      case 0xAD: // soft hyphen
      case 0xA9: // ©
      case 0xAE: // ®
      case 0xAF: // ¯ (shrug emoticon)
      case 0x2020: // †
      case 0x2021: // ‡
      case 0x203C: // ‼
      case 0x2044: // ⁄ fraction slash
      case 0x2049: // ⁉
      case 0x20E3: // combining enclosing keycap
      case 0x3030: // 〰 wavy dash
      case 0x303D: // 〽
      case 0x3297: // ㊗
      case 0x3299: // ㊙
      case 0xFEFF: // zero-width no-break space
      case 0xFFFD: // replacement character
        return false;
    }

    // Zero-width / format characters and directional marks.
    if (rune >= 0x200B && rune <= 0x200F) return false;
    if (rune >= 0x2028 && rune <= 0x202E) return false;
    if (rune >= 0x2050 && rune <= 0x205F) return false;
    if (rune >= 0x2060 && rune <= 0x2064) return false;

    // Letter-like symbols (™ ℹ …).
    if (rune >= 0x2100 && rune <= 0x214F) return false;

    // Arrows, math, technical, enclosed, box drawing, blocks, shapes,
    // misc symbols, dingbats, braille and stars — none are speakable.
    if (rune >= 0x2190 && rune <= 0x2BFF) return false;

    // Supplemental punctuation.
    if (rune >= 0x2E00 && rune <= 0x2E7F) return false;

    // Katakana / half-width katakana (shrug emoticon).
    if (rune >= 0x30A0 && rune <= 0x30FF) return false;
    if (rune >= 0xFF61 && rune <= 0xFF9F) return false;

    // Variation selectors and compatibility decorative forms.
    if (rune >= 0xFE00 && rune <= 0xFE4F) return false;

    // Interlinear annotation characters.
    if (rune >= 0xFFF9 && rune <= 0xFFFB) return false;

    // Private use area.
    if (rune >= 0xE000 && rune <= 0xF8FF) return false;

    // Emoji planes: pictographs, emoticons, transport, flags, supplemental.
    if (rune >= 0x1F000 && rune <= 0x1FBFF) return false;

    return true;
  }

  /// Collapses the whitespace artefacts left behind by removals.
  static String _tidy(String text) {
    final collapsed = text
        .replaceAll('\r\n', '\n')
        .replaceAll(RegExp(r'[ \t]{2,}'), ' ')
        .replaceAllMapped(RegExp(r'[ \t]+([,.!?;:])'), (m) => m[1]!)
        .replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return collapsed
        .split('\n')
        .map((line) => line.trim())
        .join('\n')
        .trim();
  }
}
