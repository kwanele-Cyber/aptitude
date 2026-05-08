import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/progress/domain/repository/progress_repository.dart';
import 'package:myapp/features/progress/domain/usecases/track_progress_usecase.dart';

class MockProgressRepository extends Mock implements ProgressRepository {}

void main() {
  late MockProgressRepository mockRepository;
  late TrackProgressUseCase useCase;

  setUp(() {
    mockRepository = MockProgressRepository();
    useCase = TrackProgressUseCase(repository: mockRepository);
  });

  group('TrackProgressUseCase', () {
    const params = TrackProgressParams(
      userId: 'user1',
      skillId: 'flutter',
      skillTitle: 'Flutter',
      hoursLogged: 1.5,
      sessionsCompleted: 1,
      xpGained: 100,
    );

    test('should track progress on success', () async {
      when(() => mockRepository.trackProgress(
            userId: 'user1',
            skillId: 'flutter',
            skillTitle: 'Flutter',
            hoursLogged: 1.5,
            sessionsCompleted: 1,
            xpGained: 100,
          )).thenAnswer((_) async => const Right(null));

      final result = await useCase(params);

      expect(result.isRight(), true);
      verify(() => mockRepository.trackProgress(
            userId: 'user1',
            skillId: 'flutter',
            skillTitle: 'Flutter',
            hoursLogged: 1.5,
            sessionsCompleted: 1,
            xpGained: 100,
          )).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.trackProgress(
            userId: 'user1',
            skillId: 'flutter',
            skillTitle: 'Flutter',
            hoursLogged: 1.5,
            sessionsCompleted: 1,
            xpGained: 100,
          )).thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });
}
