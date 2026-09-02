import 'package:cloud_firestore/cloud_firestore.dart';

enum AudioCallState {
  idle,
  connecting,
  listening,
  processing,
  novaSpeaking,
  paused,
  error,
  ending,
  ended,
}

class AudioCallSessionModel {
  final String id;
  final String userId;
  final AudioCallState state;
  final String sessionSummary;
  final String lastTranscript;
  final String lastNovaResponse;
  final int messageCount;
  final bool panicFlag;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AudioCallSessionModel({
    required this.id,
    required this.userId,
    this.state = AudioCallState.idle,
    this.sessionSummary = '',
    this.lastTranscript = '',
    this.lastNovaResponse = '',
    this.messageCount = 0,
    this.panicFlag = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'state': state.name,
      'sessionSummary': sessionSummary,
      'lastTranscript': lastTranscript,
      'lastNovaResponse': lastNovaResponse,
      'messageCount': messageCount,
      'panicFlag': panicFlag,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory AudioCallSessionModel.fromJson(Map<String, dynamic> json, String id) {
    return AudioCallSessionModel(
      id: id,
      userId: (json['userId'] ?? '').toString(),
      state: _stateFromString(json['state'] ?? 'idle'),
      sessionSummary: (json['sessionSummary'] ?? '').toString(),
      lastTranscript: (json['lastTranscript'] ?? '').toString(),
      lastNovaResponse: (json['lastNovaResponse'] ?? '').toString(),
      messageCount: (json['messageCount'] is int)
          ? json['messageCount'] as int
          : int.tryParse('${json['messageCount']}') ?? 0,
      panicFlag: json['panicFlag'] == true,
      createdAt: _toDateTime(json['createdAt']),
      updatedAt: _toDateTime(json['updatedAt']),
    );
  }

  AudioCallSessionModel copyWith({
    String? id,
    String? userId,
    AudioCallState? state,
    String? sessionSummary,
    String? lastTranscript,
    String? lastNovaResponse,
    int? messageCount,
    bool? panicFlag,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AudioCallSessionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      state: state ?? this.state,
      sessionSummary: sessionSummary ?? this.sessionSummary,
      lastTranscript: lastTranscript ?? this.lastTranscript,
      lastNovaResponse: lastNovaResponse ?? this.lastNovaResponse,
      messageCount: messageCount ?? this.messageCount,
      panicFlag: panicFlag ?? this.panicFlag,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static AudioCallState _stateFromString(String value) {
    for (final state in AudioCallState.values) {
      if (state.name == value) {
        return state;
      }
    }
    return AudioCallState.idle;
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return DateTime.now();
  }
}
