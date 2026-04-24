import 'package:uuid/uuid.dart';

class Review {
  String rid;
  final String reviewerId;
  final String revieweeId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  Review({
    String? rid,
    required this.reviewerId,
    required this.revieweeId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  }) : rid = rid ?? const Uuid().v4();



  Map<String, dynamic> toJson() {
    return {
      'rid': rid,
      'reviewerId': reviewerId,
      'revieweeId': revieweeId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      rid: json['rid'],
      reviewerId: json['reviewerId'],
      revieweeId: json['revieweeId'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
    );
  }
}
