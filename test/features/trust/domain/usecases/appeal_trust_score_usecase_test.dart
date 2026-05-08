import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/trust/domain/entity/trust_entity.dart';
import 'package:myapp/features/trust/domain/repository/trust_repository.dart';
import 'package:myapp/features/trust/domain/usecases/appeal_trust_score_usecase.dart';

class MockTrustRepository extends Mock implements TrustRepository {}

final tAppealEntity = TrustAppealEntity(
  id: 'appeal1',
  userId: 'user1',
  reason: 'My score dropped unfairly',
  status: AppealStatus.pending,
  createdAt: DateTime(2025, 1, 1),
);

void main() {
  late MockTrustRepository mockRepository;
  late AppealTrustScoreUseCase useCase;
  late GetAppealsUseCase getAppealsUseCase;

  setUp(() {
    mockRepository = MockTrustRepository();
    useCase = AppealTrustScoreUseCase(repository: mockRepository);
    getAppealsUseCase = GetAppealsUseCase(repository: mockRepository);
  });

  group('AppealTrustScoreUseCase', () {
    const params = AppealTrustScoreParams(
      userId: 'user1',
      reason: 'My score dropped unfairly',
    );

    test('should submit appeal on success', () async {
      when(() => mockRepository.submitAppeal(any(), any()))
          .thenAnswer((_) async => Right(tAppealEntity));

      final result = await useCase(params);

      expect(result.isRight(), true);
      verify(() => mockRepository.submitAppeal('user1', 'My score dropped unfairly'))
          .called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.submitAppeal(any(), any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });

  group('GetAppealsUseCase', () {
    const params = GetAppealsParams(userId: 'user1');

    test('should get appeals on success', () async {
      when(() => mockRepository.getAppeals(any()))
          .thenAnswer((_) async => Right([tAppealEntity]));

      final result = await getAppealsUseCase(params);

      expect(result.isRight(), true);
      verify(() => mockRepository.getAppeals('user1')).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.getAppeals(any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final result = await getAppealsUseCase(params);

      expect(result.isLeft(), true);
    });
  });
}
