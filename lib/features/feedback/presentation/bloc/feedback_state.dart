import 'package:equatable/equatable.dart';
import 'package:myapp/features/feedback/domain/entities/feedback_entity.dart';

abstract class FeedbackState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FeedbackInitial extends FeedbackState {}

class FeedbackLoading extends FeedbackState {}

class FeedbackRatingSubmitted extends FeedbackState {
  final FeedbackEntity feedback;

  FeedbackRatingSubmitted({required this.feedback});

  @override
  List<Object?> get props => [feedback];
}

class FeedbackReviewWritten extends FeedbackState {
  final FeedbackEntity feedback;

  FeedbackReviewWritten({required this.feedback});

  @override
  List<Object?> get props => [feedback];
}

class FeedbackReviewsLoaded extends FeedbackState {
  final List<FeedbackEntity> reviews;

  FeedbackReviewsLoaded({required this.reviews});

  @override
  List<Object?> get props => [reviews];
}

class FeedbackReviewEdited extends FeedbackState {
  final FeedbackEntity feedback;

  FeedbackReviewEdited({required this.feedback});

  @override
  List<Object?> get props => [feedback];
}

class FeedbackResponseSubmitted extends FeedbackState {
  final FeedbackEntity feedback;

  FeedbackResponseSubmitted({required this.feedback});

  @override
  List<Object?> get props => [feedback];
}

class FeedbackError extends FeedbackState {
  final String message;

  FeedbackError({required this.message});

  @override
  List<Object?> get props => [message];
}
