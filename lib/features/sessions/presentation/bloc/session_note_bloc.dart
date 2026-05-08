import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/features/sessions/domain/entity/session_note_entity.dart';
import 'package:myapp/features/sessions/domain/repository/session_note_repository.dart';
import 'package:myapp/features/sessions/domain/usecases/get_session_notes_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/update_session_notes_usecase.dart';
import 'package:myapp/features/sessions/presentation/bloc/session_note_event.dart';
import 'package:myapp/features/sessions/presentation/bloc/session_note_state.dart';

class SessionNoteBloc extends Bloc<SessionNoteEvent, SessionNoteState> {
  final GetSessionNotesUseCase getSessionNotesUseCase;
  final UpdateSessionNotesUseCase updateSessionNotesUseCase;
  final SessionNoteRepository sessionNoteRepository;

  StreamSubscription<SessionNoteEntity>? _notesSubscription;

  SessionNoteBloc({
    required this.getSessionNotesUseCase,
    required this.updateSessionNotesUseCase,
    required this.sessionNoteRepository,
  }) : super(SessionNoteInitial()) {
    on<LoadSessionNotesRequested>(_onLoadSessionNotesRequested);
    on<UpdateSessionNotesRequested>(_onUpdateSessionNotesRequested);
    on<NotesSubscriptionRequested>(_onNotesSubscriptionRequested);
    on<NotesSubscriptionCancelled>(_onNotesSubscriptionCancelled);
    on<NotesRealtimeUpdateReceived>(_onNotesRealtimeUpdateReceived);
  }

  @override
  Future<void> close() {
    _notesSubscription?.cancel();
    return super.close();
  }

  Future _onLoadSessionNotesRequested(
    LoadSessionNotesRequested event,
    Emitter<SessionNoteState> emit,
  ) async {
    emit(SessionNoteLoading());
    final result = await getSessionNotesUseCase(
      GetSessionNotesParams(sessionId: event.sessionId),
    );

    await result.fold(
      (left) async =>
          emit(SessionNoteError(message: 'Failed to load notes')),
      (right) async => emit(SessionNotesLoaded(notes: right)),
    );
  }

  Future _onUpdateSessionNotesRequested(
    UpdateSessionNotesRequested event,
    Emitter<SessionNoteState> emit,
  ) async {
    final result = await updateSessionNotesUseCase(
      UpdateSessionNotesParams(
        sessionId: event.sessionId,
        content: event.content,
        updatedBy: event.updatedBy,
      ),
    );

    await result.fold(
      (left) async =>
          emit(SessionNoteError(message: 'Failed to update notes')),
      (right) async => emit(SessionNotesUpdated(notes: right)),
    );
  }

  void _onNotesSubscriptionRequested(
    NotesSubscriptionRequested event,
    Emitter<SessionNoteState> emit,
  ) {
    _notesSubscription?.cancel();
    _notesSubscription =
        sessionNoteRepository.watchSessionNotes(event.sessionId).listen(
      (notes) {
        if (isClosed) return;
        add(NotesRealtimeUpdateReceived(
          sessionId: notes.sessionId,
          content: notes.content,
          updatedBy: notes.updatedBy,
          updatedAt: notes.updatedAt,
        ));
      },
      onError: (error) {
        if (isClosed) return;
        add(LoadSessionNotesRequested(sessionId: event.sessionId));
      },
    );
  }

  void _onNotesSubscriptionCancelled(
    NotesSubscriptionCancelled event,
    Emitter<SessionNoteState> emit,
  ) {
    _notesSubscription?.cancel();
    _notesSubscription = null;
  }

  void _onNotesRealtimeUpdateReceived(
    NotesRealtimeUpdateReceived event,
    Emitter<SessionNoteState> emit,
  ) {
    emit(SessionNotesLoaded(
      notes: SessionNoteEntity(
        sessionId: event.sessionId,
        content: event.content,
        updatedBy: event.updatedBy,
        updatedAt: event.updatedAt,
      ),
    ));
  }
}
