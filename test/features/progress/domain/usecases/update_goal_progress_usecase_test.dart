import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/progress/domain/repository/progress_repository.dart';
import 'package:myapp/features/progress/domain/usecases/update_goal_progress_usecase.dart';

class MockProgressRepository extends Mock implements ProgressRepository {}

void main() {
  late MockProgressRepository mockRepository;
  late UpdateGoalProgressUseCase useCase;

  setUp(() {
    mockRepository = MockProgressRepository();
    useCase = UpdateGoalProgressUseCase(repository: mockRepository);
  });

  group('UpdateGoalProgressUseCase', () {
    const params = UpdateGoalProgressParams(
      goalId: 'goal1',
      progressPercent: 50,
    );

    test('should update goal progress on success', () async {
      when(() => mockRepository.updateGoalProgress('goal1', 50))
          .thenAnswer((_) async => const Right(null));

      final result = await useCase(params);

      expect(result.isRight(), true);
      verify(() => mockRepository.updateGoalProgress('goal1', 50)).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.updateGoalProgress('goal1', 50))
          .thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });
}
