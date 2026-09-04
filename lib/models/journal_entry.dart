/// Ek journal entry — positive / challenge / let-go reflection.
class JournalEntry {
  final String id;
  final DateTime createdAt;
  final String positive;
  final String negative;
  final String letGo;
  final String mood;

  const JournalEntry({
    required this.id,
    required this.createdAt,
    required this.positive,
    required this.negative,
    required this.letGo,
    required this.mood,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'positive': positive,
        'negative': negative,
        'letGo': letGo,
        'mood': mood,
        'createdAt': createdAt.toIso8601String(),
      };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
        id: json['id'] as String,
        positive: json['positive'] as String? ?? '',
        negative: json['negative'] as String? ?? '',
        letGo: json['letGo'] as String? ?? '',
        mood: json['mood'] as String? ?? '🙂',
        createdAt:
            DateTime.tryParse(json['createdAt'] as String? ?? '') ??
                DateTime.now(),
      );

  static JournalEntry? fromFirestore(Map<String, dynamic> data) {
    try {
      return JournalEntry.fromJson(data);
    } catch (_) {
      return null;
    }
  }
}
