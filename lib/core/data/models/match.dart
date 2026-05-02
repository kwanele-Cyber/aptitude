enum MatchStatus { pending, accepted, rejected, ignored, saved }

class Match {
  final String id;
  final List<String> participants;
  final MatchStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? lastActionBy;

  Match({
    required this.id,
    required this.participants,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.lastActionBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participants': participants,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastActionBy': lastActionBy,
    };
  }

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'] as String,
      participants: List<String>.from(json['participants'] ?? []),
      status: MatchStatus.values.firstWhere((e) => e.name == json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      lastActionBy: json['lastActionBy'] as String?,
    );
  }
}
