import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/features/progress/domain/usecases/fetch_goals_usecase.dart';
import 'package:myapp/features/progress/domain/usecases/fetch_progress_usecase.dart';
import 'package:myapp/features/progress/domain/usecases/set_goal_usecase.dart';
import 'package:myapp/features/progress/domain/usecases/share_achievement_usecase.dart';
import 'package:myapp/features/progress/domain/usecases/track_progress_usecase.dart';
import 'package:myapp/features/progress/domain/usecases/update_goal_progress_usecase.dart';
import 'package:myapp/features/progress/presentation/bloc/progress_event.dart';
import 'package:myapp/features/progress/presentation/bloc/progress_state.dart';

class ProgressBloc extends Bloc<ProgressEvent, ProgressState> {
  final TrackProgressUseCase trackProgressUseCase;
  final FetchProgressUseCase fetchProgressUseCase;
  final SetGoalUseCase setGoalUseCase;
  final FetchGoalsUseCase fetchGoalsUseCase;
  final UpdateGoalProgressUseCase updateGoalProgressUseCase;
  final ShareAchievementUseCase shareAchievementUseCase;

  ProgressBloc({
    required this.trackProgressUseCase,
    required this.fetchProgressUseCase,
    required this.setGoalUseCase,
    required this.fetchGoalsUseCase,
    required this.updateGoalProgressUseCase,
    required this.shareAchievementUseCase,
  }) : super(ProgressInitial()) {
    on<FetchProgressRequested>(_onFetchProgress);
    on<TrackProgressRequested>(_onTrackProgress);
    on<FetchGoalsRequested>(_onFetchGoals);
    on<SetGoalRequested>(_onSetGoal);
    on<UpdateGoalProgressRequested>(_onUpdateGoalProgress);
    on<ShareAchievementRequested>(_onShareAchievement);
  }

  Future<void> _onFetchProgress(
    FetchProgressRequested event,
    Emitter<ProgressState> emit,
  ) async {
    emit(ProgressLoading());
    final result =
        await fetchProgressUseCase(FetchProgressParams(userId: event.userId));
    await result.fold(
      (left) async =>
          emit(ProgressError(message: 'Failed to load progress')),
      (right) async => emit(ProgressLoaded(progressList: right)),
    );
  }

  Future<void> _onTrackProgress(
    TrackProgressRequested event,
    Emitter<ProgressState> emit,
  ) async {
    emit(ProgressLoading());
    final result = await trackProgressUseCase(TrackProgressParams(
      userId: event.userId,
      skillId: event.skillId,
      skillTitle: event.skillTitle,
      hoursLogged: event.hoursLogged,
      sessionsCompleted: event.sessionsCompleted,
      xpGained: event.xpGained,
    ));
    await result.fold(
      (left) async =>
          emit(ProgressError(message: 'Failed to track progress')),
      (right) async => emit(ProgressTracked()),
    );
  }

  Future<void> _onFetchGoals(
    FetchGoalsRequested event,
    Emitter<ProgressState> emit,
  ) async {
    emit(ProgressLoading());
    final result =
        await fetchGoalsUseCase(FetchGoalsParams(userId: event.userId));
    await result.fold(
      (left) async => emit(ProgressError(message: 'Failed to load goals')),
      (right) async => emit(GoalsLoaded(goals: right)),
    );
  }

  Future<void> _onSetGoal(
    SetGoalRequested event,
    Emitter<ProgressState> emit,
  ) async {
    emit(ProgressLoading());
    final result =
        await setGoalUseCase(SetGoalParams(goal: event.goal));
    await result.fold(
      (left) async => emit(ProgressError(message: 'Failed to set goal')),
      (right) async => emit(GoalSet()),
    );
  }

  Future<void> _onUpdateGoalProgress(
    UpdateGoalProgressRequested event,
    Emitter<ProgressState> emit,
  ) async {
    emit(ProgressLoading());
    final result = await updateGoalProgressUseCase(
      UpdateGoalProgressParams(
        goalId: event.goalId,
        progressPercent: event.progressPercent,
      ),
    );
    await result.fold(
      (left) async =>
          emit(ProgressError(message: 'Failed to update goal progress')),
      (right) async => emit(GoalProgressUpdated()),
    );
  }

  Future<void> _onShareAchievement(
    ShareAchievementRequested event,
    Emitter<ProgressState> emit,
  ) async {
    emit(ProgressLoading());
    final result = await shareAchievementUseCase(
      ShareAchievementParams(
        progressId: event.progressId,
        milestone: event.milestone,
      ),
    );
    await result.fold(
      (left) async =>
          emit(ProgressError(message: 'Failed to share achievement')),
      (right) async => emit(AchievementShared()),
    );
  }
}
