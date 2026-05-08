import 'package:equatable/equatable.dart';

abstract class FeedbackEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SubmitRatingRequested extends FeedbackEvent {
  final String sessionId;
  final String reviewerId;
  final String reviewerName;
  final String revieweeId;
  final String revieweeName;
  final int rating;

  SubmitRatingRequested({
    required this.sessionId,
    required this.reviewerId,
    required this.reviewerName,
    required this.revieweeId,
    required this.revieweeName,
    required this.rating,
  });

  @override
  List<Object?> get props => [
        sessionId,
        reviewerId,
        reviewerName,
        revieweeId,
        revieweeName,
        rating,
      ];
}

class WriteReviewRequested extends FeedbackEvent {
  final String feedbackId;
  final String review;

  WriteReviewRequested({
    required this.feedbackId,
    required this.review,
  });

  @override
  List<Object?> get props => [feedbackId, review];
}

class ViewReviewsRequested extends FeedbackEvent {
  final String userId;
  final int? minRating;
  final int? maxRating;

  ViewReviewsRequested({
    required this.userId,
    this.minRating,
    this.maxRating,
  });

  @override
  List<Object?> get props => [userId, minRating, maxRating];
}

class EditReviewRequested extends FeedbackEvent {
  final String feedbackId;
  final String review;

  EditReviewRequested({
    required this.feedbackId,
    required this.review,
  });

  @override
  List<Object?> get props => [feedbackId, review];
}

class RespondToReviewRequested extends FeedbackEvent {
  final String feedbackId;
  final String response;

  RespondToReviewRequested({
    required this.feedbackId,
    required this.response,
  });

  @override
  List<Object?> get props => [feedbackId, response];
}
