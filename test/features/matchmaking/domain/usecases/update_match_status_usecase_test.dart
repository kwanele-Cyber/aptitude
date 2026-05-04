import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/matchmaking/domain/entity/match_entity.dart';
import 'package:myapp/features/matchmaking/domain/repository/match_repository.dart';
import 'package:myapp/features/matchmaking/domain/usecases/update_match_status_usecase.dart';

class MockMatchRepository extends Mock implements MatchRepository {}

void main() {
  late MockMatchRepository mockRepository;
  late UpdateMatchStatusUseCase useCase;

  setUpAll(() {
    registerFallbackValue(MatchStatus.pending);
  });

  setUp(() {
    mockRepository = MockMatchRepository();
    useCase = UpdateMatchStatusUseCase(repository: mockRepository);
  });

  group('UpdateMatchStatusUseCase', () {
    const params = UpdateMatchStatusParams(
      matchId: 'match1',
      status: MatchStatus.accepted,
    );

    test('should update match status on success', () async {
      when(() => mockRepository.updateMatchStatus(any(), any()))
          .thenAnswer((_) async => const Right(null));

      final result = await useCase(params);

      expect(result.isRight(), true);
      verify(
        () => mockRepository.updateMatchStatus('match1', MatchStatus.accepted),
      ).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.updateMatchStatus(any(), any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });
}
