import 'package:equatable/equatable.dart';

class MatchFeedbackEntity extends Equatable {
  final String matchId;
  final String userId;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  const MatchFeedbackEntity({
    required this.matchId,
    required this.userId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [matchId, userId, rating, comment, createdAt];
}
