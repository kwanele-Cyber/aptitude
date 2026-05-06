import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/messages/domain/entity/room_entity.dart';
import 'package:myapp/features/messages/domain/repository/message_repository.dart';

class CreateRoomUseCase implements UseCase<String, CreateRoomParams> {
  final MessageRepository repository;

  CreateRoomUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(CreateRoomParams params) {
    return repository.createRoom(params.room);
  }
}

class CreateRoomParams {
  final RoomEntity room;

  const CreateRoomParams({required this.room});
}
