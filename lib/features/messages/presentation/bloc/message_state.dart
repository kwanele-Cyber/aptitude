part of 'message_bloc.dart';

abstract class MessageState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MessageInitial extends MessageState {}

class MessagesLoaded extends MessageState {
  final List<MessageEntity> messages;

  MessagesLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

class MessageError extends MessageState {
  final String message;

  MessageError(this.message);

  @override
  List<Object?> get props => [message];
}

class ReactionAdded extends MessageState {
  final String messageId;
  final String emoji;

  ReactionAdded({required this.messageId, required this.emoji});

  @override
  List<Object?> get props => [messageId, emoji];
}

class ReactionRemoved extends MessageState {
  final String messageId;
  final String emoji;

  ReactionRemoved({required this.messageId, required this.emoji});

  @override
  List<Object?> get props => [messageId, emoji];
}

class TypingIndicatorUpdated extends MessageState {
  final Map<String, bool> typingUsers;

  TypingIndicatorUpdated({required this.typingUsers});

  @override
  List<Object?> get props => [typingUsers];
}

class MessageEdited extends MessageState {
  final String messageId;

  MessageEdited({required this.messageId});

  @override
  List<Object?> get props => [messageId];
}
