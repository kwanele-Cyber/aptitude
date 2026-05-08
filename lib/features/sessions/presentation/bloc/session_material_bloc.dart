import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/features/sessions/domain/usecases/delete_material_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/get_session_materials_usecase.dart';
import 'package:myapp/features/sessions/domain/usecases/upload_material_usecase.dart';
import 'package:myapp/features/sessions/presentation/bloc/session_material_event.dart';
import 'package:myapp/features/sessions/presentation/bloc/session_material_state.dart';

class SessionMaterialBloc
    extends Bloc<SessionMaterialEvent, SessionMaterialState> {
  final UploadMaterialUseCase uploadMaterialUseCase;
  final DeleteMaterialUseCase deleteMaterialUseCase;
  final GetSessionMaterialsUseCase getSessionMaterialsUseCase;

  SessionMaterialBloc({
    required this.uploadMaterialUseCase,
    required this.deleteMaterialUseCase,
    required this.getSessionMaterialsUseCase,
  }) : super(SessionMaterialInitial()) {
    on<LoadSessionMaterialsRequested>(_onLoadSessionMaterialsRequested);
    on<UploadMaterialRequested>(_onUploadMaterialRequested);
    on<DeleteMaterialRequested>(_onDeleteMaterialRequested);
  }

  Future _onLoadSessionMaterialsRequested(
    LoadSessionMaterialsRequested event,
    Emitter<SessionMaterialState> emit,
  ) async {
    emit(SessionMaterialLoading());
    final result = await getSessionMaterialsUseCase(
      GetSessionMaterialsParams(sessionId: event.sessionId),
    );

    await result.fold(
      (left) async => emit(
        SessionMaterialError(message: 'Failed to load materials'),
      ),
      (right) async => emit(SessionMaterialsLoaded(materials: right)),
    );
  }

  Future _onUploadMaterialRequested(
    UploadMaterialRequested event,
    Emitter<SessionMaterialState> emit,
  ) async {
    emit(SessionMaterialUploading());
    final result = await uploadMaterialUseCase(
      UploadMaterialParams(
        sessionId: event.sessionId,
        file: event.file,
        uploadedBy: event.uploadedBy,
      ),
    );

    await result.fold(
      (left) async => emit(
        SessionMaterialError(message: 'Failed to upload material'),
      ),
      (right) async {
        emit(SessionMaterialUploaded(material: right));
        // Reload the full list after upload
        final loadResult = await getSessionMaterialsUseCase(
          GetSessionMaterialsParams(sessionId: event.sessionId),
        );
        await loadResult.fold(
          (left) async => emit(
            SessionMaterialError(message: 'Failed to load materials'),
          ),
          (right) async => emit(SessionMaterialsLoaded(materials: right)),
        );
      },
    );
  }

  Future _onDeleteMaterialRequested(
    DeleteMaterialRequested event,
    Emitter<SessionMaterialState> emit,
  ) async {
    emit(SessionMaterialLoading());
    final result = await deleteMaterialUseCase(
      DeleteMaterialParams(
        materialId: event.materialId,
        sessionId: event.sessionId,
      ),
    );

    await result.fold(
      (left) async =>
          emit(SessionMaterialError(message: 'Failed to delete material')),
      (right) async {
        emit(SessionMaterialDeleted(materialId: event.materialId));
        // Reload the full list after deletion
        final loadResult = await getSessionMaterialsUseCase(
          GetSessionMaterialsParams(sessionId: event.sessionId),
        );
        await loadResult.fold(
          (left) async => emit(
            SessionMaterialError(message: 'Failed to load materials'),
          ),
          (right) async => emit(SessionMaterialsLoaded(materials: right)),
        );
      },
    );
  }
}
