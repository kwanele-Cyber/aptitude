import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/features/messages/domain/entity/message_entity.dart';
import 'package:myapp/features/messages/domain/usecases/get_messages_usecase.dart';
import 'package:myapp/features/messages/domain/usecases/mark_messages_as_read_usecase.dart';
import 'package:myapp/features/messages/domain/usecases/send_message_usecase.dart';

part 'message_event.dart';
part 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final SendMessageUseCase sendMessageUseCase;
  final GetMessagesUseCase getMessagesUseCase;
  final MarkMessagesAsReadUseCase markMessagesAsReadUseCase;

  StreamSubscription? _messagesSubscription;

  MessageBloc({
    required this.sendMessageUseCase,
    required this.getMessagesUseCase,
    required this.markMessagesAsReadUseCase,
  }) : super(MessageInitial()) {
    on<LoadMessages>(_onLoadMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<MessagesUpdated>(_onMessagesUpdated);
    on<MarkMessagesAsReadEvent>(_onMarkMessagesAsRead);
  }

  void _onLoadMessages(LoadMessages event, Emitter<MessageState> emit) {
    _messagesSubscription?.cancel();
    _messagesSubscription = getMessagesUseCase(event.userId1, event.userId2).listen(
      (result) {
        result.fold(
          (failure) => add(MessagesUpdated(messages: [], error: failure.message)),
          (messages) => add(MessagesUpdated(messages: messages)),
        );
      },
      onError: (error) => add(MessagesUpdated(messages: [], error: error.toString())),
    );
  }

  void _onSendMessage(SendMessageEvent event, Emitter<MessageState> emit) async {
    final result = await sendMessageUseCase(SendMessageParams(message: event.message));
    result.fold(
      (failure) => emit(MessageError(failure.message ?? 'Failed to send message')),
      (_) => {}, // Message will be updated via stream
    );
  }

  void _onMessagesUpdated(MessagesUpdated event, Emitter<MessageState> emit) {
    if (event.error != null) {
      emit(MessageError(event.error!));
    } else {
      emit(MessagesLoaded(event.messages));
    }
  }

  void _onMarkMessagesAsRead(MarkMessagesAsReadEvent event, Emitter<MessageState> emit) async {
    await markMessagesAsReadUseCase(MarkMessagesAsReadParams(
      userId1: event.userId1,
      userId2: event.userId2,
    ));
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}