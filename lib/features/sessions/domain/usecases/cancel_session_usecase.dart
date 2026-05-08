import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/sessions/domain/entity/session_entity.dart';
import 'package:myapp/features/sessions/domain/repository/session_repository.dart';

class CancelSessionUseCase
    implements UseCase<SessionEntity, CancelSessionParams> {
  final SessionRepository repository;

  CancelSessionUseCase({required this.repository});

  @override
  Future<Either<Failure, SessionEntity>> call(
      CancelSessionParams params) async {
    if (!params.session.canCancel(DateTime.now())) {
      final restriction =
          params.session.cancellationRestrictionMessage(DateTime.now());
      return Left(ServerFailure(
          restriction ?? 'Cannot cancel this session.'));
    }
    return repository.cancelSession(params.session.id, params.reason);
  }
}

class CancelSessionParams {
  final SessionEntity session;
  final String? reason;

  CancelSessionParams({required this.session, this.reason});
}
