import 'package:equatable/equatable.dart';

class SessionNoteEntity extends Equatable {
  final String sessionId;
  final String content;
  final String updatedBy;
  final DateTime updatedAt;

  const SessionNoteEntity({
    required this.sessionId,
    required this.content,
    required this.updatedBy,
    required this.updatedAt,
  });

  SessionNoteEntity copyWith({
    String? sessionId,
    String? content,
    String? updatedBy,
    DateTime? updatedAt,
  }) {
    return SessionNoteEntity(
      sessionId: sessionId ?? this.sessionId,
      content: content ?? this.content,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [sessionId, content, updatedBy, updatedAt];
}
