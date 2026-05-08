import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/core/usecases/usecase.dart';
import 'package:myapp/features/sessions/domain/entity/session_entity.dart';
import 'package:myapp/features/sessions/domain/repository/session_repository.dart';

class CreateSessionUseCase
    implements UseCase<SessionEntity, CreateSessionParams> {
  final SessionRepository repository;

  CreateSessionUseCase({required this.repository});

  @override
  Future<Either<Failure, SessionEntity>> call(
      CreateSessionParams params) async {
    return repository.createSession({
      'matchId': params.matchId,
      'skillId': params.skillId,
      'skillTitle': params.skillTitle,
      'initiatorId': params.initiatorId,
      'participantId': params.participantId,
      'participantName': params.participantName,
      'scheduledStart': params.scheduledStart.toIso8601String(),
      'scheduledEnd': params.scheduledEnd.toIso8601String(),
      'format': params.format.name,
      'cancellationPolicy': params.cancellationPolicy.name,
      'location': params.location,
      'meetingLink': params.meetingLink,
      'notes': params.notes,
      'recurrencePattern': params.recurrencePattern.name,
      'maxParticipants': params.maxParticipants,
      'remindersEnabled': params.remindersEnabled,
    });
  }
}

class CreateSessionParams {
  final String matchId;
  final String skillId;
  final String skillTitle;
  final String initiatorId;
  final String participantId;
  final String participantName;
  final DateTime scheduledStart;
  final DateTime scheduledEnd;
  final SessionFormat format;
  final CancellationPolicy cancellationPolicy;
  final String? location;
  final String? meetingLink;
  final String? notes;
  final RecurrencePattern recurrencePattern;
  final int? maxParticipants;
  final bool remindersEnabled;

  CreateSessionParams({
    required this.matchId,
    required this.skillId,
    required this.skillTitle,
    required this.initiatorId,
    required this.participantId,
    required this.participantName,
    required this.scheduledStart,
    required this.scheduledEnd,
    required this.format,
    this.cancellationPolicy = CancellationPolicy.moderate,
    this.location,
    this.meetingLink,
    this.notes,
    this.recurrencePattern = RecurrencePattern.none,
    this.maxParticipants,
    this.remindersEnabled = true,
  });
}
