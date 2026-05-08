import 'package:equatable/equatable.dart';

abstract class SessionNoteEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadSessionNotesRequested extends SessionNoteEvent {
  final String sessionId;

  LoadSessionNotesRequested({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}

class UpdateSessionNotesRequested extends SessionNoteEvent {
  final String sessionId;
  final String content;
  final String updatedBy;

  UpdateSessionNotesRequested({
    required this.sessionId,
    required this.content,
    required this.updatedBy,
  });

  @override
  List<Object?> get props => [sessionId, content, updatedBy];
}

class NotesSubscriptionRequested extends SessionNoteEvent {
  final String sessionId;

  NotesSubscriptionRequested({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}

class NotesSubscriptionCancelled extends SessionNoteEvent {}

class NotesRealtimeUpdateReceived extends SessionNoteEvent {
  final String sessionId;
  final String content;
  final String updatedBy;
  final DateTime updatedAt;

  NotesRealtimeUpdateReceived({
    required this.sessionId,
    required this.content,
    required this.updatedBy,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [sessionId, content, updatedBy, updatedAt];
}
