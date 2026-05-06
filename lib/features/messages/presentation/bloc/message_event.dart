part of 'message_bloc.dart';

abstract class MessageEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadMessages extends MessageEvent {
  final String userId1;
  final String userId2;

  LoadMessages({required this.userId1, required this.userId2});

  @override
  List<Object?> get props => [userId1, userId2];
}
class AddMessageReactionEvent extends MessageEvent {
  final String messageId;
  final String userId;
  final String emoji;

  AddMessageReactionEvent({
    required this.messageId,
    required this.userId,
    required this.emoji,
  });

  @override
  List<Object?> get props => [messageId, userId, emoji];
}

class RemoveMessageReactionEvent extends MessageEvent {
  final String messageId;
  final String userId;
  final String emoji;

  RemoveMessageReactionEvent({
    required this.messageId,
    required this.userId,
    required this.emoji,
  });

  @override
  List<Object?> get props => [messageId, userId, emoji];
}

class SetTypingIndicatorEvent extends MessageEvent {
  final String conversationId;
  final String userId;
  final bool isTyping;

  SetTypingIndicatorEvent({
    required this.conversationId,
    required this.userId,
    required this.isTyping,
  });

  @override
  List<Object?> get props => [conversationId, userId, isTyping];
}

class EditMessageEvent extends MessageEvent {
  final String messageId;
  final String newContent;
  final String roomId;

  EditMessageEvent({
    required this.messageId,
    required this.newContent,
    required this.roomId,
  });

  @override
  List<Object?> get props => [messageId, newContent, roomId];
}
class SendMessageEvent extends MessageEvent {
  final MessageEntity message;

  SendMessageEvent({required this.message});

  @override
  List<Object?> get props => [message];
}

class MessagesUpdated extends MessageEvent {
  final List<MessageEntity> messages;
  final String? error;

  MessagesUpdated({required this.messages, this.error});

  @override
  List<Object?> get props => [messages, error];
}

class MarkMessagesAsReadEvent extends MessageEvent {
  final String userId1;
  final String userId2;

  MarkMessagesAsReadEvent({required this.userId1, required this.userId2});

  @override
  List<Object?> get props => [userId1, userId2];
}