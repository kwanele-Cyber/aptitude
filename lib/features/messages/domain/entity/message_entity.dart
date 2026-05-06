import 'package:equatable/equatable.dart';
import 'file_attachment_entity.dart';
import 'message_reaction_entity.dart';

class MessageEntity extends Equatable {
  final String id;
  final String senderId;
  final String receiverId;
  final String? roomId;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final List<FileAttachmentEntity> attachments;
  final List<MessageReactionEntity> reactions;
  final DateTime? editedAt;

  const MessageEntity({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.roomId,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.attachments = const [],
    this.reactions = const [],
    this.editedAt,
  });

  /// Check if message has been edited
  bool get isEdited => editedAt != null;

  /// Get unique reactions with counts
  Map<String, int> get reactionSummary {
    final summary = <String, int>{};
    for (final reaction in reactions) {
      summary[reaction.emoji] = (summary[reaction.emoji] ?? 0) + 1;
    }
    return summary;
  }

  /// Get users who reacted with specific emoji
  List<String> getUsersForReaction(String emoji) {
    return reactions
        .where((r) => r.emoji == emoji)
        .map((r) => r.userId)
        .toList();
  }

  @override
  List<Object?> get props => [
        id,
        senderId,
        receiverId,
        roomId,
        content,
        timestamp,
        isRead,
        attachments,
        reactions,
        editedAt,
      ];
}
