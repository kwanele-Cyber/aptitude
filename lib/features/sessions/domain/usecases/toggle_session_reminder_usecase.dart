import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/sessions/domain/entity/session_entity.dart';
import 'package:myapp/features/sessions/domain/repository/session_repository.dart';

class ToggleSessionReminderUseCase
    implements UseCase<SessionEntity, ToggleSessionReminderParams> {
  final SessionRepository repository;

  ToggleSessionReminderUseCase({required this.repository});

  @override
  Future<Either<Failure, SessionEntity>> call(
      ToggleSessionReminderParams params) async {
    return repository.toggleReminders(params.id, params.enabled);
  }
}

class ToggleSessionReminderParams {
  final String id;
  final bool enabled;

  ToggleSessionReminderParams({required this.id, required this.enabled});
}
