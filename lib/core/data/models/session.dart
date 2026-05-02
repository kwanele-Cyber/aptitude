enum SessionStatus { scheduled, completed, cancelled }

class Session {
  final String id;
  final String agreementId;
  final String title;
  final DateTime startTime;
  final int durationMinutes;
  final SessionStatus status;
  final String location; // Could be a physical address or a meeting link
  final String? notes;
  final bool isRated;

  Session({
    required this.id,
    required this.agreementId,
    required this.title,
    required this.startTime,
    required this.durationMinutes,
    this.status = SessionStatus.scheduled,
    this.location = 'Online',
    this.notes,
    this.isRated = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agreementId': agreementId,
      'title': title,
      'startTime': startTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'status': status.index,
      'location': location,
      'notes': notes,
      'isRated': isRated,
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
      location: json['location'] as String? ?? 'Online',
      notes: json['notes'] as String?,
      isRated: json['isRated'] as bool? ?? false,
    );
  }

  Session copyWith({
    SessionStatus? status,
    String? notes,
    DateTime? startTime,
    int? durationMinutes,
    String? location,
    bool? isRated,
  }) {
    return Session(
      id: id,
      agreementId: agreementId,
      title: title,
      startTime: startTime ?? this.startTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      isRated: isRated ?? this.isRated,
    );
  }
}
