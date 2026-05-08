import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/agreements/domain/repository/agreement_repository.dart';
import 'package:myapp/features/agreements/domain/usecases/cancel_agreement_usecase.dart';

class MockAgreementRepository extends Mock implements AgreementRepository {}

void main() {
  late MockAgreementRepository mockRepository;
  late CancelAgreementUseCase useCase;

  setUp(() {
    mockRepository = MockAgreementRepository();
    useCase = CancelAgreementUseCase(repository: mockRepository);
  });

  group('CancelAgreementUseCase', () {
    const params = CancelAgreementParams(
      agreementId: 'agreement1',
      userId: 'user1',
    );

    test('should cancel agreement on success', () async {
      when(() => mockRepository.cancelAgreement(any(), any()))
          .thenAnswer((_) async => const Right(null));

      final result = await useCase(params);

      expect(result.isRight(), true);
      verify(() => mockRepository.cancelAgreement('agreement1', 'user1'))
          .called(1);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.cancelAgreement(any(), any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });
}
