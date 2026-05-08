import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/sessions/domain/entity/session_entity.dart';
import 'package:myapp/features/sessions/domain/repository/session_repository.dart';

class UpdateSessionUseCase
    implements UseCase<SessionEntity, UpdateSessionParams> {
  final SessionRepository repository;

  UpdateSessionUseCase({required this.repository});

  @override
  Future<Either<Failure, SessionEntity>> call(
      UpdateSessionParams params) async {
    final data = <String, dynamic>{};
    if (params.scheduledStart != null) {
      data['scheduledStart'] = params.scheduledStart!.toIso8601String();
    }
    if (params.scheduledEnd != null) {
      data['scheduledEnd'] = params.scheduledEnd!.toIso8601String();
    }
    if (params.format != null) data['format'] = params.format!.name;
    if (params.location != null) data['location'] = params.location;
    if (params.meetingLink != null) data['meetingLink'] = params.meetingLink;
    if (params.notes != null) data['notes'] = params.notes;
    if (params.maxParticipants != null) {
      data['maxParticipants'] = params.maxParticipants;
    }

    return repository.updateSession(params.id, data);
  }
}

class UpdateSessionParams {
  final String id;
  final DateTime? scheduledStart;
  final DateTime? scheduledEnd;
  final SessionFormat? format;
  final String? location;
  final String? meetingLink;
  final String? notes;
  final int? maxParticipants;

  UpdateSessionParams({
    required this.id,
    this.scheduledStart,
    this.scheduledEnd,
    this.format,
    this.location,
    this.meetingLink,
    this.notes,
    this.maxParticipants,
  });
}
