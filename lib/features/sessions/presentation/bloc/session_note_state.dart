import 'package:equatable/equatable.dart';
import 'package:myapp/features/sessions/domain/entity/session_note_entity.dart';

abstract class SessionNoteState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SessionNoteInitial extends SessionNoteState {}

class SessionNoteLoading extends SessionNoteState {}

class SessionNotesLoaded extends SessionNoteState {
  final SessionNoteEntity notes;

  SessionNotesLoaded({required this.notes});

  @override
  List<Object?> get props => [notes];
}

class SessionNotesUpdated extends SessionNoteState {
  final SessionNoteEntity notes;

  SessionNotesUpdated({required this.notes});

  @override
  List<Object?> get props => [notes];
}

class SessionNoteError extends SessionNoteState {
  final String message;

  SessionNoteError({required this.message});

  @override
  List<Object?> get props => [message];
}
