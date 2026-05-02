enum SessionStatus { scheduled, completed, cancelled }

enum SessionFormat { online, inPerson, hybrid }

class Session {
  final String id;
  final String agreementId;
  final String title;
  final DateTime startTime;
  final int durationMinutes;
  final SessionStatus status;
  final SessionFormat format;
  final String location; // Could be a physical address or a meeting link
  final String? notes;
  final bool isRated;
  final List<int> reminderOffsetsMinutes;
  final bool calendarSyncEnabled;
  final int capacity;
  final List<String> attendeeIds;
  final List<String> waitlistUserIds;
  final String? recurrenceGroupId;

  Session({
    required this.id,
    required this.agreementId,
    required this.title,
    required this.startTime,
    required this.durationMinutes,
    this.status = SessionStatus.scheduled,
    this.format = SessionFormat.online,
    this.location = 'Online',
    this.notes,
    this.isRated = false,
    this.reminderOffsetsMinutes = const [1440, 60],
    this.calendarSyncEnabled = false,
    this.capacity = 2,
    this.attendeeIds = const [],
    this.waitlistUserIds = const [],
    this.recurrenceGroupId,
  });

  bool get isFull => attendeeIds.length >= capacity;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agreementId': agreementId,
      'title': title,
      'startTime': startTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'status': status.index,
      'format': format.index,
      'location': location,
      'notes': notes,
      'isRated': isRated,
      'reminderOffsetsMinutes': reminderOffsetsMinutes,
      'calendarSyncEnabled': calendarSyncEnabled,
      'capacity': capacity,
      'attendeeIds': attendeeIds,
      'waitlistUserIds': waitlistUserIds,
      'recurrenceGroupId': recurrenceGroupId,
    };
  }

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as String,
      agreementId: json['agreementId'] as String,
      title: json['title'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      durationMinutes: json['durationMinutes'] as int,
      status: SessionStatus.values[json['status'] as int? ?? 0],
      format: SessionFormat.values[json['format'] as int? ?? 0],
      location: json['location'] as String? ?? 'Online',
      notes: json['notes'] as String?,
      isRated: json['isRated'] as bool? ?? false,
      reminderOffsetsMinutes:
          (json['reminderOffsetsMinutes'] as List?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [1440, 60],
      calendarSyncEnabled: json['calendarSyncEnabled'] as bool? ?? false,
      capacity: json['capacity'] as int? ?? 2,
      attendeeIds:
          (json['attendeeIds'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      waitlistUserIds:
          (json['waitlistUserIds'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      recurrenceGroupId: json['recurrenceGroupId'] as String?,
    );
  }

  Session copyWith({
    String? title,
    SessionStatus? status,
    SessionFormat? format,
    String? notes,
    DateTime? startTime,
    int? durationMinutes,
    String? location,
    bool? isRated,
    List<int>? reminderOffsetsMinutes,
    bool? calendarSyncEnabled,
    int? capacity,
    List<String>? attendeeIds,
    List<String>? waitlistUserIds,
    String? recurrenceGroupId,
  }) {
    return Session(
      id: id,
      agreementId: agreementId,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      format: format ?? this.format,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      isRated: isRated ?? this.isRated,
      reminderOffsetsMinutes:
          reminderOffsetsMinutes ?? this.reminderOffsetsMinutes,
      calendarSyncEnabled: calendarSyncEnabled ?? this.calendarSyncEnabled,
      capacity: capacity ?? this.capacity,
      attendeeIds: attendeeIds ?? this.attendeeIds,
      waitlistUserIds: waitlistUserIds ?? this.waitlistUserIds,
      recurrenceGroupId: recurrenceGroupId ?? this.recurrenceGroupId,
    );
  }
}
