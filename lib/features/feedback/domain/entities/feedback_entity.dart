import 'package:equatable/equatable.dart';

class FeedbackEntity extends Equatable {
  final String id;
  final String sessionId;
  final String reviewerId;
  final String reviewerName;
  final String revieweeId;
  final String revieweeName;
  final int rating;
  final String? review;
  final String? response;
  final DateTime? respondedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FeedbackEntity({
    required this.id,
    required this.sessionId,
    required this.reviewerId,
    required this.reviewerName,
    required this.revieweeId,
    required this.revieweeName,
    required this.rating,
    this.review,
    this.response,
    this.respondedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get canEditReview =>
      DateTime.now().difference(createdAt).inHours < 48;

  @override
  List<Object?> get props => [
        id,
        sessionId,
        reviewerId,
        reviewerName,
        revieweeId,
        revieweeName,
        rating,
        review,
        response,
        respondedAt,
        createdAt,
        updatedAt,
      ];
}
