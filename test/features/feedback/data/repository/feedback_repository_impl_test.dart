import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/feedback/data/datasources/feedback_remote_datasource.dart';
import 'package:myapp/features/feedback/data/models/feedback_model.dart';
import 'package:myapp/features/feedback/data/repository/feedback_repository_impl.dart';
import 'package:myapp/features/feedback/domain/entities/feedback_entity.dart';

class MockFeedbackRemoteDataSource extends Mock
    implements FeedbackRemoteDataSource {}

final tFeedbackModel = FeedbackModel(
  id: 'feedback1',
  sessionId: 'session1',
  reviewerId: 'reviewer1',
  reviewerName: 'Alice',
  revieweeId: 'reviewee1',
  revieweeName: 'Bob',
  rating: 4,
  review: 'Great session!',
  createdAt: DateTime(2024, 1, 15, 10, 0),
  updatedAt: DateTime(2024, 1, 15, 10, 0),
);

void main() {
  late FeedbackRepositoryImpl repository;
  late MockFeedbackRemoteDataSource mockRemote;

  setUpAll(() {
    registerFallbackValue(FeedbackModel(
      id: '',
      sessionId: '',
      reviewerId: '',
      reviewerName: '',
      revieweeId: '',
      revieweeName: '',
      rating: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
  });

  setUp(() {
    mockRemote = MockFeedbackRemoteDataSource();
    repository = FeedbackRepositoryImpl(remoteDataSource: mockRemote);
  });

  group('submitRating', () {
    test('should create feedback on success', () async {
      when(() => mockRemote.createFeedback(any()))
          .thenAnswer((_) async {});

      final result = await repository.submitRating(
        'session1', 'reviewer1', 'Alice', 'reviewee1', 'Bob', 4,
      );

      expect(result.isRight(), true);
      expect(result.getOrElse(() => tFeedbackModel), isA<FeedbackEntity>());
      verify(() => mockRemote.createFeedback(any())).called(1);
    });

    test('should clamp rating to valid range', () async {
      when(() => mockRemote.createFeedback(any()))
          .thenAnswer((_) async {});

      final result = await repository.submitRating(
        'session1', 'reviewer1', 'Alice', 'reviewee1', 'Bob', 10,
      );

      final feedback = result.getOrElse(() => tFeedbackModel);
      expect(feedback.rating, 5);
    });

    test('should return ServerFailure when remote throws', () async {
      when(() => mockRemote.createFeedback(any()))
          .thenThrow(ServerException());

      final result = await repository.submitRating(
        'session1', 'reviewer1', 'Alice', 'reviewee1', 'Bob', 4,
      );

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });

    test('should return ServerFailure on generic exception', () async {
      when(() => mockRemote.createFeedback(any())).thenThrow(Exception());

      final result = await repository.submitRating(
        'session1', 'reviewer1', 'Alice', 'reviewee1', 'Bob', 4,
      );

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('writeReview', () {
    test('should write review on success', () async {
      when(() => mockRemote.updateFeedback(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockRemote.getFeedback(any()))
          .thenAnswer((_) async => tFeedbackModel);

      final result = await repository.writeReview('feedback1', 'Great!');

      expect(result.isRight(), true);
      expect(result.getOrElse(() => tFeedbackModel), isA<FeedbackEntity>());
      verify(() => mockRemote.updateFeedback('feedback1', any())).called(1);
      verify(() => mockRemote.getFeedback('feedback1')).called(1);
    });

    test('should return ServerFailure when feedback not found', () async {
      when(() => mockRemote.updateFeedback(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockRemote.getFeedback(any()))
          .thenAnswer((_) async => null);

      final result = await repository.writeReview('feedback1', 'Great!');

      expect(result.isLeft(), true);
    });

    test('should return ServerFailure when remote throws on update', () async {
      when(() => mockRemote.updateFeedback(any(), any()))
          .thenThrow(ServerException());

      final result = await repository.writeReview('feedback1', 'Great!');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('viewReviews', () {
    final feedbacks = [tFeedbackModel];

    test('should fetch reviews on success', () async {
      when(() => mockRemote.fetchFeedbacksForUser(any()))
          .thenAnswer((_) async => feedbacks);

      final result = await repository.viewReviews('reviewee1');

      expect(result.isRight(), true);
      expect(result.getOrElse(() => []), isA<List<FeedbackEntity>>());
      verify(() => mockRemote.fetchFeedbacksForUser('reviewee1')).called(1);
    });

    test('should filter by minRating', () async {
      when(() => mockRemote.fetchFeedbacksForUser(any()))
          .thenAnswer((_) async => feedbacks);

      final result = await repository.viewReviews('reviewee1', minRating: 5);

      expect(result.isRight(), true);
      expect(result.getOrElse(() => []), isEmpty);
    });

    test('should filter by maxRating', () async {
      when(() => mockRemote.fetchFeedbacksForUser(any()))
          .thenAnswer((_) async => feedbacks);

      final result = await repository.viewReviews('reviewee1', maxRating: 3);

      expect(result.isRight(), true);
      expect(result.getOrElse(() => []), isEmpty);
    });

    test('should return ServerFailure when remote throws', () async {
      when(() => mockRemote.fetchFeedbacksForUser(any()))
          .thenThrow(ServerException());

      final result = await repository.viewReviews('reviewee1');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('editReview', () {
    test('should edit review on success', () async {
      final editableFeedback = FeedbackModel(
        id: 'feedback1',
        sessionId: 'session1',
        reviewerId: 'reviewer1',
        reviewerName: 'Alice',
        revieweeId: 'reviewee1',
        revieweeName: 'Bob',
        rating: 4,
        review: 'Original',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      );

      when(() => mockRemote.getFeedback(any()))
          .thenAnswer((_) async => editableFeedback);
      when(() => mockRemote.updateFeedback(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockRemote.getFeedback(any()))
          .thenAnswer((_) async => editableFeedback);

      final result = await repository.editReview('feedback1', 'Updated!');

      expect(result.isRight(), true);
      verify(() => mockRemote.updateFeedback('feedback1', any())).called(1);
    });

    test('should return ServerFailure when feedback not found', () async {
      when(() => mockRemote.getFeedback(any()))
          .thenAnswer((_) async => null);

      final result = await repository.editReview('feedback1', 'Updated!');

      expect(result.isLeft(), true);
    });

    test('should return ServerFailure when 48h has passed', () async {
      final oldFeedback = FeedbackModel(
        id: 'feedback1',
        sessionId: 'session1',
        reviewerId: 'reviewer1',
        reviewerName: 'Alice',
        revieweeId: 'reviewee1',
        revieweeName: 'Bob',
        rating: 4,
        review: 'Original',
        createdAt: DateTime.now().subtract(const Duration(hours: 49)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 49)),
      );

      when(() => mockRemote.getFeedback(any()))
          .thenAnswer((_) async => oldFeedback);

      final result = await repository.editReview('feedback1', 'Updated!');

      expect(result.isLeft(), true);
      expect(
        result.fold((l) => l.message, (r) => null),
        contains('48 hours'),
      );
    });

    test('should return ServerFailure when remote throws on get', () async {
      when(() => mockRemote.getFeedback(any()))
          .thenThrow(ServerException());

      final result = await repository.editReview('feedback1', 'Updated!');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('respondToReview', () {
    test('should respond to review on success', () async {
      when(() => mockRemote.updateFeedback(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockRemote.getFeedback(any()))
          .thenAnswer((_) async => tFeedbackModel);

      final result = await repository.respondToReview('feedback1', 'Thanks!');

      expect(result.isRight(), true);
      expect(result.getOrElse(() => tFeedbackModel), isA<FeedbackEntity>());
      verify(() => mockRemote.updateFeedback('feedback1', any())).called(1);
      verify(() => mockRemote.getFeedback('feedback1')).called(1);
    });

    test('should return ServerFailure when feedback not found', () async {
      when(() => mockRemote.updateFeedback(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockRemote.getFeedback(any()))
          .thenAnswer((_) async => null);

      final result = await repository.respondToReview('feedback1', 'Thanks!');

      expect(result.isLeft(), true);
    });

    test('should return ServerFailure when remote throws', () async {
      when(() => mockRemote.updateFeedback(any(), any()))
          .thenThrow(ServerException());

      final result = await repository.respondToReview('feedback1', 'Thanks!');

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });
}
