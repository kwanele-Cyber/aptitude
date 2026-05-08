import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/progress/domain/entity/learning_goal_entity.dart';
import 'package:myapp/features/progress/domain/repository/progress_repository.dart';
import 'package:myapp/features/progress/domain/usecases/set_goal_usecase.dart';

class MockProgressRepository extends Mock implements ProgressRepository {}

void main() {
  late MockProgressRepository mockRepository;
  late SetGoalUseCase useCase;

  setUp(() {
    mockRepository = MockProgressRepository();
    useCase = SetGoalUseCase(repository: mockRepository);
  });

  group('SetGoalUseCase', () {
    final tGoal = LearningGoalEntity(
      id: 'goal1',
      userId: 'user1',
      skillId: 'flutter',
      skillTitle: 'Flutter',
      description: 'Build a Flutter app',
      createdAt: DateTime(2025, 1, 1),
    );

    final params = SetGoalParams(goal: tGoal);

    test('should set goal on success', () async {
      when(() => mockRepository.setGoal(tGoal))
          .thenAnswer((_) async => const Right(null));

      final result = await useCase(params);

      expect(result.isRight(), true);
      verify(() => mockRepository.setGoal(tGoal)).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.setGoal(tGoal))
          .thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });
}
