import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/features/skills/domain/usecases/create_skill_offer_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/update_skill_usecase.dart';
import 'package:myapp/features/skills/presentation/bloc/skill_event.dart';
import 'package:myapp/features/skills/presentation/bloc/skill_state.dart';

class SkillBloc extends Bloc<SkillEvent, SkillState> {
  final CreateSkillOfferUseCase createSkillOfferUseCase;
  final UpdateSkillUseCase updateSkillUseCase;

  SkillBloc({
    required this.createSkillOfferUseCase,
    required this.updateSkillUseCase,
  }) : super(SkillInitial()) {
    on<CreateSkillOfferRequested>(_onCreateSkillOfferRequested);
    on<UpdateSkillRequested>(_onUpdateSkillRequested);
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
}
