class SessionNote {
  final String id;
  final String sessionId;
  final String content;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isPinned;

  SessionNote({
    required this.id,
    required this.sessionId,
    required this.content,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.isPinned = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'content': content,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isPinned': isPinned,
    };
  }

  factory SessionNote.fromJson(Map<String, dynamic> json) {
    return SessionNote(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      content: json['content'] as String,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isPinned: json['isPinned'] as bool? ?? false,
    );
  }

  SessionNote copyWith({
    String? content,
    DateTime? updatedAt,
    bool? isPinned,
  }) {
    return SessionNote(
      id: id,
      sessionId: sessionId,
      content: content ?? this.content,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}
