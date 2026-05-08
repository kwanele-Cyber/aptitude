import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/feedback/domain/entities/feedback_entity.dart';
import 'package:myapp/features/feedback/domain/repository/feedback_repository.dart';

class SubmitRatingUseCase {
  final FeedbackRepository repository;

  SubmitRatingUseCase({required this.repository});

  Future<Either<Failure, FeedbackEntity>> call(SubmitRatingParams params) async {
    return repository.submitRating(
      params.sessionId,
      params.reviewerId,
      params.reviewerName,
      params.revieweeId,
      params.revieweeName,
      params.rating,
    );
  }
}

class SubmitRatingParams extends Equatable {
  final String sessionId;
  final String reviewerId;
  final String reviewerName;
  final String revieweeId;
  final String revieweeName;
  final int rating;

  const SubmitRatingParams({
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
