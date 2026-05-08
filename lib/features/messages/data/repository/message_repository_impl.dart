import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/messages/data/datasources/message_remote_datasource.dart';
import 'package:myapp/features/messages/data/models/message_model.dart';
import 'package:myapp/features/messages/domain/entity/inbox_conversation_entity.dart';
import 'package:myapp/features/messages/domain/entity/message_entity.dart';
import 'package:myapp/features/messages/domain/entity/room_entity.dart';
import 'package:myapp/features/messages/domain/repository/message_repository.dart';

class MessageRepositoryImpl implements MessageRepository {
  final MessageRemoteDataSource remoteDataSource;

  MessageRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> sendMessage(MessageEntity message) async {
    try {
      final messageModel = MessageModel(
        id: message.id,
        senderId: message.senderId,
        receiverId: message.receiverId,
        roomId: message.roomId,
        content: message.content,
        timestamp: message.timestamp,
        isRead: message.isRead,
      );
      await remoteDataSource.sendMessage(messageModel);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Stream<Either<Failure, List<MessageEntity>>> getMessages(String userId1, String userId2) async* {
    try {
      await for (final messages in remoteDataSource.getMessages(userId1, userId2)) {
        yield Right(messages);
      }
    } on ServerException {
      yield Left(ServerFailure());
    } catch (_) {
      yield Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> markMessagesAsRead(String userId1, String userId2) async {
    try {
      await remoteDataSource.markMessagesAsRead(userId1, userId2);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Stream<Either<Failure, List<InboxConversationEntity>>> watchInbox(String userId) async* {
    try {
      await for (final conversations in remoteDataSource.watchInbox(userId)) {
        yield Right(conversations);
      }
    } on ServerException {
      yield Left(ServerFailure());
    } catch (_) {
      yield Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, String>> createRoom(RoomEntity room) async {
    try {
      final roomId = await remoteDataSource.createRoom(room);
      return Right(roomId);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> sendRoomMessage(String roomId, MessageEntity message) async {
    try {
      final messageModel = MessageModel(
        id: message.id,
        senderId: message.senderId,
        receiverId: message.receiverId,
        roomId: roomId,
        content: message.content,
        timestamp: message.timestamp,
        isRead: message.isRead,
      );
      await remoteDataSource.sendRoomMessage(roomId, messageModel);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Stream<Either<Failure, List<MessageEntity>>> getRoomMessages(String roomId) async* {
    try {
      await for (final messages in remoteDataSource.getRoomMessages(roomId)) {
        yield Right(messages);
      }
    } on ServerException {
      yield Left(ServerFailure());
    } catch (_) {
      yield Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> addMessageReaction({
    required String messageId,
    required String userId,
    required String emoji,
  }) async {
    try {
      await remoteDataSource.addMessageReaction(
        messageId: messageId,
        userId: userId,
        emoji: emoji,
      );
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> removeMessageReaction({
    required String messageId,
    required String userId,
    required String emoji,
  }) async {
    try {
      await remoteDataSource.removeMessageReaction(
        messageId: messageId,
        userId: userId,
        emoji: emoji,
      );
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> editMessage({
    required String messageId,
    required String newContent,
    required String roomId,
  }) async {
    try {
      await remoteDataSource.editMessage(
        messageId: messageId,
        newContent: newContent,
        roomId: roomId,
      );
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> setTypingIndicator({
    required String conversationId,
    required String userId,
    required bool isTyping,
  }) async {
    try {
      await remoteDataSource.setTypingIndicator(
        conversationId: conversationId,
        userId: userId,
        isTyping: isTyping,
      );
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Stream<Either<Failure, Map<String, bool>>> watchTypingIndicator({
    required String conversationId,
  }) async* {
    try {
      await for (final typingStatus
          in remoteDataSource.watchTypingIndicator(conversationId: conversationId)) {
        yield Right(typingStatus);
      }
    } on ServerException {
      yield Left(ServerFailure());
    } catch (_) {
      yield Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> blockUser(
      String currentUserId, String blockedUserId, String blockedUserName) async {
    try {
      await remoteDataSource.blockUser(currentUserId, blockedUserId, blockedUserName);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> unblockUser(
      String currentUserId, String blockedUserId) async {
    try {
      await remoteDataSource.unblockUser(currentUserId, blockedUserId);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Stream<Either<Failure, List<String>>> getBlockedUserIds(String userId) async* {
    try {
      await for (final ids in remoteDataSource.getBlockedUserIds(userId)) {
        yield Right(ids);
      }
    } on ServerException {
      yield Left(ServerFailure());
    } catch (_) {
      yield Left(ServerFailure());
    }
  }
}
