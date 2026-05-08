import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/agreements/domain/entities/agreement_entity.dart';
import 'package:myapp/features/agreements/domain/repository/agreement_repository.dart';
import 'package:myapp/features/agreements/domain/usecases/get_agreement_by_id_usecase.dart';

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
  status: AgreementStatus.pending,
  duration: '4 weeks',
  frequency: '1x/week',
  sessionsCount: 4,
  notes: null,
  createdAt: DateTime(2025, 1, 1),
  updatedAt: DateTime(2025, 1, 1),
);

void main() {
  late MockAgreementRepository mockRepository;
  late GetAgreementByIdUseCase useCase;

  setUp(() {
    mockRepository = MockAgreementRepository();
    useCase = GetAgreementByIdUseCase(repository: mockRepository);
  });

  group('GetAgreementByIdUseCase', () {
    const params = GetAgreementByIdParams(agreementId: 'agreement1');

    test('should get agreement by id on success', () async {
      when(() => mockRepository.getAgreementById(any()))
          .thenAnswer((_) async => Right(tAgreement));

      final result = await useCase(params);

      expect(result.isRight(), true);
      verify(() => mockRepository.getAgreementById('agreement1')).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.getAgreementById(any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });
}
