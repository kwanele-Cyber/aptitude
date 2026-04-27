enum InviteStatus {
  pending,
  accepted,
  rejected;

  String get name => toString().split('.').last;

  static InviteStatus fromString(String status) {
    return InviteStatus.values.firstWhere(
      (e) => e.name == status.toLowerCase(),
      orElse: () => InviteStatus.pending,
    );
  }
}

class Invite {
  final String id;
  final String from;
  final String to;
  final String fromName;
  final String toName;
  final List<String> commonSkills;
  final InviteStatus status;
  final String createdAt;

  Invite({
    required this.id,
    required this.from,
    required this.to,
    required this.fromName,
    required this.toName,
    required this.commonSkills,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from': from,
      'to': to,
      'fromName': fromName,
      'toName': toName,
      'commonSkills': commonSkills,
      'status': status.name,
      'createdAt': createdAt,
    };
  }

  factory Invite.fromJson(Map<String, dynamic> json) {
    return Invite(
      id: json['id'] ?? '',
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      fromName: json['fromName'] ?? '',
      toName: json['toName'] ?? '',
      commonSkills: List<String>.from(json['commonSkills'] ?? []),
      status: InviteStatus.fromString(json['status'] ?? 'pending'),
      createdAt: json['createdAt'] ?? '',
    );
  }
}
