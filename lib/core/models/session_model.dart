import 'package:myapp/core/models/location_model.dart';

enum SessionStatus { scheduled, completed, canceled }

class SessionModel {
  final String id;
  final String agreementId;
  final String title;
  final DateTime startTime;
  final double duration; // in hours
  final SessionStatus status;
  final LocationModel? location;
  final String? notes;

  SessionModel({
    required this.id,
    required this.agreementId,
    required this.title,
    required this.startTime,
    required this.duration,
    this.status = SessionStatus.scheduled,
    this.location,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'agreementId': agreementId,
        'title': title,
        'startTime': startTime.toIso8601String(),
        'duration': duration,
        'status': status.name,
        'location': location?.toJson(),
        'notes': notes,
      };

  factory SessionModel.fromJson(Map<String, dynamic> json) => SessionModel(
        id: json['id'] as String,
        agreementId: json['agreementId'] as String,
        title: json['title'] as String,
        startTime: DateTime.parse(json['startTime'] as String),
        duration: (json['duration'] as num).toDouble(),
        status: SessionStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => SessionStatus.scheduled,
        ),
        location: json['location'] != null
            ? LocationModel.fromJson(Map<String, dynamic>.from(json['location'] as Map))
            : null,
        notes: json['notes'] as String?,
      );

  SessionModel copyWith({
    String? id,
    String? agreementId,
    String? title,
    DateTime? startTime,
    double? duration,
    SessionStatus? status,
    LocationModel? location,
    String? notes,
  }) {
    return SessionModel(
      id: id ?? this.id,
      agreementId: agreementId ?? this.agreementId,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      status: status ?? this.status,
      location: location ?? this.location,
      notes: notes ?? this.notes,
    );
  }
}
