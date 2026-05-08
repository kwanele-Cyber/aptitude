import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/feedback/domain/entities/feedback_entity.dart';
import 'package:myapp/features/feedback/domain/usecases/edit_review_usecase.dart';
import 'package:myapp/features/feedback/domain/usecases/respond_to_review_usecase.dart';
import 'package:myapp/features/feedback/domain/usecases/submit_rating_usecase.dart';
import 'package:myapp/features/feedback/domain/usecases/view_reviews_usecase.dart';
import 'package:myapp/features/feedback/domain/usecases/write_review_usecase.dart';
import 'package:myapp/features/feedback/presentation/bloc/feedback_bloc.dart';
import 'package:myapp/features/feedback/presentation/bloc/feedback_event.dart';
import 'package:myapp/features/feedback/presentation/bloc/feedback_state.dart';
import 'package:bloc_test/bloc_test.dart';

class MockSubmitRatingUseCase extends Mock implements SubmitRatingUseCase {}

class MockWriteReviewUseCase extends Mock implements WriteReviewUseCase {}

class MockViewReviewsUseCase extends Mock implements ViewReviewsUseCase {}

class MockEditReviewUseCase extends Mock implements EditReviewUseCase {}

class MockRespondToReviewUseCase extends Mock
    implements RespondToReviewUseCase {}

final tFeedback = FeedbackEntity(
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
  late FeedbackBloc bloc;
  late MockSubmitRatingUseCase mockSubmitRating;
  late MockWriteReviewUseCase mockWriteReview;
  late MockViewReviewsUseCase mockViewReviews;
  late MockEditReviewUseCase mockEditReview;
  late MockRespondToReviewUseCase mockRespondToReview;

  setUpAll(() {
    registerFallbackValue(const SubmitRatingParams(
      sessionId: '',
      reviewerId: '',
      reviewerName: '',
      revieweeId: '',
      revieweeName: '',
      rating: 1,
    ));
    registerFallbackValue(const WriteReviewParams(
      feedbackId: '',
      review: '',
    ));
    registerFallbackValue(const ViewReviewsParams(userId: ''));
    registerFallbackValue(const EditReviewParams(
      feedbackId: '',
      review: '',
    ));
    registerFallbackValue(const RespondToReviewParams(
      feedbackId: '',
      response: '',
    ));
  });

  setUp(() {
    mockSubmitRating = MockSubmitRatingUseCase();
    mockWriteReview = MockWriteReviewUseCase();
    mockViewReviews = MockViewReviewsUseCase();
    mockEditReview = MockEditReviewUseCase();
    mockRespondToReview = MockRespondToReviewUseCase();
    bloc = FeedbackBloc(
      submitRatingUseCase: mockSubmitRating,
      writeReviewUseCase: mockWriteReview,
      viewReviewsUseCase: mockViewReviews,
      editReviewUseCase: mockEditReview,
      respondToReviewUseCase: mockRespondToReview,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('SubmitRatingRequested', () {
    final event = SubmitRatingRequested(
      sessionId: 'session1',
      reviewerId: 'reviewer1',
      reviewerName: 'Alice',
      revieweeId: 'reviewee1',
      revieweeName: 'Bob',
      rating: 4,
    );

    blocTest<FeedbackBloc, FeedbackState>(
      'emits [FeedbackLoading, FeedbackRatingSubmitted] on success',
      build: () {
        when(() => mockSubmitRating(any()))
            .thenAnswer((_) async => Right(tFeedback));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        FeedbackLoading(),
        isA<FeedbackRatingSubmitted>(),
      ],
    );

    blocTest<FeedbackBloc, FeedbackState>(
      'emits [FeedbackLoading, FeedbackError] on failure',
      build: () {
        when(() => mockSubmitRating(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        FeedbackLoading(),
        FeedbackError(message: 'Failed to submit rating'),
      ],
    );
  });

  group('WriteReviewRequested', () {
    final event = WriteReviewRequested(
      feedbackId: 'feedback1',
      review: 'Great session!',
    );

    blocTest<FeedbackBloc, FeedbackState>(
      'emits [FeedbackLoading, FeedbackReviewWritten] on success',
      build: () {
        when(() => mockWriteReview(any()))
            .thenAnswer((_) async => Right(tFeedback));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        FeedbackLoading(),
        isA<FeedbackReviewWritten>(),
      ],
    );

    blocTest<FeedbackBloc, FeedbackState>(
      'emits [FeedbackLoading, FeedbackError] on failure',
      build: () {
        when(() => mockWriteReview(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        FeedbackLoading(),
        FeedbackError(message: 'Failed to write review'),
      ],
    );
  });

  group('ViewReviewsRequested', () {
    final event = ViewReviewsRequested(userId: 'reviewee1');

    blocTest<FeedbackBloc, FeedbackState>(
      'emits [FeedbackLoading, FeedbackReviewsLoaded] on success',
      build: () {
        when(() => mockViewReviews(any()))
            .thenAnswer((_) async => Right([tFeedback]));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        FeedbackLoading(),
        isA<FeedbackReviewsLoaded>(),
      ],
    );

    blocTest<FeedbackBloc, FeedbackState>(
      'emits [FeedbackLoading, FeedbackError] on failure',
      build: () {
        when(() => mockViewReviews(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        FeedbackLoading(),
        FeedbackError(message: 'Failed to fetch reviews'),
      ],
    );
  });

  group('EditReviewRequested', () {
    final event = EditReviewRequested(
      feedbackId: 'feedback1',
      review: 'Updated review',
    );

    blocTest<FeedbackBloc, FeedbackState>(
      'emits [FeedbackLoading, FeedbackReviewEdited] on success',
      build: () {
        when(() => mockEditReview(any()))
            .thenAnswer((_) async => Right(tFeedback));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        FeedbackLoading(),
        isA<FeedbackReviewEdited>(),
      ],
    );

    blocTest<FeedbackBloc, FeedbackState>(
      'emits [FeedbackLoading, FeedbackError] on failure',
      build: () {
        when(() => mockEditReview(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        FeedbackLoading(),
        FeedbackError(message: 'Failed to edit review'),
      ],
    );

    blocTest<FeedbackBloc, FeedbackState>(
      'emits [FeedbackLoading, FeedbackError] with server message on failure',
      build: () {
        when(() => mockEditReview(any()))
            .thenAnswer((_) async =>
                Left(ServerFailure('Review can only be edited within 48 hours of submission')));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        FeedbackLoading(),
        FeedbackError(
            message: 'Review can only be edited within 48 hours of submission'),
      ],
    );
  });

  group('RespondToReviewRequested', () {
    final event = RespondToReviewRequested(
      feedbackId: 'feedback1',
      response: 'Thank you!',
    );

    blocTest<FeedbackBloc, FeedbackState>(
      'emits [FeedbackLoading, FeedbackResponseSubmitted] on success',
      build: () {
        when(() => mockRespondToReview(any()))
            .thenAnswer((_) async => Right(tFeedback));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        FeedbackLoading(),
        isA<FeedbackResponseSubmitted>(),
      ],
    );

    blocTest<FeedbackBloc, FeedbackState>(
      'emits [FeedbackLoading, FeedbackError] on failure',
      build: () {
        when(() => mockRespondToReview(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        FeedbackLoading(),
        FeedbackError(message: 'Failed to respond to review'),
      ],
    );
  });
}
