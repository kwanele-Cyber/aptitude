import 'package:uuid/uuid.dart';

enum SessionStatus { scheduled, completed, cancelled }

class Session {
  String sid;
  final String postId;
  final String teacherId;
  final String learnerId;
  final DateTime scheduledTime;
  final String? location;
  final SessionStatus status;

  Session({
    String? sid,
    required this.postId,
    required this.teacherId,
    required this.learnerId,
    required this.scheduledTime,
    this.location,
    required this.status,
  }) : sid = sid ?? const Uuid().v4();



  Map<String, dynamic> toJson() {
    return {
      'sid': sid,
      'postId': postId,
      'teacherId': teacherId,
      'learnerId': learnerId,
      'scheduledTime': scheduledTime.millisecondsSinceEpoch,
      'location': location,
      'status': status.name,
    };
  }

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      sid: json['sid'],
      postId: json['postId'],
      teacherId: json['teacherId'],
      learnerId: json['learnerId'],
      scheduledTime: DateTime.fromMillisecondsSinceEpoch(json['scheduledTime']),
      location: json['location'],
      status: SessionStatus.values.firstWhere((e) => e.name == json['status']),
    );
  }
}
