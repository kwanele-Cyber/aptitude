import 'package:intl/intl.dart';

class Complaint {
  final String id;
  final String reporterId;
  final String reporterName;
  final String reportedUserId;
  final String reportedUserName;
  final String violationType;
  final String description;
  final String status;
  final int strikeCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? adminNote;
  final String? adminId;

  Complaint({
    required this.id,
    required this.reporterId,
    required this.reporterName,
    required this.reportedUserId,
    required this.reportedUserName,
    required this.violationType,
    required this.description,
    required this.status,
    required this.strikeCount,
    required this.createdAt,
    this.updatedAt,
    this.adminNote,
    this.adminId,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'].toString(),
      reporterId: json['reporterId'].toString(),
      reporterName: json['reporterName'] ?? 'Unknown',
      reportedUserId: json['reportedUserId'].toString(),
      reportedUserName: json['reportedUserName'] ?? 'Unknown',
      violationType: json['violationType'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'pending',
      strikeCount: json['strikeCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      adminNote: json['adminNote'],
      adminId: json['adminId']?.toString(),
    );
  }

  String get formattedDate =>
      DateFormat('dd MMM yyyy, HH:mm').format(createdAt);
  String get formattedUpdatedDate => updatedAt != null
      ? DateFormat('dd MMM yyyy, HH:mm').format(updatedAt!)
      : '';
  bool get isBanned => strikeCount >= 3;
}

class ViolationType {
  static const List<Map<String, dynamic>> types = [
    {
      'value': 'HARASSMENT',
      'label': 'Harassment or Bullying',
      'icon': '😡',
      'description': 'Threatening, intimidating, or abusive behaviour',
    },
    {
      'value': 'FRAUD',
      'label': 'Fraud or Scamming',
      'icon': '🚨',
      'description': 'Deceptive practices or false skill claims',
    },
    {
      'value': 'INAPPROPRIATE_CONTENT',
      'label': 'Inappropriate Content',
      'icon': '🔞',
      'description': 'Offensive or inappropriate messages/profile content',
    },
    {
      'value': 'NO_SHOW',
      'label': 'No-Show / Ghosting',
      'icon': '👻',
      'description': 'Failed to show up for agreed skill exchange',
    },
    {
      'value': 'SPAM',
      'label': 'Spam or Advertising',
      'icon': '📢',
      'description': 'Unsolicited commercial messages or promotions',
    },
    {
      'value': 'FAKE_PROFILE',
      'label': 'Fake Profile / Impersonation',
      'icon': '🎭',
      'description': 'False identity or impersonating another person',
    },
    {
      'value': 'OTHER',
      'label': 'Other Violation',
      'icon': '⚠️',
      'description': 'Any other violation not listed above',
    },
  ];

  static String getLabel(String value) {
    final type = types.firstWhere(
      (t) => t['value'] == value,
      orElse: () => {'label': value},
    );
    return type['label'] ?? value;
  }

  static String getIcon(String value) {
    final type = types.firstWhere(
      (t) => t['value'] == value,
      orElse: () => {'icon': '⚠️'},
    );
    return type['icon'] ?? '⚠️';
  }
}

class UserSummary {
  final String id;
  final String name;
  final String email;
  final int strikeCount;
  final bool isBanned;
  final int complaintsAgainst;
  final int complaintsSubmitted;

  UserSummary({
    required this.id,
    required this.name,
    required this.email,
    required this.strikeCount,
    required this.isBanned,
    required this.complaintsAgainst,
    required this.complaintsSubmitted,
  });

  factory UserSummary.fromJson(Map<String, dynamic> json) {
    return UserSummary(
      id: json['id'].toString(),
      name: json['name'] ?? 'Unknown',
      email: json['email'] ?? '',
      strikeCount: json['strikeCount'] ?? 0,
      isBanned: json['banned'] ?? false,
      complaintsAgainst: json['complaintsAgainst'] ?? 0,
      complaintsSubmitted: json['complaintsSubmitted'] ?? 0,
    );
  }
}

class AppUser {
  final String id;
  final String name;
  final String email;
  final bool isAdmin;
  final int strikeCount;
  final bool isBanned;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.isAdmin,
    required this.strikeCount,
    required this.isBanned,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'].toString(),
      name: json['name'] ?? 'Unknown',
      email: json['email'] ?? '',
      isAdmin: json['admin'] ?? false,
      strikeCount: json['strikeCount'] ?? 0,
      isBanned: json['banned'] ?? false,
    );
  }
}