import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/admin/domain/entities/admin_entities.dart';

abstract class AdminRepository {
  // Dashboard
  Future<Either<Failure, AdminDashboardDataEntity>> getDashboardData();

  // User Management
  Future<Either<Failure, List<AdminUserEntity>>> getUsers();
  Future<Either<Failure, List<AdminUserEntity>>> searchUsers(String query, {String? role, String? status});
  Future<Either<Failure, void>> suspendUser(String userId, String reason);
  Future<Either<Failure, void>> deleteUser(String userId);
  Future<Either<Failure, void>> bulkAction(List<String> userIds, String action);

  // Content Moderation
  Future<Either<Failure, List<FlaggedContentEntity>>> getFlaggedContent({String? status, String? priority, String? type});
  Future<Either<Failure, void>> dismissFlag(String flagId);
  Future<Either<Failure, void>> removeContent(String flagId, String reason);
  Future<Either<Failure, void>> bulkModeration(List<String> flagIds, String action);

  // Penalties
  Future<Either<Failure, List<PenaltyEntity>>> getPenalties();
  Future<Either<Failure, void>> applyPenalty(String userId, String type, String reason);
  Future<Either<Failure, void>> overturnPenalty(String penaltyId);

  // Analytics
  Future<Either<Failure, AnalyticsDataEntity>> getAnalytics(String dateRange, {DateTime? start, DateTime? end});

  // System Config
  Future<Either<Failure, SystemConfigEntity>> getConfig();
  Future<Either<Failure, void>> saveConfig(SystemConfigEntity config);
  Future<Either<Failure, void>> restoreDefaultConfig();

  // Categories
  Future<Either<Failure, List<SkillCategoryEntity>>> getCategories();
  Future<Either<Failure, void>> createCategory(Map<String, dynamic> data);
  Future<Either<Failure, void>> updateCategory(String id, Map<String, dynamic> data);
  Future<Either<Failure, void>> deleteCategory(String id);
  Future<Either<Failure, void>> reorderCategories(List<String> orderedIds);

  // Broadcasts
  Future<Either<Failure, List<BroadcastMessageEntity>>> getBroadcasts();
  Future<Either<Failure, void>> sendBroadcast(String title, String message, String audience, {DateTime? scheduledAt});

  // Audit Log
  Future<Either<Failure, List<AuditLogEntryEntity>>> getAuditLogs({String? admin, String? action, int page = 1, int pageSize = 25});

  // Role Management
  Future<Either<Failure, List<AdminRoleEntity>>> getRoles();
  Future<Either<Failure, void>> createRole(String name, Map<String, List<String>> permissions);
  Future<Either<Failure, void>> updateRole(String id, Map<String, dynamic> data);
  Future<Either<Failure, void>> deleteRole(String id);

  // Database
  Future<Either<Failure, DatabaseStatsEntity>> getDatabaseStats();
  Future<Either<Failure, void>> runBackup();
  Future<Either<Failure, void>> restoreBackup();
  Future<Either<Failure, void>> runMaintenance();
}
