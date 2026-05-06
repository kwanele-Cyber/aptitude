import 'package:myapp/features/messages/domain/entity/message_entity.dart';
import 'package:myapp/features/messages/domain/entity/file_attachment_entity.dart';
import 'package:myapp/features/messages/domain/entity/message_reaction_entity.dart';

class FileAttachmentModel extends FileAttachmentEntity {
  const FileAttachmentModel({
    required super.id,
    required super.fileName,
    required super.fileUrl,
    required super.fileSizeBytes,
    required super.mimeType,
    required super.uploadedAt,
  });

  factory FileAttachmentModel.fromJson(Map<String, dynamic> json) {
    return FileAttachmentModel(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      fileUrl: json['fileUrl'] as String,
      fileSizeBytes: json['fileSizeBytes'] as int,
      mimeType: json['mimeType'] as String,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileSizeBytes': fileSizeBytes,
      'mimeType': mimeType,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }
}

class MessageReactionModel extends MessageReactionEntity {
  const MessageReactionModel({
    required super.messageId,
    required super.userId,
    required super.emoji,
    required super.addedAt,
  });

  factory MessageReactionModel.fromJson(Map<String, dynamic> json) {
    return MessageReactionModel(
      messageId: json['messageId'] as String,
      userId: json['userId'] as String,
      emoji: json['emoji'] as String,
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'userId': userId,
      'emoji': emoji,
      'addedAt': addedAt.toIso8601String(),
    };
  }
}

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.senderId,
    required super.receiverId,
    super.roomId,
    required super.content,
    required super.timestamp,
    super.isRead,
    super.attachments,
    super.reactions,
    super.editedAt,
  });

  factory MessageModel.fromJson(String id, Map<String, dynamic> json) {
    final attachmentsData = json['attachments'] as List? ?? [];
    final attachments = attachmentsData
        .cast<Map<String, dynamic>>()
        .map((a) => FileAttachmentModel.fromJson(a))
        .toList();

    final reactionsData = json['reactions'] as List? ?? [];
    final reactions = reactionsData
        .cast<Map<String, dynamic>>()
        .map((r) => MessageReactionModel.fromJson(r))
        .toList();

    return MessageModel(
      id: id,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      roomId: json['roomId'] as String?,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool? ?? false,
      attachments: attachments,
      reactions: reactions,
      editedAt: json['editedAt'] != null
          ? DateTime.parse(json['editedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      if (roomId != null) 'roomId': roomId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      if (attachments.isNotEmpty)
        'attachments': attachments.map((a) => a.toJson()).toList(),
      if (reactions.isNotEmpty)
        'reactions': reactions.map((r) => r.toJson()).toList(),
      if (editedAt != null) 'editedAt': editedAt!.toIso8601String(),
    };
  }
}
