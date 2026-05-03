enum SessionStatus { scheduled, completed, cancelled, inProgress }

enum SessionFormat { online, inPerson, hybrid }

enum AttendanceVerificationMethod { code, qr, geolocation, manual }

class AttendanceRecord {
  final String userId;
  final DateTime checkedInAt;
  final AttendanceVerificationMethod method;
  final String? verificationCode;
  final double? latitude;
  final double? longitude;

  AttendanceRecord({
    required this.userId,
    required this.checkedInAt,
    required this.method,
    this.verificationCode,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'checkedInAt': checkedInAt.toIso8601String(),
      'method': method.index,
      'verificationCode': verificationCode,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      userId: json['userId'] as String,
      checkedInAt: DateTime.parse(json['checkedInAt'] as String),
      method: AttendanceVerificationMethod.values[json['method'] as int? ?? 0],
      verificationCode: json['verificationCode'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}

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
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? verificationCode;
  final Map<String, AttendanceRecord> attendanceRecords;

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
    this.startedAt,
    this.completedAt,
    this.verificationCode,
    this.attendanceRecords = const {},
  });

  bool get isFull => attendeeIds.length >= capacity;
  bool get hasStarted => status == SessionStatus.inProgress;
  bool get isComplete => status == SessionStatus.completed;

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
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'verificationCode': verificationCode,
      'attendanceRecords': attendanceRecords.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
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
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      verificationCode: json['verificationCode'] as String?,
      attendanceRecords:
          (json['attendanceRecords'] as Map?)?.map(
            (key, value) => MapEntry(
              key.toString(),
              AttendanceRecord.fromJson(
                Map<String, dynamic>.from(value as Map),
              ),
            ),
          ) ??
          const {},
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
    DateTime? startedAt,
    DateTime? completedAt,
    String? verificationCode,
    Map<String, AttendanceRecord>? attendanceRecords,
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
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      verificationCode: verificationCode ?? this.verificationCode,
      attendanceRecords: attendanceRecords ?? this.attendanceRecords,
    );
  }
}
