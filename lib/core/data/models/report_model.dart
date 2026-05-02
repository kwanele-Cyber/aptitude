enum ReportReason {
  spam,
  harassment,
  inappropriateContent,
  fraud,
  other
}

class ReportModel {
  final String id;
  final String reporterId;
  final String reportedUserId;
  final ReportReason reason;
  final String description;
  final DateTime timestamp;
  final String? context; // e.g., "profile", "chat_channel_id"

  ReportModel({
    required this.id,
    required this.reporterId,
    required this.reportedUserId,
    required this.reason,
    required this.description,
    required this.timestamp,
    this.context,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporterId': reporterId,
      'reportedUserId': reportedUserId,
      'reason': reason.index,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'context': context,
    };
  }

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String,
      reporterId: json['reporterId'] as String,
      reportedUserId: json['reportedUserId'] as String,
      reason: ReportReason.values[json['reason'] as int? ?? 0],
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      context: json['context'] as String?,
    );
  }
}
