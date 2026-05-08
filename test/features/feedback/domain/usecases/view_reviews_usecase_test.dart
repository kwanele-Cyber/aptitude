import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/feedback/domain/entities/feedback_entity.dart';
import 'package:myapp/features/feedback/domain/repository/feedback_repository.dart';
import 'package:myapp/features/feedback/domain/usecases/view_reviews_usecase.dart';

class MockFeedbackRepository extends Mock implements FeedbackRepository {}

final tReviews = [
  FeedbackEntity(
    id: 'feedback1',
    sessionId: 'session1',
    reviewerId: 'reviewer1',
    reviewerName: 'Alice',
    revieweeId: 'reviewee1',
    revieweeName: 'Bob',
    rating: 5,
    review: 'Excellent!',
    createdAt: DateTime(2024, 1, 15, 10, 0),
    updatedAt: DateTime(2024, 1, 15, 10, 0),
  ),
];

void main() {
  late MockFeedbackRepository mockRepository;
  late ViewReviewsUseCase useCase;

  setUp(() {
    mockRepository = MockFeedbackRepository();
    useCase = ViewReviewsUseCase(repository: mockRepository);
  });

  group('ViewReviewsUseCase', () {
    test('should call repository.viewReviews without filters', () async {
      when(() => mockRepository.viewReviews(any()))
          .thenAnswer((_) async => Right(tReviews));

      final params = ViewReviewsParams(userId: 'reviewee1');
      final result = await useCase(params);

      verify(() => mockRepository.viewReviews('reviewee1')).called(1);
      expect(result.isRight(), true);
    });

    test('should call repository.viewReviews with rating filters', () async {
      when(() => mockRepository.viewReviews(any(),
          minRating: any(named: 'minRating'),
          maxRating: any(named: 'maxRating')))
          .thenAnswer((_) async => Right(tReviews));

      final params = ViewReviewsParams(
        userId: 'reviewee1',
        minRating: 3,
        maxRating: 5,
      );
      final result = await useCase(params);

      expect(result.isRight(), true);
    });

    test('should return Failure when repository fails', () async {
      when(() => mockRepository.viewReviews(any()))
          .thenAnswer((_) async => Left(ServerFailure()));

      final params = ViewReviewsParams(userId: 'reviewee1');
      final result = await useCase(params);

      expect(result.isLeft(), true);
    });
  });
}
