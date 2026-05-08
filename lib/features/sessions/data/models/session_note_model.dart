import 'package:myapp/features/sessions/domain/entity/session_note_entity.dart';

class SessionNoteModel extends SessionNoteEntity {
  const SessionNoteModel({
    required super.sessionId,
    required super.content,
    required super.updatedBy,
    required super.updatedAt,
  });

  factory SessionNoteModel.fromJson(Map<String, dynamic> json) {
    return SessionNoteModel(
      sessionId: json['sessionId'] as String? ?? '',
      content: json['content'] as String? ?? '',
      updatedBy: json['updatedBy'] as String? ?? '',
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'content': content,
      'updatedBy': updatedBy,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
