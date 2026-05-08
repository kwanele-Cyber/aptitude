import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/sessions/domain/entity/session_entity.dart';
import 'package:myapp/features/sessions/domain/repository/session_repository.dart';

class GenerateVerificationCodeUseCase
    implements UseCase<SessionEntity, GenerateVerificationCodeParams> {
  final SessionRepository repository;

  GenerateVerificationCodeUseCase({required this.repository});

  @override
  Future<Either<Failure, SessionEntity>> call(
      GenerateVerificationCodeParams params) async {
    return repository.generateVerificationCode(params.sessionId, params.userId);
  }
}

class GenerateVerificationCodeParams {
  final String sessionId;
  final String userId;

  GenerateVerificationCodeParams({
    required this.sessionId,
    required this.userId,
  });
}
