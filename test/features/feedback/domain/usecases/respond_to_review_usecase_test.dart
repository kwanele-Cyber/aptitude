import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/feedback/domain/entities/feedback_entity.dart';
import 'package:myapp/features/feedback/domain/repository/feedback_repository.dart';
import 'package:myapp/features/feedback/domain/usecases/respond_to_review_usecase.dart';

class MockFeedbackRepository extends Mock implements FeedbackRepository {}

final tFeedback = FeedbackEntity(
  id: 'feedback1',
  sessionId: 'session1',
  reviewerId: 'reviewer1',
  reviewerName: 'Alice',
  revieweeId: 'reviewee1',
  revieweeName: 'Bob',
  rating: 4,
  review: 'Great session!',
  response: 'Thank you!',
  respondedAt: DateTime(2024, 1, 16, 12, 0),
  createdAt: DateTime(2024, 1, 15, 10, 0),
  updatedAt: DateTime(2024, 1, 16, 12, 0),
);

void main() {
  late MockFeedbackRepository mockRepository;
  late RespondToReviewUseCase useCase;

  setUp(() {
    mockRepository = MockFeedbackRepository();
    useCase = RespondToReviewUseCase(repository: mockRepository);
  });

  group('RespondToReviewUseCase', () {
    final params = RespondToReviewParams(
      feedbackId: 'feedback1',
      response: 'Thank you!',
    );

    test('should call repository.respondToReview with correct params', () async {
      when(() => mockRepository.respondToReview(any(), any()))
          .thenAnswer((_) async => Right(tFeedback));

      final result = await useCase(params);

      verify(() => mockRepository.respondToReview('feedback1', 'Thank you!'))
          .called(1);
      expect(result.isRight(), true);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.respondToReview(any(), any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });
}
