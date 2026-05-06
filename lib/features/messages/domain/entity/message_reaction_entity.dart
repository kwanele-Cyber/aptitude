import 'package:equatable/equatable.dart';

class MessageReactionEntity extends Equatable {
  final String messageId;
  final String userId;
  final String emoji;
  final DateTime addedAt;

  const MessageReactionEntity({
    required this.messageId,
    required this.userId,
    required this.emoji,
    required this.addedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'userId': userId,
      'emoji': emoji,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [messageId, userId, emoji, addedAt];
}
