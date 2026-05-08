import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/agreements/domain/entities/agreement_entity.dart';
import 'package:myapp/features/agreements/domain/repository/agreement_repository.dart';
import 'package:myapp/features/agreements/domain/usecases/view_agreements_usecase.dart';

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
  late ViewAgreementsUseCase useCase;

  setUp(() {
    mockRepository = MockAgreementRepository();
    useCase = ViewAgreementsUseCase(repository: mockRepository);
  });

  group('ViewAgreementsUseCase', () {
    const params = ViewAgreementsParams(userId: 'user1');

    test('should view agreements on success', () async {
      when(() => mockRepository.viewAgreements(any()))
          .thenAnswer((_) async => Right([tAgreement]));

      final result = await useCase(params);

      expect(result.isRight(), true);
      verify(() => mockRepository.viewAgreements('user1')).called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.viewAgreements(any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });
}
