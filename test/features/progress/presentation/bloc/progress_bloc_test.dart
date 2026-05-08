import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/progress/domain/entity/learning_goal_entity.dart';
import 'package:myapp/features/progress/domain/entity/skill_progress_entity.dart';
import 'package:myapp/features/progress/domain/usecases/fetch_goals_usecase.dart';
import 'package:myapp/features/progress/domain/usecases/fetch_progress_usecase.dart';
import 'package:myapp/features/progress/domain/usecases/set_goal_usecase.dart';
import 'package:myapp/features/progress/domain/usecases/share_achievement_usecase.dart';
import 'package:myapp/features/progress/domain/usecases/track_progress_usecase.dart';
import 'package:myapp/features/progress/domain/usecases/update_goal_progress_usecase.dart';
import 'package:myapp/features/progress/presentation/bloc/progress_bloc.dart';
import 'package:myapp/features/progress/presentation/bloc/progress_event.dart';
import 'package:myapp/features/progress/presentation/bloc/progress_state.dart';
import 'package:bloc_test/bloc_test.dart';

class MockTrackProgressUseCase extends Mock
    implements TrackProgressUseCase {}

class MockFetchProgressUseCase extends Mock
    implements FetchProgressUseCase {}

class MockSetGoalUseCase extends Mock implements SetGoalUseCase {}

class MockFetchGoalsUseCase extends Mock implements FetchGoalsUseCase {}

class MockUpdateGoalProgressUseCase extends Mock
    implements UpdateGoalProgressUseCase {}

class MockShareAchievementUseCase extends Mock
    implements ShareAchievementUseCase {}

final tProgress = SkillProgressEntity(
  id: 'progress1',
  userId: 'user1',
  skillId: 'flutter',
  skillTitle: 'Flutter',
  xpPoints: 100,
  updatedAt: DateTime(2025, 1, 1),
);

final tGoal = LearningGoalEntity(
  id: 'goal1',
  userId: 'user1',
  skillId: 'flutter',
  skillTitle: 'Flutter',
  description: 'Build a Flutter app',
  createdAt: DateTime(2025, 1, 1),
);

void main() {
  late ProgressBloc bloc;
  late MockTrackProgressUseCase mockTrackUseCase;
  late MockFetchProgressUseCase mockFetchProgressUseCase;
  late MockSetGoalUseCase mockSetGoalUseCase;
  late MockFetchGoalsUseCase mockFetchGoalsUseCase;
  late MockUpdateGoalProgressUseCase mockUpdateGoalProgressUseCase;
  late MockShareAchievementUseCase mockShareAchievementUseCase;

  setUpAll(() {
    registerFallbackValue(const TrackProgressParams(
      userId: '',
      skillId: '',
      skillTitle: '',
    ));
    registerFallbackValue(const FetchProgressParams(userId: ''));
    registerFallbackValue(SetGoalParams(
      goal: LearningGoalEntity(
        id: '',
        userId: '',
        skillId: '',
        skillTitle: '',
        description: '',
        createdAt: DateTime(2025, 1, 1),
      ),
    ));
    registerFallbackValue(const FetchGoalsParams(userId: ''));
    registerFallbackValue(const UpdateGoalProgressParams(
      goalId: '',
      progressPercent: 0,
    ));
    registerFallbackValue(const ShareAchievementParams(
      progressId: '',
      milestone: '',
    ));
  });

  setUp(() {
    mockTrackUseCase = MockTrackProgressUseCase();
    mockFetchProgressUseCase = MockFetchProgressUseCase();
    mockSetGoalUseCase = MockSetGoalUseCase();
    mockFetchGoalsUseCase = MockFetchGoalsUseCase();
    mockUpdateGoalProgressUseCase = MockUpdateGoalProgressUseCase();
    mockShareAchievementUseCase = MockShareAchievementUseCase();

    bloc = ProgressBloc(
      trackProgressUseCase: mockTrackUseCase,
      fetchProgressUseCase: mockFetchProgressUseCase,
      setGoalUseCase: mockSetGoalUseCase,
      fetchGoalsUseCase: mockFetchGoalsUseCase,
      updateGoalProgressUseCase: mockUpdateGoalProgressUseCase,
      shareAchievementUseCase: mockShareAchievementUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('FetchProgressRequested', () {
    blocTest<ProgressBloc, ProgressState>(
      'emits [ProgressLoading, ProgressLoaded] on success',
      build: () {
        when(() => mockFetchProgressUseCase(any()))
            .thenAnswer((_) async => Right([tProgress]));
        return bloc;
      },
      act: (bloc) => bloc.add(FetchProgressRequested(userId: 'user1')),
      expect: () => [
        isA<ProgressLoading>(),
        isA<ProgressLoaded>().having(
          (s) => s.progressList,
          'progressList',
          [tProgress],
        ),
      ],
    );

    blocTest<ProgressBloc, ProgressState>(
      'emits [ProgressLoading, ProgressError] on failure',
      build: () {
        when(() => mockFetchProgressUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(FetchProgressRequested(userId: 'user1')),
      expect: () => [
        isA<ProgressLoading>(),
        isA<ProgressError>(),
      ],
    );
  });

  group('TrackProgressRequested', () {
    blocTest<ProgressBloc, ProgressState>(
      'emits [ProgressLoading, ProgressTracked] on success',
      build: () {
        when(() => mockTrackUseCase(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(TrackProgressRequested(
        userId: 'user1',
        skillId: 'flutter',
        skillTitle: 'Flutter',
        hoursLogged: 1.0,
        sessionsCompleted: 1,
        xpGained: 100,
      )),
      expect: () => [
        isA<ProgressLoading>(),
        isA<ProgressTracked>(),
      ],
    );

    blocTest<ProgressBloc, ProgressState>(
      'emits [ProgressLoading, ProgressError] on failure',
      build: () {
        when(() => mockTrackUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(TrackProgressRequested(
        userId: 'user1',
        skillId: 'flutter',
        skillTitle: 'Flutter',
        hoursLogged: 1.0,
        sessionsCompleted: 1,
        xpGained: 100,
      )),
      expect: () => [
        isA<ProgressLoading>(),
        isA<ProgressError>(),
      ],
    );
  });

  group('FetchGoalsRequested', () {
    blocTest<ProgressBloc, ProgressState>(
      'emits [ProgressLoading, GoalsLoaded] on success',
      build: () {
        when(() => mockFetchGoalsUseCase(any()))
            .thenAnswer((_) async => Right([tGoal]));
        return bloc;
      },
      act: (bloc) => bloc.add(FetchGoalsRequested(userId: 'user1')),
      expect: () => [
        isA<ProgressLoading>(),
        isA<GoalsLoaded>().having(
          (s) => s.goals,
          'goals',
          [tGoal],
        ),
      ],
    );

    blocTest<ProgressBloc, ProgressState>(
      'emits [ProgressLoading, ProgressError] on failure',
      build: () {
        when(() => mockFetchGoalsUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(FetchGoalsRequested(userId: 'user1')),
      expect: () => [
        isA<ProgressLoading>(),
        isA<ProgressError>(),
      ],
    );
  });

  group('SetGoalRequested', () {
    blocTest<ProgressBloc, ProgressState>(
      'emits [ProgressLoading, GoalSet] on success',
      build: () {
        when(() => mockSetGoalUseCase(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(SetGoalRequested(goal: tGoal)),
      expect: () => [
        isA<ProgressLoading>(),
        isA<GoalSet>(),
      ],
    );

    blocTest<ProgressBloc, ProgressState>(
      'emits [ProgressLoading, ProgressError] on failure',
      build: () {
        when(() => mockSetGoalUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(SetGoalRequested(goal: tGoal)),
      expect: () => [
        isA<ProgressLoading>(),
        isA<ProgressError>(),
      ],
    );
  });

  group('UpdateGoalProgressRequested', () {
    blocTest<ProgressBloc, ProgressState>(
      'emits [ProgressLoading, GoalProgressUpdated] on success',
      build: () {
        when(() => mockUpdateGoalProgressUseCase(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(UpdateGoalProgressRequested(
        goalId: 'goal1',
        progressPercent: 50,
      )),
      expect: () => [
        isA<ProgressLoading>(),
        isA<GoalProgressUpdated>(),
      ],
    );

    blocTest<ProgressBloc, ProgressState>(
      'emits [ProgressLoading, ProgressError] on failure',
      build: () {
        when(() => mockUpdateGoalProgressUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(UpdateGoalProgressRequested(
        goalId: 'goal1',
        progressPercent: 50,
      )),
      expect: () => [
        isA<ProgressLoading>(),
        isA<ProgressError>(),
      ],
    );
  });

  group('ShareAchievementRequested', () {
    blocTest<ProgressBloc, ProgressState>(
      'emits [ProgressLoading, AchievementShared] on success',
      build: () {
        when(() => mockShareAchievementUseCase(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(ShareAchievementRequested(
        progressId: 'progress1',
        milestone: 'Earned 100XP',
      )),
      expect: () => [
        isA<ProgressLoading>(),
        isA<AchievementShared>(),
      ],
    );

    blocTest<ProgressBloc, ProgressState>(
      'emits [ProgressLoading, ProgressError] on failure',
      build: () {
        when(() => mockShareAchievementUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(ShareAchievementRequested(
        progressId: 'progress1',
        milestone: 'Earned 100XP',
      )),
      expect: () => [
        isA<ProgressLoading>(),
        isA<ProgressError>(),
      ],
    );
  });
}
