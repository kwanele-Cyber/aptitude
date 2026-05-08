import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/agreements/domain/repository/agreement_repository.dart';
import 'package:myapp/features/agreements/domain/usecases/accept_agreement_usecase.dart';

class MockAgreementRepository extends Mock implements AgreementRepository {}

void main() {
  late MockAgreementRepository mockRepository;
  late AcceptAgreementUseCase useCase;

  setUp(() {
    mockRepository = MockAgreementRepository();
    useCase = AcceptAgreementUseCase(repository: mockRepository);
  });

  group('AcceptAgreementUseCase', () {
    const params = AcceptAgreementParams(
      agreementId: 'agreement1',
      userId: 'user2',
    );

    test('should accept agreement on success', () async {
      when(() => mockRepository.acceptAgreement(any(), any()))
          .thenAnswer((_) async => const Right(null));

      final result = await useCase(params);

      expect(result.isRight(), true);
      verify(() => mockRepository.acceptAgreement('agreement1', 'user2'))
          .called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.acceptAgreement(any(), any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });
}
