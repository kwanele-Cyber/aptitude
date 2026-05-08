import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/trust/domain/entity/trust_entity.dart';
import 'package:myapp/features/trust/domain/repository/trust_repository.dart';
import 'package:myapp/features/trust/domain/usecases/update_reputation_usecase.dart';

class MockTrustRepository extends Mock implements TrustRepository {}

final tTrustEntity = TrustEntity(
  id: 'trust_user1',
  userId: 'user1',
  score: 80,
  factors: [],
  lastCalculated: DateTime(2025, 1, 1),
  createdAt: DateTime(2025, 1, 1),
  updatedAt: DateTime(2025, 1, 1),
);

void main() {
  late MockTrustRepository mockRepository;
  late UpdateReputationUseCase useCase;

  setUp(() {
    mockRepository = MockTrustRepository();
    useCase = UpdateReputationUseCase(repository: mockRepository);
  });

  group('UpdateReputationUseCase', () {
    const params = UpdateReputationParams(
      userId: 'user1',
      event: 'session_completed',
      data: {'sessionId': 'session1'},
    );

    test('should update reputation on success', () async {
      when(() => mockRepository.updateReputation(any(), any(), any()))
          .thenAnswer((_) async => Right(tTrustEntity));

      final result = await useCase(params);

      expect(result.isRight(), true);
      verify(() => mockRepository.updateReputation('user1', 'session_completed', {
        'sessionId': 'session1',
      })).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.updateReputation(any(), any(), any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });
}
