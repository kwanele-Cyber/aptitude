
enum SessionStatus { scheduled, completed, cancelled }

class Session {
  final String sid;
  final String postId;
  final String teacherId;
  final String learnerId;
  final DateTime scheduledTime;
  final String? location;
  final SessionStatus status;

  Session({
    required this.sid,
    required this.postId,
    required this.teacherId,
    required this.learnerId,
    required this.scheduledTime,
    this.location,
    required this.status,
  });
}
