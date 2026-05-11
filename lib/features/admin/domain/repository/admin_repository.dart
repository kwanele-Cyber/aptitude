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
  Future<Either<Failure, void>> updateTrustScore(String userId, double score, String reason);

  // Content Moderation
  Future<Either<Failure, List<FlaggedContentEntity>>> getFlaggedContent({String? status, String? priority, String? type});
  Future<Either<Failure, void>> dismissFlag(String flagId);
  Future<Either<Failure, void>> removeContent(String flagId, String reason);
  Future<Either<Failure, void>> bulkModeration(List<String> flagIds, String action);

  // Penalties
  Future<Either<Failure, List<PenaltyEntity>>> getPenalties({String? query});
  Future<Either<Failure, void>> applyPenalty(String userId, String type, String reason);
  Future<Either<Failure, void>> overturnPenalty(String penaltyId);

  // Disputes & Appeals
  Future<Either<Failure, List<DisputeEntity>>> getDisputes();
  Future<Either<Failure, void>> resolveDispute(String disputeId, String resolution);
  Future<Either<Failure, List<AppealEntity>>> getAppeals();
  Future<Either<Failure, void>> handleAppeal(String appealId, String decision);

  // Analytics
  Future<Either<Failure, AnalyticsDataEntity>> getAnalytics(String dateRange, {DateTime? start, DateTime? end});
  Future<Either<Failure, String>> exportSystemData(String type);

  // System Config
  Future<Either<Failure, SystemConfigEntity>> getConfig({String? query});
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
  Future<Either<Failure, void>> logAudit(String action, {String detail = '', String severity = 'info', String actorRole = 'User', String? actorId});

  // Support
  Future<Either<Failure, List<SupportRequestEntity>>> getSupportRequests();
  Future<Either<Failure, void>> respondToSupportRequest(String requestId, String response);

  // Audit Log
  Future<Either<Failure, List<AuditLogEntryEntity>>> getAuditLogs({String? actor, String? action, int page = 1, int pageSize = 25});

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
  Future<Either<Failure, void>> assignEmergencyAdmin(String userId, String verificationToken);
  Future<Either<Failure, void>> grantTemporaryAdmin(String userId, Duration duration, List<String> permissions);
  Future<Either<Failure, void>> rotateRecoveryKeys();
}
