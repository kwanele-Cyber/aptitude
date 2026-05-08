import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/disputes/domain/entities/dispute_entity.dart';
import 'package:myapp/features/disputes/domain/repository/dispute_repository.dart';
import 'package:myapp/features/disputes/domain/usecases/appeal_decision_usecase.dart';

class MockDisputeRepository extends Mock implements DisputeRepository {}

final tDispute = DisputeEntity(
  id: 'dispute1',
  type: DisputeType.dispute,
  reporterId: 'user1',
  reporterName: 'Alice',
  respondentId: 'user2',
  reason: 'Agreement Violation',
  description: 'Did not fulfill terms',
  status: DisputeStatus.appealed,
  resolution: 'Resolved amicably',
  resolvedBy: 'admin1',
  resolvedAt: DateTime(2024, 1, 16, 10, 0),
  appealReason: 'Unfair decision',
  appealedAt: DateTime(2024, 1, 17, 10, 0),
  createdAt: DateTime(2024, 1, 15, 10, 0),
  updatedAt: DateTime(2024, 1, 17, 10, 0),
);

void main() {
  late MockDisputeRepository mockRepository;
  late AppealDecisionUseCase useCase;

  setUp(() {
    mockRepository = MockDisputeRepository();
    useCase = AppealDecisionUseCase(repository: mockRepository);
  });

  group('AppealDecisionUseCase', () {
    final params = AppealDecisionParams(
      disputeId: 'dispute1',
      appealReason: 'Unfair decision',
    );

    test('should call repository.appealDecision with correct params', () async {
      when(() => mockRepository.appealDecision(
            any(),
            appealReason: any(named: 'appealReason'),
          )).thenAnswer((_) async => Right(tDispute));

      final result = await useCase(params);

      verify(() => mockRepository.appealDecision(
            'dispute1',
            appealReason: 'Unfair decision',
          )).called(1);
      expect(result.isRight(), true);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.appealDecision(
            any(),
            appealReason: any(named: 'appealReason'),
          )).thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });
}
