import 'dart:convert';

class HistoryEntry {
  final String id;
  final String routineId;
  final String routineTitle;
  final String category;
  final DateTime completedAt;
  final int moodScore;
  final String? notes;

  HistoryEntry({
    required this.id,
    required this.routineId,
    required this.routineTitle,
    required this.category,
    required this.completedAt,
    required this.moodScore,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'routineId': routineId,
    'routineTitle': routineTitle,
    'category': category,
    'completedAt': completedAt.toIso8601String(),
    'moodScore': moodScore,
    'notes': notes,
  };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
    id: json['id'],
    routineId: json['routineId'],
    routineTitle: json['routineTitle'],
    category: json['category'],
    completedAt: DateTime.parse(json['completedAt']),
    moodScore: json['moodScore'],
    notes: json['notes'],
  );

  static List<HistoryEntry> listFromJson(String str) => 
    List<HistoryEntry>.from(json.decode(str).map((x) => HistoryEntry.fromJson(x)));
  
  static String listToJson(List<HistoryEntry> list) => 
    json.encode(List<dynamic>.from(list.map((x) => x.toJson())));
}