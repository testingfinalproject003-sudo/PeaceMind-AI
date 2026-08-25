class UserModel {
  final String uid;
  final String name;
  final String email;
  final String mood;
  final int routineCount;
  final int taskCount;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.mood = '🙂',
    this.routineCount = 0,
    this.taskCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'mood': mood,
      'routineCount': routineCount,
      'taskCount': taskCount,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: (json['uid'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      mood: (json['mood'] ?? '🙂').toString(),
      routineCount: (json['routineCount'] is int)
          ? json['routineCount'] as int
          : int.tryParse('${json['routineCount']}') ?? 0,
      taskCount: (json['taskCount'] is int)
          ? json['taskCount'] as int
          : int.tryParse('${json['taskCount']}') ?? 0,
    );
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? mood,
    int? routineCount,
    int? taskCount,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      mood: mood ?? this.mood,
      routineCount: routineCount ?? this.routineCount,
      taskCount: taskCount ?? this.taskCount,
    );
  }
}