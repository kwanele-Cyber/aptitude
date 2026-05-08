import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/disputes/domain/entities/dispute_entity.dart';
import 'package:myapp/features/disputes/domain/repository/dispute_repository.dart';
import 'package:myapp/features/disputes/domain/usecases/report_user_usecase.dart';

class MockDisputeRepository extends Mock implements DisputeRepository {}

final tDispute = DisputeEntity(
  id: 'dispute1',
  type: DisputeType.report,
  reporterId: 'user1',
  reporterName: 'Alice',
  reportedUserId: 'user2',
  reportedUserName: 'Bob',
  reason: 'Harassment',
  description: 'Inappropriate messages',
  createdAt: DateTime(2024, 1, 15, 10, 0),
  updatedAt: DateTime(2024, 1, 15, 10, 0),
);

void main() {
  late MockDisputeRepository mockRepository;
  late ReportUserUseCase useCase;

  setUp(() {
    mockRepository = MockDisputeRepository();
    useCase = ReportUserUseCase(repository: mockRepository);
  });

  group('ReportUserUseCase', () {
    final params = ReportUserParams(
      reporterId: 'user1',
      reporterName: 'Alice',
      reportedUserId: 'user2',
      reportedUserName: 'Bob',
      reason: 'Harassment',
      description: 'Inappropriate messages',
    );

    test('should call repository.reportUser with correct params', () async {
      when(() => mockRepository.reportUser(
            reporterId: any(named: 'reporterId'),
            reporterName: any(named: 'reporterName'),
            reportedUserId: any(named: 'reportedUserId'),
            reportedUserName: any(named: 'reportedUserName'),
            reason: any(named: 'reason'),
            description: any(named: 'description'),
            evidenceUrls: any(named: 'evidenceUrls'),
          )).thenAnswer((_) async => Right(tDispute));

      final result = await useCase(params);

      verify(() => mockRepository.reportUser(
            reporterId: 'user1',
            reporterName: 'Alice',
            reportedUserId: 'user2',
            reportedUserName: 'Bob',
            reason: 'Harassment',
            description: 'Inappropriate messages',
            evidenceUrls: [],
          )).called(1);
      expect(result.isRight(), true);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.reportUser(
            reporterId: any(named: 'reporterId'),
            reporterName: any(named: 'reporterName'),
            reportedUserId: any(named: 'reportedUserId'),
            reportedUserName: any(named: 'reportedUserName'),
            reason: any(named: 'reason'),
            description: any(named: 'description'),
            evidenceUrls: any(named: 'evidenceUrls'),
          )).thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });
}
