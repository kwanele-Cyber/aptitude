import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/disputes/domain/entities/dispute_entity.dart';
import 'package:myapp/features/disputes/domain/repository/dispute_repository.dart';
import 'package:myapp/features/disputes/domain/usecases/create_dispute_usecase.dart';

class MockDisputeRepository extends Mock implements DisputeRepository {}

final tDispute = DisputeEntity(
  id: 'dispute1',
  type: DisputeType.dispute,
  reporterId: 'user1',
  reporterName: 'Alice',
  respondentId: 'user2',
  reason: 'Agreement Violation',
  description: 'Did not fulfill terms',
  createdAt: DateTime(2024, 1, 15, 10, 0),
  updatedAt: DateTime(2024, 1, 15, 10, 0),
);

void main() {
  late MockDisputeRepository mockRepository;
  late CreateDisputeUseCase useCase;

  setUp(() {
    mockRepository = MockDisputeRepository();
    useCase = CreateDisputeUseCase(repository: mockRepository);
  });

  group('CreateDisputeUseCase', () {
    final params = CreateDisputeParams(
      reporterId: 'user1',
      reporterName: 'Alice',
      respondentId: 'user2',
      reason: 'Agreement Violation',
      description: 'Did not fulfill terms',
    );

    test('should call repository.createDispute with correct params', () async {
      when(() => mockRepository.createDispute(
            reporterId: any(named: 'reporterId'),
            reporterName: any(named: 'reporterName'),
            respondentId: any(named: 'respondentId'),
            reason: any(named: 'reason'),
            description: any(named: 'description'),
            agreementId: any(named: 'agreementId'),
            sessionId: any(named: 'sessionId'),
            evidenceUrls: any(named: 'evidenceUrls'),
          )).thenAnswer((_) async => Right(tDispute));

      final result = await useCase(params);

      verify(() => mockRepository.createDispute(
            reporterId: 'user1',
            reporterName: 'Alice',
            respondentId: 'user2',
            reason: 'Agreement Violation',
            description: 'Did not fulfill terms',
            agreementId: null,
            sessionId: null,
            evidenceUrls: [],
          )).called(1);
      expect(result.isRight(), true);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.createDispute(
            reporterId: any(named: 'reporterId'),
            reporterName: any(named: 'reporterName'),
            respondentId: any(named: 'respondentId'),
            reason: any(named: 'reason'),
            description: any(named: 'description'),
            agreementId: any(named: 'agreementId'),
            sessionId: any(named: 'sessionId'),
            evidenceUrls: any(named: 'evidenceUrls'),
          )).thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });
}
