import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/feedback/domain/entities/feedback_entity.dart';
import 'package:myapp/features/feedback/domain/repository/feedback_repository.dart';

class ViewReviewsUseCase {
  final FeedbackRepository repository;

  ViewReviewsUseCase({required this.repository});

  Future<Either<Failure, List<FeedbackEntity>>> call(
      ViewReviewsParams params) async {
    return repository.viewReviews(
      params.userId,
      minRating: params.minRating,
      maxRating: params.maxRating,
    );
  }
}

class ViewReviewsParams extends Equatable {
  final String userId;
  final int? minRating;
  final int? maxRating;

  const ViewReviewsParams({
    required this.userId,
    this.minRating,
    this.maxRating,
  });

  @override
  List<Object?> get props => [userId, minRating, maxRating];
}
