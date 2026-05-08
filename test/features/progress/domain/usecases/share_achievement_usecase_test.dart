import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/progress/domain/repository/progress_repository.dart';
import 'package:myapp/features/progress/domain/usecases/share_achievement_usecase.dart';

class MockProgressRepository extends Mock implements ProgressRepository {}

void main() {
  late MockProgressRepository mockRepository;
  late ShareAchievementUseCase useCase;

  setUp(() {
    mockRepository = MockProgressRepository();
    useCase = ShareAchievementUseCase(repository: mockRepository);
  });

  group('ShareAchievementUseCase', () {
    const params = ShareAchievementParams(
      progressId: 'progress1',
      milestone: 'Earned 100XP',
    );

    test('should share achievement on success', () async {
      when(() => mockRepository.shareAchievement('progress1', 'Earned 100XP'))
          .thenAnswer((_) async => const Right(null));

      final result = await useCase(params);

      expect(result.isRight(), true);
      verify(() => mockRepository.shareAchievement('progress1', 'Earned 100XP'))
          .called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.shareAchievement('progress1', 'Earned 100XP'))
          .thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });
}
