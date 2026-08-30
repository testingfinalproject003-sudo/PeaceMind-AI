import 'dart:convert';

class Routine {
  final String id;
  String title;
  String category;
  String time;
  List<bool> days;
  String? coverImage;
  bool isCompleted;
  DateTime? completedAt;
  int? moodScore;

  Routine({
    required this.id,
    required this.title,
    required this.category,
    required this.time,
    required this.days,
    this.coverImage,
    this.isCompleted = false,
    this.completedAt,
    this.moodScore,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'time': time,
        'days': days,
        'coverImage': coverImage,
        'isCompleted': isCompleted,
        'completedAt': completedAt?.toIso8601String(),
        'moodScore': moodScore,
      };

  factory Routine.fromJson(Map<String, dynamic> json) => Routine(
        id: json['id'],
        title: json['title'],
        category: json['category'],
        time: json['time'],
        days: List<bool>.from(json['days']),
        coverImage: json['coverImage'],
        isCompleted: json['isCompleted'] ?? false,
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'])
            : null,
        moodScore: json['moodScore'],
      );

  static String listToJson(List<Routine> routines) =>
      jsonEncode(routines.map((r) => r.toJson()).toList());

  static List<Routine> listFromJson(String jsonStr) {
    final list = jsonDecode(jsonStr) as List<dynamic>;
    return list.map((e) => Routine.fromJson(e as Map<String, dynamic>)).toList();
  }
}