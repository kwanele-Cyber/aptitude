class MatchFeedback {
  final String id;
  final String fromUid;
  final String toUid;
  final int rating;
  final String? note;
  final DateTime createdAt;

  MatchFeedback({
    required this.id,
    required this.fromUid,
    required this.toUid,
    required this.rating,
    this.note,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'fromUid': fromUid,
        'toUid': toUid,
        'rating': rating,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
      };

  factory MatchFeedback.fromJson(Map<String, dynamic> json) => MatchFeedback(
        id: json['id'] as String,
        fromUid: json['fromUid'] as String,
        toUid: json['toUid'] as String,
        rating: (json['rating'] as num?)?.toInt() ?? 0,
        note: json['note'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
      );
}
