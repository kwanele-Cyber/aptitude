import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/admin/domain/entities/admin_entities.dart';
import 'package:myapp/features/admin/domain/repository/admin_repository.dart';

// Dashboard
class GetDashboardDataUseCase {
  final AdminRepository repository;
  GetDashboardDataUseCase(this.repository);
  Future<Either<Failure, AdminDashboardDataEntity>> call() => repository.getDashboardData();
}

// User Management
class GetUsersUseCase {
  final AdminRepository repository;
  GetUsersUseCase(this.repository);
  Future<Either<Failure, List<AdminUserEntity>>> call() => repository.getUsers();
}

class SearchUsersUseCase {
  final AdminRepository repository;
  SearchUsersUseCase(this.repository);
  Future<Either<Failure, List<AdminUserEntity>>> call(String query, {String? role, String? status}) =>
      repository.searchUsers(query, role: role, status: status);
}

class SuspendUserUseCase {
  final AdminRepository repository;
  SuspendUserUseCase(this.repository);
  Future<Either<Failure, void>> call(String userId, String reason) => repository.suspendUser(userId, reason);
}

class DeleteUserUseCase {
  final AdminRepository repository;
  DeleteUserUseCase(this.repository);
  Future<Either<Failure, void>> call(String userId) => repository.deleteUser(userId);
}

class BulkUserActionUseCase {
  final AdminRepository repository;
  BulkUserActionUseCase(this.repository);
  Future<Either<Failure, void>> call(List<String> userIds, String action) => repository.bulkAction(userIds, action);
}

// Content Moderation
class GetFlaggedContentUseCase {
  final AdminRepository repository;
  GetFlaggedContentUseCase(this.repository);
  Future<Either<Failure, List<FlaggedContentEntity>>> call({String? status, String? priority, String? type}) =>
      repository.getFlaggedContent(status: status, priority: priority, type: type);
}

class DismissFlagUseCase {
  final AdminRepository repository;
  DismissFlagUseCase(this.repository);
  Future<Either<Failure, void>> call(String flagId) => repository.dismissFlag(flagId);
}

class RemoveContentUseCase {
  final AdminRepository repository;
  RemoveContentUseCase(this.repository);
  Future<Either<Failure, void>> call(String flagId, String reason) => repository.removeContent(flagId, reason);
}

class BulkModerationUseCase {
  final AdminRepository repository;
  BulkModerationUseCase(this.repository);
  Future<Either<Failure, void>> call(List<String> flagIds, String action) => repository.bulkModeration(flagIds, action);
}

// Penalties
class GetPenaltiesUseCase {
  final AdminRepository repository;
  GetPenaltiesUseCase(this.repository);
  Future<Either<Failure, List<PenaltyEntity>>> call({String? query}) => repository.getPenalties(query: query);
}

class ApplyPenaltyUseCase {
  final AdminRepository repository;
  ApplyPenaltyUseCase(this.repository);
  Future<Either<Failure, void>> call(String userId, String type, String reason) =>
      repository.applyPenalty(userId, type, reason);
}

class OverturnPenaltyUseCase {
  final AdminRepository repository;
  OverturnPenaltyUseCase(this.repository);
  Future<Either<Failure, void>> call(String penaltyId) => repository.overturnPenalty(penaltyId);
}

// Analytics
class GetAnalyticsUseCase {
  final AdminRepository repository;
  GetAnalyticsUseCase(this.repository);
  Future<Either<Failure, AnalyticsDataEntity>> call(String dateRange, {DateTime? start, DateTime? end}) =>
      repository.getAnalytics(dateRange, start: start, end: end);
}

// System Config
class GetConfigUseCase {
  final AdminRepository repository;
  GetConfigUseCase(this.repository);
  Future<Either<Failure, SystemConfigEntity>> call({String? query}) => repository.getConfig(query: query);
}

class SaveConfigUseCase {
  final AdminRepository repository;
  SaveConfigUseCase(this.repository);
  Future<Either<Failure, void>> call(SystemConfigEntity config) => repository.saveConfig(config);
}

class RestoreDefaultConfigUseCase {
  final AdminRepository repository;
  RestoreDefaultConfigUseCase(this.repository);
  Future<Either<Failure, void>> call() => repository.restoreDefaultConfig();
}

// Categories
class GetCategoriesUseCase {
  final AdminRepository repository;
  GetCategoriesUseCase(this.repository);
  Future<Either<Failure, List<SkillCategoryEntity>>> call() => repository.getCategories();
}

class CreateCategoryUseCase {
  final AdminRepository repository;
  CreateCategoryUseCase(this.repository);
  Future<Either<Failure, void>> call(Map<String, dynamic> data) => repository.createCategory(data);
}

class UpdateCategoryUseCase {
  final AdminRepository repository;
  UpdateCategoryUseCase(this.repository);
  Future<Either<Failure, void>> call(String id, Map<String, dynamic> data) => repository.updateCategory(id, data);
}

class DeleteCategoryUseCase {
  final AdminRepository repository;
  DeleteCategoryUseCase(this.repository);
  Future<Either<Failure, void>> call(String id) => repository.deleteCategory(id);
}

class ReorderCategoriesUseCase {
  final AdminRepository repository;
  ReorderCategoriesUseCase(this.repository);
  Future<Either<Failure, void>> call(List<String> orderedIds) => repository.reorderCategories(orderedIds);
}

// Broadcasts
class GetBroadcastsUseCase {
  final AdminRepository repository;
  GetBroadcastsUseCase(this.repository);
  Future<Either<Failure, List<BroadcastMessageEntity>>> call() => repository.getBroadcasts();
}

class SendBroadcastUseCase {
  final AdminRepository repository;
  SendBroadcastUseCase(this.repository);
  Future<Either<Failure, void>> call(String title, String message, String audience, {DateTime? scheduledAt}) =>
      repository.sendBroadcast(title, message, audience, scheduledAt: scheduledAt);
}

// Audit Log
class GetAuditLogsUseCase {
  final AdminRepository repository;
  GetAuditLogsUseCase(this.repository);
  Future<Either<Failure, List<AuditLogEntryEntity>>> call({String? actor, String? action, int page = 1, int pageSize = 25}) =>
      repository.getAuditLogs(actor: actor, action: action, page: page, pageSize: pageSize);
}

// Role Management
class GetRolesUseCase {
  final AdminRepository repository;
  GetRolesUseCase(this.repository);
  Future<Either<Failure, List<AdminRoleEntity>>> call() => repository.getRoles();
}

class CreateRoleUseCase {
  final AdminRepository repository;
  CreateRoleUseCase(this.repository);
  Future<Either<Failure, void>> call(String name, Map<String, List<String>> permissions) =>
      repository.createRole(name, permissions);
}

class UpdateRoleUseCase {
  final AdminRepository repository;
  UpdateRoleUseCase(this.repository);
  Future<Either<Failure, void>> call(String id, Map<String, dynamic> data) => repository.updateRole(id, data);
}

class DeleteRoleUseCase {
  final AdminRepository repository;
  DeleteRoleUseCase(this.repository);
  Future<Either<Failure, void>> call(String id) => repository.deleteRole(id);
}

// Database
class GetDatabaseStatsUseCase {
  final AdminRepository repository;
  GetDatabaseStatsUseCase(this.repository);
  Future<Either<Failure, DatabaseStatsEntity>> call() => repository.getDatabaseStats();
}

class RunBackupUseCase {
  final AdminRepository repository;
  RunBackupUseCase(this.repository);
  Future<Either<Failure, void>> call() => repository.runBackup();
}

class RestoreBackupUseCase {
  final AdminRepository repository;
  RestoreBackupUseCase(this.repository);
  Future<Either<Failure, void>> call() => repository.restoreBackup();
}

class RunMaintenanceUseCase {
  final AdminRepository repository;
  RunMaintenanceUseCase(this.repository);
  Future<Either<Failure, void>> call() => repository.runMaintenance();
}
