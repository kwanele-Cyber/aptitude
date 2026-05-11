import 'package:equatable/equatable.dart';
import 'package:myapp/features/admin/domain/entities/admin_entities.dart';

abstract class AdminState extends Equatable {
  const AdminState();
  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

// Dashboard
class AdminDashboardLoading extends AdminState {}

class AdminDashboardLoaded extends AdminState {
  final int totalUsers, activeMatches, sessionsThisWeek;
  final double averageRating;
  const AdminDashboardLoaded({
    this.totalUsers = 0,
    this.activeMatches = 0,
    this.sessionsThisWeek = 0,
    this.averageRating = 0.0,
  });
  @override
  List<Object?> get props => [
    totalUsers,
    activeMatches,
    sessionsThisWeek,
    averageRating,
  ];
}

// Users
class AdminUsersLoading extends AdminState {}

class AdminUsersLoaded extends AdminState {
  final List<AdminUserEntity> users;
  const AdminUsersLoaded(this.users);
  @override
  List<Object?> get props => [users];
}

// Moderation
class AdminModerationLoading extends AdminState {}

class AdminModerationLoaded extends AdminState {
  final List<FlaggedContentEntity> items;
  const AdminModerationLoaded(this.items);
  @override
  List<Object?> get props => [items];
}

// Penalties
class AdminPenaltiesLoading extends AdminState {}

class AdminPenaltiesLoaded extends AdminState {
  final List<PenaltyEntity> penalties;
  const AdminPenaltiesLoaded(this.penalties);
  @override
  List<Object?> get props => [penalties];
}

// Analytics
class AdminAnalyticsLoading extends AdminState {}

class AdminAnalyticsLoaded extends AdminState {
  final AnalyticsDataEntity data;
  const AdminAnalyticsLoaded(this.data);
  @override
  List<Object?> get props => [data];
}

// Config
class AdminConfigLoading extends AdminState {}

class AdminConfigLoaded extends AdminState {
  final SystemConfigEntity config;
  const AdminConfigLoaded(this.config);
  @override
  List<Object?> get props => [config];
}

// Categories
class AdminCategoriesLoading extends AdminState {}

class AdminCategoriesLoaded extends AdminState {
  final List<SkillCategoryEntity> categories;
  const AdminCategoriesLoaded(this.categories);
  @override
  List<Object?> get props => [categories];
}

// Broadcasts
class AdminBroadcastsLoading extends AdminState {}

class AdminBroadcastsLoaded extends AdminState {
  final List<BroadcastMessageEntity> broadcasts;
  const AdminBroadcastsLoaded(this.broadcasts);
  @override
  List<Object?> get props => [broadcasts];
}

// Audit Log
class AdminAuditLogLoading extends AdminState {}

class AdminAuditLogLoaded extends AdminState {
  final List<AuditLogEntryEntity> entries;
  final int page;
  final bool hasMore;
  const AdminAuditLogLoaded(
    this.entries, {
    this.page = 1,
    this.hasMore = false,
  });
  @override
  List<Object?> get props => [entries, page, hasMore];
}

// Roles
class AdminRolesLoading extends AdminState {}

class AdminRolesLoaded extends AdminState {
  final List<AdminRoleEntity> roles;
  const AdminRolesLoaded(this.roles);
  @override
  List<Object?> get props => [roles];
}

// Database
class AdminDatabaseLoading extends AdminState {}

class AdminDatabaseLoaded extends AdminState {
  final DatabaseStatsEntity stats;
  const AdminDatabaseLoaded(this.stats);
  @override
  List<Object?> get props => [stats];
}

// Seed
class AdminSeedInProgress extends AdminState {
  final String step;
  final double progress;
  const AdminSeedInProgress({required this.step, required this.progress});
  @override
  List<Object?> get props => [step, progress];
}

class AdminSeedComplete extends AdminState {
  final List<String> results;
  const AdminSeedComplete(this.results);
  @override
  List<Object?> get props => [results];
}

class AdminSeedError extends AdminState {
  final String message;
  const AdminSeedError(this.message);
  @override
  List<Object?> get props => [message];
}

// Generic
class AdminOperationSuccess extends AdminState {
  final String message;
  const AdminOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class AdminError extends AdminState {
  final String message;
  const AdminError(this.message);
  @override
  List<Object?> get props => [message];
}
