class Rating {
  final String id;
  final String sessionId;
  final String fromUid;
  final String toUid;
  final double score; // 1-5
  final String comment;
  final DateTime createdAt;

  Rating({
    required this.id,
    required this.sessionId,
    required this.fromUid,
    required this.toUid,
    required this.score,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'fromUid': fromUid,
      'toUid': toUid,
      'score': score,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      fromUid: json['fromUid'] as String,
      toUid: json['toUid'] as String,
      score: (json['score'] as num).toDouble(),
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
