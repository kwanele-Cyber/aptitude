import 'package:myapp/features/admin/domain/entities/admin_entities.dart';

class AdminUserModel extends AdminUserEntity {
  const AdminUserModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.role,
    super.status,
    super.joined,
    super.sessions,
    super.rating,
    super.reportsCount,
    super.twoFactorEnabled,
    super.trustScore,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) => AdminUserModel(
        id: json['id'] as String? ?? json['uid'] as String? ?? '',
        firstName: json['firstName'] as String? ?? json['first_name'] as String? ?? '',
        lastName: json['lastName'] as String? ?? json['last_name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        role: json['role'] as String? ?? 'User',
        status: json['status'] as String? ?? 'Active',
        joined: json['joined'] as String? ?? '',
        sessions: (json['sessions'] as num?)?.toInt() ?? 0,
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        reportsCount: (json['reportsCount'] as num?)?.toInt() ?? 0,
        twoFactorEnabled: json['twoFactorEnabled'] as bool? ?? false,
        trustScore: (json['trustScore'] as num?)?.toDouble() ?? 100.0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'role': role,
        'status': status,
        'joined': joined,
        'sessions': sessions,
        'rating': rating,
        'reportsCount': reportsCount,
        'twoFactorEnabled': twoFactorEnabled,
        'trustScore': trustScore,
      };
}

class FlaggedContentModel extends FlaggedContentEntity {
  const FlaggedContentModel({
    required super.id,
    required super.priority,
    required super.reason,
    required super.preview,
    required super.reportedBy,
    required super.fromUser,
    required super.timestamp,
    required super.type,
    super.status,
    super.contentId,
  });

  factory FlaggedContentModel.fromJson(Map<String, dynamic> json) => FlaggedContentModel(
        id: json['id'] as String? ?? '',
        priority: json['priority'] as String? ?? 'LOW',
        reason: json['reason'] as String? ?? '',
        preview: json['preview'] as String? ?? '',
        reportedBy: json['reportedBy'] as String? ?? '',
        fromUser: json['fromUser'] as String? ?? '',
        timestamp: json['timestamp'] as String? ?? '',
        type: json['type'] as String? ?? '',
        status: json['status'] as String? ?? 'Pending',
        contentId: json['contentId'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'priority': priority,
        'reason': reason,
        'preview': preview,
        'reportedBy': reportedBy,
        'fromUser': fromUser,
        'timestamp': timestamp,
        'type': type,
        'status': status,
        'contentId': contentId,
      };
}

class PenaltyModel extends PenaltyEntity {
  const PenaltyModel({
    required super.id,
    required super.severity,
    required super.type,
    required super.user,
    required super.userId,
    required super.reason,
    required super.date,
    required super.duration,
    super.strikes,
    super.isActive,
  });

  factory PenaltyModel.fromJson(Map<String, dynamic> json) => PenaltyModel(
        id: json['id'] as String? ?? '',
        severity: json['severity'] as String? ?? 'Low',
        type: json['type'] as String? ?? '',
        user: json['user'] as String? ?? '',
        userId: json['userId'] as String? ?? '',
        reason: json['reason'] as String? ?? '',
        date: json['date'] as String? ?? '',
        duration: json['duration'] as String? ?? '',
        strikes: (json['strikes'] as num?)?.toInt() ?? 0,
        isActive: json['isActive'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'severity': severity,
        'type': type,
        'user': user,
        'userId': userId,
        'reason': reason,
        'date': date,
        'duration': duration,
        'strikes': strikes,
        'isActive': isActive,
      };
}

class AnalyticsDataModel extends AnalyticsDataEntity {
  const AnalyticsDataModel({
    super.newUsers,
    super.totalMatches,
    super.sessionsCompleted,
    super.avgRating,
    super.avgTrustScore,
    super.disputeRate,
    super.userGrowth,
    super.matchSuccessByCategory,
    super.sessionCompletionRate,
    super.sessionCancelRate,
    super.sessionNoShowRate,
    super.sessionRescheduleRate,
  });

  factory AnalyticsDataModel.fromJson(Map<String, dynamic> json) => AnalyticsDataModel(
        newUsers: (json['newUsers'] as num?)?.toInt() ?? 0,
        totalMatches: (json['totalMatches'] as num?)?.toInt() ?? 0,
        sessionsCompleted: (json['sessionsCompleted'] as num?)?.toInt() ?? 0,
        avgRating: (json['avgRating'] as num?)?.toDouble() ?? 0.0,
        avgTrustScore: (json['avgTrustScore'] as num?)?.toDouble() ?? 0.0,
        disputeRate: (json['disputeRate'] as num?)?.toDouble() ?? 0.0,
        userGrowth: (json['userGrowth'] as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList() ?? [],
        matchSuccessByCategory: (json['matchSuccessByCategory'] as Map<String, dynamic>?)
                ?.map((k, v) => MapEntry(k, (v as num).toDouble())) ??
            {},
        sessionCompletionRate: (json['sessionCompletionRate'] as num?)?.toDouble() ?? 0.0,
        sessionCancelRate: (json['sessionCancelRate'] as num?)?.toDouble() ?? 0.0,
        sessionNoShowRate: (json['sessionNoShowRate'] as num?)?.toDouble() ?? 0.0,
        sessionRescheduleRate: (json['sessionRescheduleRate'] as num?)?.toDouble() ?? 0.0,
      );
}

class SystemConfigModel extends SystemConfigEntity {
  const SystemConfigModel({
    super.featureFlags,
    super.matchParams,
    super.trustThresholds,
    super.generalSettings,
  });

  factory SystemConfigModel.fromJson(Map<String, dynamic> json) => SystemConfigModel(
        featureFlags: (json['featureFlags'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, v as bool)) ?? {},
        matchParams: (json['matchParams'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, (v as num).toDouble())) ?? {},
        trustThresholds:
            (json['trustThresholds'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, (v as num).toInt())) ?? {},
        generalSettings:
            (json['generalSettings'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, (v as num).toInt())) ?? {},
      );

  Map<String, dynamic> toJson() => {
        'featureFlags': featureFlags,
        'matchParams': matchParams,
        'trustThresholds': trustThresholds,
        'generalSettings': generalSettings,
      };
}

class SkillCategoryModel extends SkillCategoryEntity {
  const SkillCategoryModel({
    required super.id,
    required super.name,
    super.emoji,
    super.skillCount,
    super.active,
    super.displayOrder,
    super.subcategories,
  });

  factory SkillCategoryModel.fromJson(Map<String, dynamic> json) => SkillCategoryModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        emoji: json['emoji'] as String? ?? '📘',
        skillCount: (json['skillCount'] as num?)?.toInt() ?? 0,
        active: json['active'] as bool? ?? true,
        displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
        subcategories: (json['subcategories'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'skillCount': skillCount,
        'active': active,
        'displayOrder': displayOrder,
        'subcategories': subcategories,
      };
}

class BroadcastMessageModel extends BroadcastMessageEntity {
  const BroadcastMessageModel({
    required super.id,
    required super.title,
    required super.message,
    required super.audience,
    super.recipientCount,
    super.sentDate,
    super.openRate,
    super.isScheduled,
    super.scheduledAt,
    super.status,
  });

  factory BroadcastMessageModel.fromJson(Map<String, dynamic> json) => BroadcastMessageModel(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        message: json['message'] as String? ?? '',
        audience: json['audience'] as String? ?? '',
        recipientCount: (json['recipientCount'] as num?)?.toInt() ?? 0,
        sentDate: json['sentDate'] as String? ?? '',
        openRate: (json['openRate'] as num?)?.toDouble() ?? 0.0,
        isScheduled: json['isScheduled'] as bool? ?? false,
        scheduledAt: json['scheduledAt'] != null ? DateTime.parse(json['scheduledAt'] as String) : null,
        status: json['status'] as String? ?? 'sent',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'audience': audience,
        'recipientCount': recipientCount,
        'sentDate': sentDate,
        'openRate': openRate,
        'isScheduled': isScheduled,
        'scheduledAt': scheduledAt?.toIso8601String(),
        'status': status,
      };
}

class AuditLogEntryModel extends AuditLogEntryEntity {
  const AuditLogEntryModel({
    required super.id,
    required super.timestamp,
    required super.actorId,
    required super.actorName,
    required super.actorRole,
    required super.action,
    required super.detail,
    required super.severity,
    super.ip,
    super.device,
    super.changes,
  });

  factory AuditLogEntryModel.fromJson(Map<String, dynamic> json) => AuditLogEntryModel(
        id: json['id'] as String? ?? '',
        timestamp: json['timestamp'] != null
            ? DateTime.parse(json['timestamp'] as String)
            : DateTime.now(),
        actorId: json['actorId'] as String? ?? json['userId'] as String? ?? '',
        actorName: json['actorName'] as String? ?? json['admin'] as String? ?? 'Unknown',
        actorRole: json['actorRole'] as String? ?? json['userRole'] as String? ?? 'User',
        action: json['action'] as String? ?? '',
        detail: json['detail'] as String? ?? '',
        severity: json['severity'] as String? ?? 'info',
        ip: json['ip'] as String?,
        device: json['device'] as String?,
        changes: json['changes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'actorId': actorId,
        'actorName': actorName,
        'actorRole': actorRole,
        'action': action,
        'detail': detail,
        'severity': severity,
        'ip': ip,
        'device': device,
        'changes': changes,
      };
}

class AdminRoleModel extends AdminRoleEntity {
  const AdminRoleModel({
    required super.id,
    required super.name,
    super.members,
    super.permissionCount,
    super.totalPermissions,
    super.isProtected,
    super.permissions,
  });

  factory AdminRoleModel.fromJson(Map<String, dynamic> json) => AdminRoleModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        members: (json['members'] as num?)?.toInt() ?? 0,
        permissionCount: (json['permissionCount'] as num?)?.toInt() ?? 0,
        totalPermissions: (json['totalPermissions'] as num?)?.toInt() ?? 47,
        isProtected: json['isProtected'] as bool? ?? false,
        permissions: (json['permissions'] as Map<String, dynamic>?)
                ?.map((k, v) => MapEntry(k, (v as List<dynamic>).map((e) => e as String).toList())) ??
            {},
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'members': members,
        'permissionCount': permissionCount,
        'totalPermissions': totalPermissions,
        'isProtected': isProtected,
        'permissions': permissions,
      };
}

class DatabaseStatsModel extends DatabaseStatsEntity {
  const DatabaseStatsModel({
    super.totalDocuments,
    super.totalCollections,
    super.storageUsed,
    super.lastBackup,
    super.collections,
  });

  factory DatabaseStatsModel.fromJson(Map<String, dynamic> json) => DatabaseStatsModel(
        totalDocuments: (json['totalDocuments'] as num?)?.toInt() ?? 0,
        totalCollections: (json['totalCollections'] as num?)?.toInt() ?? 0,
        storageUsed: json['storageUsed'] as String? ?? '0 MB',
        lastBackup: json['lastBackup'] as String? ?? 'Never',
        collections: (json['collections'] as List<dynamic>?)
                ?.map((e) => CollectionInfoModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'totalDocuments': totalDocuments,
        'totalCollections': totalCollections,
        'storageUsed': storageUsed,
        'lastBackup': lastBackup,
        'collections': collections.map((e) => (e as CollectionInfoModel).toJson()).toList(),
      };
}

class CollectionInfoModel extends CollectionInfoEntity {
  const CollectionInfoModel({
    required super.name,
    super.documents,
    super.size,
    super.status,
  });

  factory CollectionInfoModel.fromJson(Map<String, dynamic> json) => CollectionInfoModel(
        name: json['name'] as String? ?? '',
        documents: (json['documents'] as num?)?.toInt() ?? 0,
        size: json['size'] as String? ?? '0 MB',
        status: json['status'] as String? ?? 'Online',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'documents': documents,
        'size': size,
        'status': status,
      };
}

class AdminDashboardDataModel extends AdminDashboardDataEntity {
  const AdminDashboardDataModel({
    super.totalUsers,
    super.activeMatches,
    super.sessionsThisWeek,
    super.averageRating,
  });

  factory AdminDashboardDataModel.fromJson(Map<String, dynamic> json) => AdminDashboardDataModel(
        totalUsers: (json['totalUsers'] as num?)?.toInt() ?? 0,
        activeMatches: (json['activeMatches'] as num?)?.toInt() ?? 0,
        sessionsThisWeek: (json['sessionsThisWeek'] as num?)?.toInt() ?? 0,
        averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        'totalUsers': totalUsers,
        'activeMatches': activeMatches,
        'sessionsThisWeek': sessionsThisWeek,
        'averageRating': averageRating,
      };
}

class DisputeModel extends DisputeEntity {
  const DisputeModel({
    required super.id,
    required super.agreementId,
    required super.reporterId,
    required super.respondentId,
    required super.reason,
    super.status,
    required super.timestamp,
    super.resolution,
  });

  factory DisputeModel.fromJson(Map<String, dynamic> json) => DisputeModel(
        id: json['id'] as String? ?? '',
        agreementId: json['agreementId'] as String? ?? '',
        reporterId: json['reporterId'] as String? ?? '',
        respondentId: json['respondentId'] as String? ?? '',
        reason: json['reason'] as String? ?? '',
        status: json['status'] as String? ?? 'Pending',
        timestamp: json['timestamp'] as String? ?? '',
        resolution: json['resolution'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'agreementId': agreementId,
        'reporterId': reporterId,
        'respondentId': respondentId,
        'reason': reason,
        'status': status,
        'timestamp': timestamp,
        'resolution': resolution,
      };
}

class AppealModel extends AppealEntity {
  const AppealModel({
    required super.id,
    required super.penaltyId,
    required super.userId,
    required super.reason,
    super.status,
    required super.timestamp,
    super.decision,
  });

  factory AppealModel.fromJson(Map<String, dynamic> json) => AppealModel(
        id: json['id'] as String? ?? '',
        penaltyId: json['penaltyId'] as String? ?? '',
        userId: json['userId'] as String? ?? '',
        reason: json['reason'] as String? ?? '',
        status: json['status'] as String? ?? 'Pending',
        timestamp: json['timestamp'] as String? ?? '',
        decision: json['decision'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'penaltyId': penaltyId,
        'userId': userId,
        'reason': reason,
        'status': status,
        'timestamp': timestamp,
        'decision': decision,
      };
}

class SupportRequestModel extends SupportRequestEntity {
  const SupportRequestModel({
    required super.id,
    required super.userId,
    required super.subject,
    required super.message,
    super.status,
    required super.timestamp,
    super.adminResponse,
  });

  factory SupportRequestModel.fromJson(Map<String, dynamic> json) => SupportRequestModel(
        id: json['id'] as String? ?? '',
        userId: json['userId'] as String? ?? '',
        subject: json['subject'] as String? ?? '',
        message: json['message'] as String? ?? '',
        status: json['status'] as String? ?? 'Open',
        timestamp: json['timestamp'] as String? ?? '',
        adminResponse: json['adminResponse'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'subject': subject,
        'message': message,
        'status': status,
        'timestamp': timestamp,
        'adminResponse': adminResponse,
      };
}
