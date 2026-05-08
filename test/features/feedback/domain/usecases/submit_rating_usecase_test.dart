import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/feedback/domain/entities/feedback_entity.dart';
import 'package:myapp/features/feedback/domain/repository/feedback_repository.dart';
import 'package:myapp/features/feedback/domain/usecases/submit_rating_usecase.dart';

class MockFeedbackRepository extends Mock implements FeedbackRepository {}

final tFeedback = FeedbackEntity(
  id: 'feedback1',
  sessionId: 'session1',
  reviewerId: 'reviewer1',
  reviewerName: 'Alice',
  revieweeId: 'reviewee1',
  revieweeName: 'Bob',
  rating: 4,
  createdAt: DateTime(2024, 1, 15, 10, 0),
  updatedAt: DateTime(2024, 1, 15, 10, 0),
);

void main() {
  late MockFeedbackRepository mockRepository;
  late SubmitRatingUseCase useCase;

  setUp(() {
    mockRepository = MockFeedbackRepository();
    useCase = SubmitRatingUseCase(repository: mockRepository);
  });

  group('SubmitRatingUseCase', () {
    final params = SubmitRatingParams(
      sessionId: 'session1',
      reviewerId: 'reviewer1',
      reviewerName: 'Alice',
      revieweeId: 'reviewee1',
      revieweeName: 'Bob',
      rating: 4,
    );

    test('should call repository.submitRating with correct params', () async {
      when(() => mockRepository.submitRating(
          any(), any(), any(), any(), any(), any()))
          .thenAnswer((_) async => Right(tFeedback));

      final result = await useCase(params);

      verify(() => mockRepository.submitRating(
          'session1', 'reviewer1', 'Alice', 'reviewee1', 'Bob', 4)).called(1);
      expect(result.isRight(), true);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.submitRating(
          any(), any(), any(), any(), any(), any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });
}
