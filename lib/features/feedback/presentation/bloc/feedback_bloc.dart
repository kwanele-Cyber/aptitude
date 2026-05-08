import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/features/feedback/domain/usecases/edit_review_usecase.dart';
import 'package:myapp/features/feedback/domain/usecases/respond_to_review_usecase.dart';
import 'package:myapp/features/feedback/domain/usecases/submit_rating_usecase.dart';
import 'package:myapp/features/feedback/domain/usecases/view_reviews_usecase.dart';
import 'package:myapp/features/feedback/domain/usecases/write_review_usecase.dart';
import 'package:myapp/features/feedback/presentation/bloc/feedback_event.dart';
import 'package:myapp/features/feedback/presentation/bloc/feedback_state.dart';

class FeedbackBloc extends Bloc<FeedbackEvent, FeedbackState> {
  final SubmitRatingUseCase submitRatingUseCase;
  final WriteReviewUseCase writeReviewUseCase;
  final ViewReviewsUseCase viewReviewsUseCase;
  final EditReviewUseCase editReviewUseCase;
  final RespondToReviewUseCase respondToReviewUseCase;

  FeedbackBloc({
    required this.submitRatingUseCase,
    required this.writeReviewUseCase,
    required this.viewReviewsUseCase,
    required this.editReviewUseCase,
    required this.respondToReviewUseCase,
  }) : super(FeedbackInitial()) {
    on<SubmitRatingRequested>(_onSubmitRatingRequested);
    on<WriteReviewRequested>(_onWriteReviewRequested);
    on<ViewReviewsRequested>(_onViewReviewsRequested);
    on<EditReviewRequested>(_onEditReviewRequested);
    on<RespondToReviewRequested>(_onRespondToReviewRequested);
  }

  Future _onSubmitRatingRequested(
    SubmitRatingRequested event,
    Emitter<FeedbackState> emit,
  ) async {
    emit(FeedbackLoading());
    final result = await submitRatingUseCase(
      SubmitRatingParams(
        sessionId: event.sessionId,
        reviewerId: event.reviewerId,
        reviewerName: event.reviewerName,
        revieweeId: event.revieweeId,
        revieweeName: event.revieweeName,
        rating: event.rating,
      ),
    );

    await result.fold(
      (left) async {
        emit(FeedbackError(message: 'Failed to submit rating'));
      },
      (right) async {
        emit(FeedbackRatingSubmitted(feedback: right));
      },
    );
  }

  Future _onWriteReviewRequested(
    WriteReviewRequested event,
    Emitter<FeedbackState> emit,
  ) async {
    emit(FeedbackLoading());
    final result = await writeReviewUseCase(
      WriteReviewParams(
        feedbackId: event.feedbackId,
        review: event.review,
      ),
    );

    await result.fold(
      (left) async {
        emit(FeedbackError(message: 'Failed to write review'));
      },
      (right) async {
        emit(FeedbackReviewWritten(feedback: right));
      },
    );
  }

  Future _onViewReviewsRequested(
    ViewReviewsRequested event,
    Emitter<FeedbackState> emit,
  ) async {
    emit(FeedbackLoading());
    final result = await viewReviewsUseCase(
      ViewReviewsParams(
        userId: event.userId,
        minRating: event.minRating,
        maxRating: event.maxRating,
      ),
    );

    await result.fold(
      (left) async {
        emit(FeedbackError(message: 'Failed to fetch reviews'));
      },
      (right) async {
        emit(FeedbackReviewsLoaded(reviews: right));
      },
    );
  }

  Future _onEditReviewRequested(
    EditReviewRequested event,
    Emitter<FeedbackState> emit,
  ) async {
    emit(FeedbackLoading());
    final result = await editReviewUseCase(
      EditReviewParams(
        feedbackId: event.feedbackId,
        review: event.review,
      ),
    );

    await result.fold(
      (left) async {
        emit(FeedbackError(message: left.message ?? 'Failed to edit review'));
      },
      (right) async {
        emit(FeedbackReviewEdited(feedback: right));
      },
    );
  }

  Future _onRespondToReviewRequested(
    RespondToReviewRequested event,
    Emitter<FeedbackState> emit,
  ) async {
    emit(FeedbackLoading());
    final result = await respondToReviewUseCase(
      RespondToReviewParams(
        feedbackId: event.feedbackId,
        response: event.response,
      ),
    );

    await result.fold(
      (left) async {
        emit(FeedbackError(message: 'Failed to respond to review'));
      },
      (right) async {
        emit(FeedbackResponseSubmitted(feedback: right));
      },
    );
  }
}
