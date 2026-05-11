import 'package:myapp/features/feedback/domain/entities/feedback_entity.dart';

class FeedbackModel extends FeedbackEntity {
  const FeedbackModel({
    required super.id,
    required super.sessionId,
    required super.reviewerId,
    required super.reviewerName,
    required super.revieweeId,
    required super.revieweeName,
    required super.rating,
    super.review,
    super.response,
    super.respondedAt,
    required super.createdAt,
    required super.updatedAt,
  });

  factory FeedbackModel.fromJson(String key, Map<String, dynamic> json) {
    final id = json['id'] as String? ?? json['uid'] as String? ?? key;
    return FeedbackModel(
      id: id,
      sessionId: json['sessionId'] as String? ?? '',
      reviewerId: json['reviewerId'] as String? ?? '',
      reviewerName: json['reviewerName'] as String? ?? '',
      revieweeId: json['revieweeId'] as String? ?? '',
      revieweeName: json['revieweeName'] as String? ?? '',
      rating: _parseRating(json['rating']),
      review: json['review'] as String?,
      response: json['response'] as String?,
      respondedAt: json['respondedAt'] != null
          ? DateTime.tryParse(json['respondedAt'] as String)
          : null,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'revieweeId': revieweeId,
      'revieweeName': revieweeName,
      'rating': rating,
      'review': review,
      'response': response,
      'respondedAt': respondedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static int _parseRating(dynamic rating) {
    if (rating is int) {
      return rating.clamp(1, 5);
    }
    if (rating is double) {
      return rating.round().clamp(1, 5);
    }
    return 1;
  }
}
