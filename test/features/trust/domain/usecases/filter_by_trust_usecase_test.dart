import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/trust/domain/repository/trust_repository.dart';
import 'package:myapp/features/trust/domain/usecases/filter_by_trust_usecase.dart';

class MockTrustRepository extends Mock implements TrustRepository {}

void main() {
  late MockTrustRepository mockRepository;
  late FilterByTrustUseCase useCase;

  setUp(() {
    mockRepository = MockTrustRepository();
    useCase = FilterByTrustUseCase(repository: mockRepository);
  });

  group('FilterByTrustUseCase', () {
    const params = FilterByTrustParams(threshold: 70);

    test('should return users above threshold on success', () async {
      when(() => mockRepository.getUsersAboveTrustThreshold(any()))
          .thenAnswer((_) async => const Right(['user1', 'user2']));

      final result = await useCase(params);

      expect(result.isRight(), true);
      verify(() => mockRepository.getUsersAboveTrustThreshold(70)).called(1);
    });

    test('should return empty list when no users meet threshold', () async {
      when(() => mockRepository.getUsersAboveTrustThreshold(any()))
          .thenAnswer((_) async => const Right(<String>[]));

      final result = await useCase(params);

      expect(result.isRight(), true);
      expect(result.getOrElse(() => []), isEmpty);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.getUsersAboveTrustThreshold(any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });
}
