import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/features/skills/domain/usecases/clone_skill_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/create_skill_offer_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/delete_skill_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/fetch_user_skills_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/update_skill_usecase.dart';
import 'package:myapp/features/skills/presentation/bloc/skill_event.dart';
import 'package:myapp/features/skills/presentation/bloc/skill_state.dart';

class SkillBloc extends Bloc<SkillEvent, SkillState> {
  final CreateSkillOfferUseCase createSkillOfferUseCase;
  final UpdateSkillUseCase updateSkillUseCase;
  final DeleteSkillUseCase deleteSkillUseCase;
  final FetchUserSkillsUseCase fetchUserSkillsUseCase;
  final CloneSkillUseCase cloneSkillUseCase;

  SkillBloc({
    required this.createSkillOfferUseCase,
    required this.updateSkillUseCase,
    required this.deleteSkillUseCase,
    required this.fetchUserSkillsUseCase,
    required this.cloneSkillUseCase,
  }) : super(SkillInitial()) {
    on<CreateSkillOfferRequested>(_onCreateSkillOfferRequested);
    on<UpdateSkillRequested>(_onUpdateSkillRequested);
    on<DeleteSkillRequested>(_onDeleteSkillRequested);
    on<FetchUserSkillsRequested>(_onFetchUserSkillsRequested);
    on<CloneSkillRequested>(_onCloneSkillRequested);
  }

  Future _onCreateSkillOfferRequested(
    CreateSkillOfferRequested event,
    Emitter<SkillState> emit,
  ) async {
    emit(SkillLoading());
    final result = await createSkillOfferUseCase(
      CreateSkillOfferParams(
        title: event.title,
        description: event.description,
        category: event.category,
        type: event.type,
        level: event.level,
        format: event.format,
        tags: event.tags,
      ),
    );

    await result.fold(
      (left) async {
        emit(SkillError(message: 'Failed to create skill offer'));
      },
      (right) async {
        emit(SkillOfferCreated(skill: right));
      },
    );
  }

  Future _onUpdateSkillRequested(
    UpdateSkillRequested event,
    Emitter<SkillState> emit,
  ) async {
    emit(SkillLoading());
    final result = await updateSkillUseCase(
      UpdateSkillParams(
        id: event.id,
        title: event.title,
        description: event.description,
        category: event.category,
        type: event.type,
        level: event.level,
        format: event.format,
        tags: event.tags,
      ),
    );

    await result.fold(
      (left) async {
        emit(SkillError(message: 'Failed to update skill'));
      },
      (right) async {
        emit(SkillUpdated(skill: right));
      },
    );
  }

  Future _onDeleteSkillRequested(
    DeleteSkillRequested event,
    Emitter<SkillState> emit,
  ) async {
    emit(SkillLoading());
    final result = await deleteSkillUseCase(
      DeleteSkillParams(id: event.id),
    );

    await result.fold(
      (left) async {
        emit(SkillError(message: 'Failed to delete skill'));
      },
      (right) async {
        emit(SkillDeleted(id: event.id));
      },
    );
  }

  Future _onFetchUserSkillsRequested(
    FetchUserSkillsRequested event,
    Emitter<SkillState> emit,
  ) async {
    emit(SkillLoading());
    final result = await fetchUserSkillsUseCase(
      FetchUserSkillsParams(uid: event.uid),
    );

    await result.fold(
      (left) async {
        emit(SkillError(message: 'Failed to fetch skills'));
      },
      (right) async {
        emit(UserSkillsFetched(skills: right));
      },
    );
  }

  Future _onCloneSkillRequested(
    CloneSkillRequested event,
    Emitter<SkillState> emit,
  ) async {
    emit(SkillLoading());
    final result = await cloneSkillUseCase(
      CloneSkillParams(skillId: event.skillId),
    );

    await result.fold(
      (left) async {
        emit(SkillError(message: 'Failed to clone skill'));
      },
      (right) async {
        emit(SkillCloned(skill: right));
      },
    );
  }
}
