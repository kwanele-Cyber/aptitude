import 'package:equatable/equatable.dart';

class AdminUserEntity extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String status;
  final String joined;
  final int sessions;
  final double rating;
  final int reportsCount;
  final bool twoFactorEnabled;
  final double trustScore;

  String get name => '$firstName $lastName';
  String get initials => '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}';

  const AdminUserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    this.status = 'Active',
    this.joined = '',
    this.sessions = 0,
    this.rating = 0.0,
    this.reportsCount = 0,
    this.twoFactorEnabled = false,
    this.trustScore = 100.0,
  });

  @override
  List<Object?> get props => [id, firstName, lastName, email, role, status, joined, sessions, rating, reportsCount, twoFactorEnabled, trustScore];
}

class FlaggedContentEntity extends Equatable {
  final String id;
  final String priority;
  final String reason;
  final String preview;
  final String reportedBy;
  final String fromUser;
  final String timestamp;
  final String type;
  final String status;
  final String? contentId;

  const FlaggedContentEntity({
    required this.id,
    required this.priority,
    required this.reason,
    required this.preview,
    required this.reportedBy,
    required this.fromUser,
    required this.timestamp,
    required this.type,
    this.status = 'Pending',
    this.contentId,
  });

  @override
  List<Object?> get props => [id, priority, reason, preview, reportedBy, fromUser, timestamp, type, status, contentId];
}

class PenaltyEntity extends Equatable {
  final String id;
  final String severity;
  final String type;
  final String user;
  final String userId;
  final String reason;
  final String date;
  final String duration;
  final int strikes;
  final bool isActive;

  const PenaltyEntity({
    required this.id,
    required this.severity,
    required this.type,
    required this.user,
    required this.userId,
    required this.reason,
    required this.date,
    required this.duration,
    this.strikes = 0,
    this.isActive = true,
  });

  String get initials => user.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join().toUpperCase();

  @override
  List<Object?> get props => [id, severity, type, user, userId, reason, date, duration, strikes, isActive];
}

class AnalyticsDataEntity extends Equatable {
  final int newUsers;
  final int totalMatches;
  final int sessionsCompleted;
  final double avgRating;
  final double avgTrustScore;
  final double disputeRate;
  final List<double> userGrowth;
  final Map<String, double> matchSuccessByCategory;
  final double sessionCompletionRate;
  final double sessionCancelRate;
  final double sessionNoShowRate;
  final double sessionRescheduleRate;

  const AnalyticsDataEntity({
    this.newUsers = 0,
    this.totalMatches = 0,
    this.sessionsCompleted = 0,
    this.avgRating = 0.0,
    this.avgTrustScore = 0.0,
    this.disputeRate = 0.0,
    this.userGrowth = const [],
    this.matchSuccessByCategory = const {},
    this.sessionCompletionRate = 0.0,
    this.sessionCancelRate = 0.0,
    this.sessionNoShowRate = 0.0,
    this.sessionRescheduleRate = 0.0,
  });

  @override
  List<Object?> get props => [newUsers, totalMatches, sessionsCompleted, avgRating, avgTrustScore, disputeRate, userGrowth, matchSuccessByCategory, sessionCompletionRate, sessionCancelRate, sessionNoShowRate, sessionRescheduleRate];
}

class SystemConfigEntity extends Equatable {
  final Map<String, bool> featureFlags;
  final Map<String, double> matchParams;
  final Map<String, int> trustThresholds;
  final Map<String, int> generalSettings;

  const SystemConfigEntity({
    this.featureFlags = const {},
    this.matchParams = const {},
    this.trustThresholds = const {},
    this.generalSettings = const {},
  });

  @override
  List<Object?> get props => [featureFlags, matchParams, trustThresholds, generalSettings];
}

class SkillCategoryEntity extends Equatable {
  final String id;
  final String name;
  final String emoji;
  final int skillCount;
  final bool active;
  final int displayOrder;
  final List<String> subcategories;

  const SkillCategoryEntity({
    required this.id,
    required this.name,
    this.emoji = '📘',
    this.skillCount = 0,
    this.active = true,
    this.displayOrder = 0,
    this.subcategories = const [],
  });

  @override
  List<Object?> get props => [id, name, emoji, skillCount, active, displayOrder, subcategories];
}

class BroadcastMessageEntity extends Equatable {
  final String id;
  final String title;
  final String message;
  final String audience;
  final int recipientCount;
  final String sentDate;
  final double openRate;
  final bool isScheduled;
  final DateTime? scheduledAt;
  final String status;

  const BroadcastMessageEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.audience,
    this.recipientCount = 0,
    this.sentDate = '',
    this.openRate = 0.0,
    this.isScheduled = false,
    this.scheduledAt,
    this.status = 'sent',
  });

  @override
  List<Object?> get props => [id, title, message, audience, recipientCount, sentDate, openRate, isScheduled, scheduledAt, status];
}

class AuditLogEntryEntity extends Equatable {
  final String id;
  final DateTime timestamp;
  final String actorId;
  final String actorName;
  final String actorRole;
  final String action;
  final String detail;
  final String severity;
  final String? ip;
  final String? device;
  final String? changes;

  const AuditLogEntryEntity({
    required this.id,
    required this.timestamp,
    required this.actorId,
    required this.actorName,
    required this.actorRole,
    required this.action,
    required this.detail,
    required this.severity,
    this.ip,
    this.device,
    this.changes,
  });

  @override
  List<Object?> get props => [
        id,
        timestamp,
        actorId,
        actorName,
        actorRole,
        action,
        detail,
        severity,
        ip,
        device,
        changes,
      ];
}

class AdminRoleEntity extends Equatable {
  final String id;
  final String name;
  final int members;
  final int permissionCount;
  final int totalPermissions;
  final bool isProtected;
  final Map<String, List<String>> permissions;

  const AdminRoleEntity({
    required this.id,
    required this.name,
    this.members = 0,
    this.permissionCount = 0,
    this.totalPermissions = 47,
    this.isProtected = false,
    this.permissions = const {},
  });

  @override
  List<Object?> get props => [id, name, members, permissionCount, totalPermissions, isProtected, permissions];
}

class AdminDashboardDataEntity extends Equatable {
  final int totalUsers;
  final int activeMatches;
  final int sessionsThisWeek;
  final double averageRating;

  const AdminDashboardDataEntity({
    this.totalUsers = 0,
    this.activeMatches = 0,
    this.sessionsThisWeek = 0,
    this.averageRating = 0.0,
  });

  @override
  List<Object?> get props => [totalUsers, activeMatches, sessionsThisWeek, averageRating];
}

class DatabaseStatsEntity extends Equatable {
  final int totalDocuments;
  final int totalCollections;
  final String storageUsed;
  final String lastBackup;
  final List<CollectionInfoEntity> collections;

  const DatabaseStatsEntity({
    this.totalDocuments = 0,
    this.totalCollections = 0,
    this.storageUsed = '0 MB',
    this.lastBackup = 'Never',
    this.collections = const [],
  });

  @override
  List<Object?> get props => [totalDocuments, totalCollections, storageUsed, lastBackup, collections];
}

class CollectionInfoEntity extends Equatable {
  final String name;
  final int documents;
  final String size;
  final String status;

  const CollectionInfoEntity({
    required this.name,
    this.documents = 0,
    this.size = '0 MB',
    this.status = 'Online',
  });

  @override
  List<Object?> get props => [name, documents, size, status];
}

class DisputeEntity extends Equatable {
  final String id;
  final String agreementId;
  final String reporterId;
  final String respondentId;
  final String reason;
  final String status;
  final String timestamp;
  final String? resolution;

  const DisputeEntity({
    required this.id,
    required this.agreementId,
    required this.reporterId,
    required this.respondentId,
    required this.reason,
    this.status = 'Pending',
    required this.timestamp,
    this.resolution,
  });

  @override
  List<Object?> get props => [id, agreementId, reporterId, respondentId, reason, status, timestamp, resolution];
}

class AppealEntity extends Equatable {
  final String id;
  final String penaltyId;
  final String userId;
  final String reason;
  final String status;
  final String timestamp;
  final String? decision;

  const AppealEntity({
    required this.id,
    required this.penaltyId,
    required this.userId,
    required this.reason,
    this.status = 'Pending',
    required this.timestamp,
    this.decision,
  });

  @override
  List<Object?> get props => [id, penaltyId, userId, reason, status, timestamp, decision];
}

class SupportRequestEntity extends Equatable {
  final String id;
  final String userId;
  final String subject;
  final String message;
  final String status;
  final String timestamp;
  final String? adminResponse;

  const SupportRequestEntity({
    required this.id,
    required this.userId,
    required this.subject,
    required this.message,
    this.status = 'Open',
    required this.timestamp,
    this.adminResponse,
  });

  @override
  List<Object?> get props => [id, userId, subject, message, status, timestamp, adminResponse];
}
