import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/progress/data/datasources/progress_remote_datasource.dart';
import 'package:myapp/features/progress/data/models/learning_goal_model.dart';
import 'package:myapp/features/progress/data/models/skill_progress_model.dart';
import 'package:myapp/features/progress/data/repository/progress_repository_impl.dart';
import 'package:myapp/features/progress/domain/entity/learning_goal_entity.dart';
import 'package:myapp/features/progress/domain/entity/skill_progress_entity.dart';

class MockProgressRemoteDataSource extends Mock
    implements ProgressRemoteDataSource {}

final tProgressModel = SkillProgressModel(
  id: 'flutter_progress',
  userId: 'user1',
  skillId: 'flutter',
  skillTitle: 'Flutter',
  xpPoints: 100,
  hoursLogged: 2.0,
  sessionsCompleted: 1,
  updatedAt: DateTime(2025, 1, 1),
);

final tGoalModel = LearningGoalModel(
  id: 'user1_goal1',
  userId: 'user1',
  skillId: 'flutter',
  skillTitle: 'Flutter',
  description: 'Build a Flutter app',
  createdAt: DateTime(2025, 1, 1),
);

void main() {
  late ProgressRepositoryImpl repository;
  late MockProgressRemoteDataSource mockRemote;

  setUp(() {
    mockRemote = MockProgressRemoteDataSource();
    repository = ProgressRepositoryImpl(remoteDataSource: mockRemote);
  });

  group('trackProgress', () {
    test('should track progress on success', () async {
      when(() => mockRemote.trackProgress(
            userId: 'user1',
            skillId: 'flutter',
            skillTitle: 'Flutter',
            hoursLogged: 1.5,
            sessionsCompleted: 1,
            xpGained: 100,
          )).thenAnswer((_) async => tProgressModel);

      final result = await repository.trackProgress(
        userId: 'user1',
        skillId: 'flutter',
        skillTitle: 'Flutter',
        hoursLogged: 1.5,
        sessionsCompleted: 1,
        xpGained: 100,
      );

      expect(result.isRight(), true);
    });

    test('should return ServerFailure when remote throws', () async {
      when(() => mockRemote.trackProgress(
            userId: 'user1',
            skillId: 'flutter',
            skillTitle: 'Flutter',
            hoursLogged: 1.5,
            sessionsCompleted: 1,
            xpGained: 100,
          )).thenThrow(ServerException());

      final result = await repository.trackProgress(
        userId: 'user1',
        skillId: 'flutter',
        skillTitle: 'Flutter',
        hoursLogged: 1.5,
        sessionsCompleted: 1,
        xpGained: 100,
      );

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });

    test('should return ServerFailure on generic exception', () async {
      when(() => mockRemote.trackProgress(
            userId: 'user1',
            skillId: 'flutter',
            skillTitle: 'Flutter',
            hoursLogged: 1.5,
            sessionsCompleted: 1,
            xpGained: 100,
          )).thenThrow(Exception());

      final result = await repository.trackProgress(
        userId: 'user1',
        skillId: 'flutter',
        skillTitle: 'Flutter',
        hoursLogged: 1.5,
        sessionsCompleted: 1,
        xpGained: 100,
      );

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('fetchProgress', () {
    test('should fetch progress on success', () async {
      when(() => mockRemote.fetchProgress('user1'))
          .thenAnswer((_) async => [tProgressModel]);

      final result = await repository.fetchProgress('user1');

      expect(result.isRight(), true);
      expect(result.getOrElse(() => []), isA<List<SkillProgressEntity>>());
      verify(() => mockRemote.fetchProgress('user1')).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      when(() => mockRemote.fetchProgress('user1'))
          .thenThrow(ServerException());

      final result = await repository.fetchProgress('user1');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });

    test('should return ServerFailure on generic exception', () async {
      when(() => mockRemote.fetchProgress('user1'))
          .thenThrow(Exception());

      final result = await repository.fetchProgress('user1');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('setGoal', () {
    test('should set goal on success', () async {
      when(() => mockRemote.setGoal(tGoalModel))
          .thenAnswer((_) async {});

      final result = await repository.setGoal(tGoalModel);

      expect(result.isRight(), true);
      verify(() => mockRemote.setGoal(tGoalModel)).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      when(() => mockRemote.setGoal(tGoalModel))
          .thenThrow(ServerException());

      final result = await repository.setGoal(tGoalModel);

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });

    test('should return ServerFailure on generic exception', () async {
      when(() => mockRemote.setGoal(tGoalModel))
          .thenThrow(Exception());

      final result = await repository.setGoal(tGoalModel);

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('fetchGoals', () {
    test('should fetch goals on success', () async {
      when(() => mockRemote.fetchGoals('user1'))
          .thenAnswer((_) async => [tGoalModel]);

      final result = await repository.fetchGoals('user1');

      expect(result.isRight(), true);
      expect(result.getOrElse(() => []), isA<List<LearningGoalEntity>>());
      verify(() => mockRemote.fetchGoals('user1')).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      when(() => mockRemote.fetchGoals('user1'))
          .thenThrow(ServerException());

      final result = await repository.fetchGoals('user1');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });

    test('should return ServerFailure on generic exception', () async {
      when(() => mockRemote.fetchGoals('user1'))
          .thenThrow(Exception());

      final result = await repository.fetchGoals('user1');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('updateGoalProgress', () {
    test('should update goal progress on success', () async {
      when(() => mockRemote.updateGoalProgress('goal1', 50))
          .thenAnswer((_) async {});

      final result = await repository.updateGoalProgress('goal1', 50);

      expect(result.isRight(), true);
      verify(() => mockRemote.updateGoalProgress('goal1', 50)).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      when(() => mockRemote.updateGoalProgress('goal1', 50))
          .thenThrow(ServerException());

      final result = await repository.updateGoalProgress('goal1', 50);

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });

    test('should return ServerFailure on generic exception', () async {
      when(() => mockRemote.updateGoalProgress('goal1', 50))
          .thenThrow(Exception());

      final result = await repository.updateGoalProgress('goal1', 50);

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('shareAchievement', () {
    test('should share achievement on success', () async {
      when(() => mockRemote.shareAchievement('progress1', 'Earned 100XP'))
          .thenAnswer((_) async {});

      final result = await repository.shareAchievement('progress1', 'Earned 100XP');

      expect(result.isRight(), true);
      verify(() => mockRemote.shareAchievement('progress1', 'Earned 100XP')).called(1);
    });

    test('should return ServerFailure when remote throws', () async {
      when(() => mockRemote.shareAchievement('progress1', 'Earned 100XP'))
          .thenThrow(ServerException());

      final result = await repository.shareAchievement('progress1', 'Earned 100XP');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });

    test('should return ServerFailure on generic exception', () async {
      when(() => mockRemote.shareAchievement('progress1', 'Earned 100XP'))
          .thenThrow(Exception());

      final result = await repository.shareAchievement('progress1', 'Earned 100XP');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });
}
