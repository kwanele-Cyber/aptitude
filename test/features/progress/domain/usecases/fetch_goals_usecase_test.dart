import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/progress/domain/entity/learning_goal_entity.dart';
import 'package:myapp/features/progress/domain/repository/progress_repository.dart';
import 'package:myapp/features/progress/domain/usecases/fetch_goals_usecase.dart';

class MockProgressRepository extends Mock implements ProgressRepository {}

void main() {
  late MockProgressRepository mockRepository;
  late FetchGoalsUseCase useCase;

  setUp(() {
    mockRepository = MockProgressRepository();
    useCase = FetchGoalsUseCase(repository: mockRepository);
  });

  group('FetchGoalsUseCase', () {
    const params = FetchGoalsParams(userId: 'user1');

    final tGoals = [
      LearningGoalEntity(
        id: 'goal1',
        userId: 'user1',
        skillId: 'flutter',
        skillTitle: 'Flutter',
        description: 'Build a Flutter app',
        createdAt: DateTime(2025, 1, 1),
      ),
    ];

    test('should fetch goals on success', () async {
      when(() => mockRepository.fetchGoals('user1'))
          .thenAnswer((_) async => Right(tGoals));

      final result = await useCase(params);

      expect(result.isRight(), true);
      expect(result.getOrElse(() => []), tGoals);
      verify(() => mockRepository.fetchGoals('user1')).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.fetchGoals('user1'))
          .thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });
}
