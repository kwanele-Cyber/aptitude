import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/disputes/domain/entities/dispute_entity.dart';
import 'package:myapp/features/disputes/domain/repository/dispute_repository.dart';
import 'package:myapp/features/disputes/domain/usecases/resolve_dispute_usecase.dart';

class MockDisputeRepository extends Mock implements DisputeRepository {}

final tDispute = DisputeEntity(
  id: 'dispute1',
  type: DisputeType.dispute,
  reporterId: 'user1',
  reporterName: 'Alice',
  respondentId: 'user2',
  reason: 'Agreement Violation',
  description: 'Did not fulfill terms',
  status: DisputeStatus.resolved,
  resolution: 'Resolved amicably',
  resolvedBy: 'admin1',
  resolvedAt: DateTime(2024, 1, 16, 10, 0),
  createdAt: DateTime(2024, 1, 15, 10, 0),
  updatedAt: DateTime(2024, 1, 16, 10, 0),
);

void main() {
  late MockDisputeRepository mockRepository;
  late ResolveDisputeUseCase useCase;

  setUpAll(() {
    registerFallbackValue(DisputeStatus.pending);
  });

  setUp(() {
    mockRepository = MockDisputeRepository();
    useCase = ResolveDisputeUseCase(repository: mockRepository);
  });

  group('ResolveDisputeUseCase', () {
    final params = ResolveDisputeParams(
      disputeId: 'dispute1',
      resolution: 'Resolved amicably',
      resolvedBy: 'admin1',
      status: DisputeStatus.resolved,
    );

    test('should call repository.resolveDispute with correct params', () async {
      when(() => mockRepository.resolveDispute(
            any(),
            resolution: any(named: 'resolution'),
            resolvedBy: any(named: 'resolvedBy'),
            status: any(named: 'status'),
          )).thenAnswer((_) async => Right(tDispute));

      final result = await useCase(params);

      verify(() => mockRepository.resolveDispute(
            'dispute1',
            resolution: 'Resolved amicably',
            resolvedBy: 'admin1',
            status: DisputeStatus.resolved,
          )).called(1);
      expect(result.isRight(), true);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.resolveDispute(
            any(),
            resolution: any(named: 'resolution'),
            resolvedBy: any(named: 'resolvedBy'),
            status: any(named: 'status'),
          )).thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });
}
