import 'package:equatable/equatable.dart';
import 'package:myapp/features/admin/data/models/admin_models.dart';

abstract class AdminEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Dashboard
class AdminLoadDashboard extends AdminEvent {}

// Users
class AdminLoadUsers extends AdminEvent {}

class AdminSearchUsers extends AdminEvent {
  final String query;
  final String? role;
  final String? status;
  AdminSearchUsers({required this.query, this.role, this.status});
  @override
  List<Object?> get props => [query, role, status];
}

class AdminSuspendUser extends AdminEvent {
  final String userId;
  final String reason;
  AdminSuspendUser({required this.userId, required this.reason});
  @override
  List<Object?> get props => [userId, reason];
}

class AdminDeleteUser extends AdminEvent {
  final String userId;
  AdminDeleteUser(this.userId);
  @override
  List<Object?> get props => [userId];
}

class AdminBulkUserAction extends AdminEvent {
  final List<String> userIds;
  final String action;
  AdminBulkUserAction({required this.userIds, required this.action});
  @override
  List<Object?> get props => [userIds, action];
}

// Moderation
class AdminLoadFlaggedContent extends AdminEvent {
  final String? status;
  final String? priority;
  final String? type;
  AdminLoadFlaggedContent({this.status, this.priority, this.type});
}

class AdminDismissFlag extends AdminEvent {
  final String flagId;
  AdminDismissFlag(this.flagId);
  @override
  List<Object?> get props => [flagId];
}

class AdminRemoveContent extends AdminEvent {
  final String flagId;
  final String reason;
  AdminRemoveContent({required this.flagId, required this.reason});
  @override
  List<Object?> get props => [flagId, reason];
}

class AdminBulkModeration extends AdminEvent {
  final List<String> flagIds;
  final String action;
  AdminBulkModeration({required this.flagIds, required this.action});
  @override
  List<Object?> get props => [flagIds, action];
}

// Penalties
class AdminLoadPenalties extends AdminEvent {}

class AdminApplyPenalty extends AdminEvent {
  final String userId;
  final String type;
  final String reason;
  AdminApplyPenalty({required this.userId, required this.type, required this.reason});
  @override
  List<Object?> get props => [userId, type, reason];
}

class AdminOverturnPenalty extends AdminEvent {
  final String penaltyId;
  AdminOverturnPenalty(this.penaltyId);
  @override
  List<Object?> get props => [penaltyId];
}

// Analytics
class AdminLoadAnalytics extends AdminEvent {
  final String dateRange;
  final DateTime? start;
  final DateTime? end;
  AdminLoadAnalytics({this.dateRange = 'Last 30 Days', this.start, this.end});
}

// Config
class AdminLoadConfig extends AdminEvent {}

class AdminSaveConfig extends AdminEvent {
  final SystemConfigModel config;
  AdminSaveConfig(this.config);
  @override
  List<Object?> get props => [config];
}

class AdminRestoreConfig extends AdminEvent {}

// Categories
class AdminLoadCategories extends AdminEvent {}

class AdminCreateCategory extends AdminEvent {
  final Map<String, dynamic> data;
  AdminCreateCategory(this.data);
  @override
  List<Object?> get props => [data];
}

class AdminUpdateCategory extends AdminEvent {
  final String id;
  final Map<String, dynamic> data;
  AdminUpdateCategory({required this.id, required this.data});
  @override
  List<Object?> get props => [id, data];
}

class AdminDeleteCategory extends AdminEvent {
  final String id;
  AdminDeleteCategory(this.id);
  @override
  List<Object?> get props => [id];
}

class AdminReorderCategories extends AdminEvent {
  final List<String> orderedIds;
  AdminReorderCategories(this.orderedIds);
  @override
  List<Object?> get props => [orderedIds];
}

// Broadcasts
class AdminLoadBroadcasts extends AdminEvent {}

class AdminSendBroadcast extends AdminEvent {
  final String title;
  final String message;
  final String audience;
  final DateTime? scheduledAt;
  AdminSendBroadcast({required this.title, required this.message, required this.audience, this.scheduledAt});
  @override
  List<Object?> get props => [title, message, audience, scheduledAt];
}

// Audit Log
class AdminLoadAuditLogs extends AdminEvent {
  final String? admin;
  final String? action;
  final int page;
  final int pageSize;
  AdminLoadAuditLogs({this.admin, this.action, this.page = 1, this.pageSize = 25});
  @override
  List<Object?> get props => [admin, action, page, pageSize];
}

// Roles
class AdminLoadRoles extends AdminEvent {}

class AdminCreateRole extends AdminEvent {
  final String name;
  final Map<String, List<String>> permissions;
  AdminCreateRole({required this.name, required this.permissions});
  @override
  List<Object?> get props => [name, permissions];
}

class AdminUpdateRole extends AdminEvent {
  final String id;
  final Map<String, dynamic> data;
  AdminUpdateRole({required this.id, required this.data});
  @override
  List<Object?> get props => [id, data];
}

class AdminDeleteRole extends AdminEvent {
  final String id;
  AdminDeleteRole(this.id);
  @override
  List<Object?> get props => [id];
}

// Database
class AdminLoadDatabaseStats extends AdminEvent {}

class AdminRunBackup extends AdminEvent {}

class AdminRestoreBackup extends AdminEvent {}

class AdminRunMaintenance extends AdminEvent {}

// Seed
class AdminSeedDatabase extends AdminEvent {}

class AdminClearOperationStatus extends AdminEvent {}
