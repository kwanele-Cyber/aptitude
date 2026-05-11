import 'package:myapp/features/sessions/domain/entity/session_entity.dart';

class SessionModel extends SessionEntity {
  const SessionModel({
    required super.id,
    required super.matchId,
    required super.skillId,
    required super.skillTitle,
    required super.initiatorId,
    required super.participantId,
    required super.participantName,
    required super.scheduledStart,
    required super.scheduledEnd,
    required super.format,
    super.status,
    super.cancellationPolicy,
    super.location,
    super.meetingLink,
    super.notes,
    super.recurrencePattern,
    super.maxParticipants,
    super.waitlistUserIds,
    super.remindersEnabled,
    super.cancelledAt,
    super.cancelReason,
    super.confirmedAt,
    super.startedAt,
    super.completedAt,
    super.verificationCode,
    super.initiatorVerified,
    super.participantVerified,
    required super.createdAt,
    required super.updatedAt,
  });

  factory SessionModel.fromJson(String id, Map<String, dynamic> json) {
    final docId = json['id'] as String? ?? json['uid'] as String? ?? id;
    return SessionModel(
      id: docId,
      matchId: json['matchId'] as String? ?? '',
      skillId: json['skillId'] as String? ?? '',
      skillTitle: json['skillTitle'] as String? ?? '',
      initiatorId: json['initiatorId'] as String? ?? '',
      participantId: json['participantId'] as String? ?? '',
      participantName: json['participantName'] as String? ?? '',
      scheduledStart: DateTime.parse(json['scheduledStart'] as String),
      scheduledEnd: DateTime.parse(json['scheduledEnd'] as String),
      format: parseFormat(json['format'] as String?),
      status: parseStatus(json['status'] as String?),
      cancellationPolicy:
          parseCancellationPolicy(json['cancellationPolicy'] as String?),
      location: json['location'] as String?,
      meetingLink: json['meetingLink'] as String?,
      notes: json['notes'] as String?,
      recurrencePattern:
          parseRecurrencePattern(json['recurrencePattern'] as String?),
      maxParticipants: (json['maxParticipants'] as num?)?.toInt(),
      waitlistUserIds: (json['waitlistUserIds'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      remindersEnabled: json['remindersEnabled'] as bool? ?? true,
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.tryParse(json['cancelledAt'] as String)
          : null,
      cancelReason: json['cancelReason'] as String?,
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.tryParse(json['confirmedAt'] as String)
          : null,
      startedAt: json['startedAt'] != null
          ? DateTime.tryParse(json['startedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
      verificationCode: json['verificationCode'] as String?,
      initiatorVerified: json['initiatorVerified'] as bool? ?? false,
      participantVerified: json['participantVerified'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id':id,
      'matchId': matchId,
      'skillId': skillId,
      'skillTitle': skillTitle,
      'initiatorId': initiatorId,
      'participantId': participantId,
      'participantName': participantName,
      'scheduledStart': scheduledStart.toIso8601String(),
      'scheduledEnd': scheduledEnd.toIso8601String(),
      'format': format.name,
      'status': status.name,
      'cancellationPolicy': cancellationPolicy.name,
      'location': location,
      'meetingLink': meetingLink,
      'notes': notes,
      'recurrencePattern': recurrencePattern.name,
      'maxParticipants': maxParticipants,
      'waitlistUserIds': waitlistUserIds,
      'remindersEnabled': remindersEnabled,
      'cancelledAt': cancelledAt?.toIso8601String(),
      'cancelReason': cancelReason,
      'confirmedAt': confirmedAt?.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'verificationCode': verificationCode,
      'initiatorVerified': initiatorVerified,
      'participantVerified': participantVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static SessionFormat parseFormat(String? format) {
    switch (format) {
      case 'inPerson':
        return SessionFormat.inPerson;
      default:
        return SessionFormat.online;
    }
  }

  static SessionStatus parseStatus(String? status) {
    switch (status) {
      case 'confirmed':
        return SessionStatus.confirmed;
      case 'inProgress':
        return SessionStatus.inProgress;
      case 'completed':
        return SessionStatus.completed;
      case 'cancelled':
        return SessionStatus.cancelled;
      case 'noShow':
        return SessionStatus.noShow;
      default:
        return SessionStatus.scheduled;
    }
  }

  static CancellationPolicy parseCancellationPolicy(String? policy) {
    switch (policy) {
      case 'flexible':
        return CancellationPolicy.flexible;
      case 'strict':
        return CancellationPolicy.strict;
      default:
        return CancellationPolicy.moderate;
    }
  }

  static RecurrencePattern parseRecurrencePattern(String? pattern) {
    switch (pattern) {
      case 'daily':
        return RecurrencePattern.daily;
      case 'weekly':
        return RecurrencePattern.weekly;
      case 'biweekly':
        return RecurrencePattern.biweekly;
      case 'monthly':
        return RecurrencePattern.monthly;
      default:
        return RecurrencePattern.none;
    }
  }
}
