import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/matchmaking/domain/repository/match_repository.dart';
import 'package:myapp/features/matchmaking/domain/usecases/save_match_usecase.dart';

class MockMatchRepository extends Mock implements MatchRepository {}

void main() {
  late MockMatchRepository mockRepository;
  late SaveMatchUseCase useCase;

  setUp(() {
    mockRepository = MockMatchRepository();
    useCase = SaveMatchUseCase(repository: mockRepository);
  });

  group('SaveMatchUseCase', () {
    const params = SaveMatchParams(matchId: 'match1');

    test('should save match on success', () async {
      when(() => mockRepository.saveMatch(any()))
          .thenAnswer((_) async => const Right(null));

      final result = await useCase(params);

      expect(result.isRight(), true);
      verify(() => mockRepository.saveMatch('match1')).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.saveMatch(any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });
}
