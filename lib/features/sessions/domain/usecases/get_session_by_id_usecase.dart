import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/sessions/domain/entity/session_entity.dart';
import 'package:myapp/features/sessions/domain/repository/session_repository.dart';

class GetSessionByIdUseCase
    implements UseCase<SessionEntity, GetSessionByIdParams> {
  final SessionRepository repository;

  GetSessionByIdUseCase({required this.repository});

  @override
  Future<Either<Failure, SessionEntity>> call(
      GetSessionByIdParams params) async {
    return repository.getSessionById(params.id);
  }
}

class GetSessionByIdParams {
  final String id;

  GetSessionByIdParams({required this.id});
}
