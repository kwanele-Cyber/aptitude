import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/trust/domain/entity/trust_entity.dart';
import 'package:myapp/features/trust/domain/repository/trust_repository.dart';
import 'package:myapp/features/trust/domain/usecases/get_trust_profile_usecase.dart';

class MockTrustRepository extends Mock implements TrustRepository {}

final tTrustEntity = TrustEntity(
  id: 'trust_user1',
  userId: 'user1',
  score: 75,
  factors: [],
  lastCalculated: DateTime(2025, 1, 1),
  createdAt: DateTime(2025, 1, 1),
  updatedAt: DateTime(2025, 1, 1),
);

void main() {
  late MockTrustRepository mockRepository;
  late GetTrustProfileUseCase useCase;

  setUp(() {
    mockRepository = MockTrustRepository();
    useCase = GetTrustProfileUseCase(repository: mockRepository);
  });

  group('GetTrustProfileUseCase', () {
    const params = GetTrustProfileParams(userId: 'user1');

    test('should get trust profile on success', () async {
      when(() => mockRepository.getTrustProfile(any()))
          .thenAnswer((_) async => Right(tTrustEntity));

      final result = await useCase(params);

      expect(result.isRight(), true);
      verify(() => mockRepository.getTrustProfile('user1')).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.getTrustProfile(any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });
}
