import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/progress/domain/entity/skill_progress_entity.dart';
import 'package:myapp/features/progress/domain/repository/progress_repository.dart';
import 'package:myapp/features/progress/domain/usecases/fetch_progress_usecase.dart';

class MockProgressRepository extends Mock implements ProgressRepository {}

void main() {
  late MockProgressRepository mockRepository;
  late FetchProgressUseCase useCase;

  setUp(() {
    mockRepository = MockProgressRepository();
    useCase = FetchProgressUseCase(repository: mockRepository);
  });

  group('FetchProgressUseCase', () {
    const params = FetchProgressParams(userId: 'user1');

    final tProgressList = [
      SkillProgressEntity(
        id: 'progress1',
        userId: 'user1',
        skillId: 'flutter',
        skillTitle: 'Flutter',
        updatedAt: DateTime(2025, 1, 1),
      ),
    ];

    test('should fetch progress on success', () async {
      when(() => mockRepository.fetchProgress('user1'))
          .thenAnswer((_) async => Right(tProgressList));

      final result = await useCase(params);

      expect(result.isRight(), true);
      expect(result.getOrElse(() => []), tProgressList);
      verify(() => mockRepository.fetchProgress('user1')).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.fetchProgress('user1'))
          .thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });
}
