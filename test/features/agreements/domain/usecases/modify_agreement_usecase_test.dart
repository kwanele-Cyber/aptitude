import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/agreements/domain/entities/agreement_entity.dart';
import 'package:myapp/features/agreements/domain/repository/agreement_repository.dart';
import 'package:myapp/features/agreements/domain/usecases/modify_agreement_usecase.dart';

class MockAgreementRepository extends Mock implements AgreementRepository {}

final tAgreement = AgreementEntity(
  id: 'agreement1',
  initiatorId: 'user1',
  initiatorName: 'User One',
  partnerId: 'user2',
  partnerName: 'User Two',
  initiatorSkillId: 'skill1',
  initiatorSkillTitle: 'Flutter',
  partnerSkillId: 'skill2',
  partnerSkillTitle: 'Photography',
  status: AgreementStatus.modified,
  duration: '6 weeks',
  frequency: '2x/week',
  sessionsCount: 12,
  notes: 'Extended terms',
  createdAt: DateTime(2025, 1, 1),
  updatedAt: DateTime(2025, 1, 15),
  modifiedBy: 'user1',
);

void main() {
  late MockAgreementRepository mockRepository;
  late ModifyAgreementUseCase useCase;

  setUp(() {
    mockRepository = MockAgreementRepository();
    useCase = ModifyAgreementUseCase(repository: mockRepository);
  });

  group('ModifyAgreementUseCase', () {
    const params = ModifyAgreementParams(
      agreementId: 'agreement1',
      userId: 'user1',
      duration: '6 weeks',
      frequency: '2x/week',
      sessionsCount: 12,
      notes: 'Extended terms',
    );

    test('should modify agreement on success', () async {
      when(() => mockRepository.modifyAgreement(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          )).thenAnswer((_) async => Right(tAgreement));

      final result = await useCase(params);

      expect(result.isRight(), true);
      verify(() => mockRepository.modifyAgreement(
        'agreement1',
        'user1',
        '6 weeks',
        '2x/week',
        12,
        'Extended terms',
      )).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.modifyAgreement(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          )).thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });
}
