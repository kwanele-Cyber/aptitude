import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:myapp/features/admin/data/models/admin_models.dart';
import 'package:myapp/features/admin/domain/entities/admin_entities.dart';
import 'package:myapp/features/admin/domain/repository/admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AdminDashboardDataEntity>> getDashboardData() async {
    try {
      final data = await remoteDataSource.getDashboardData();
      return Right(data);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<AdminUserEntity>>> getUsers() async {
    try {
      final users = await remoteDataSource.getUsers();
      return Right(users);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<AdminUserEntity>>> searchUsers(String query, {String? role, String? status}) async {
    try {
      final users = await remoteDataSource.searchUsers(query, role: role, status: status);
      return Right(users);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> suspendUser(String userId, String reason) async {
    try {
      await remoteDataSource.suspendUser(userId, reason);
      await logAudit('Suspended User', detail: 'User ID: $userId | Reason: $reason', severity: 'warning', actorRole: 'Admin');
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser(String userId) async {
    try {
      await remoteDataSource.deleteUser(userId);
      await logAudit('Deleted User', detail: 'User ID: $userId', severity: 'danger', actorRole: 'Admin');
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> bulkAction(List<String> userIds, String action) async {
    try {
      await remoteDataSource.bulkAction(userIds, action);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateTrustScore(String userId, double score, String reason) async {
    try {
      await remoteDataSource.updateTrustScore(userId, score, reason);
      await logAudit('Updated Trust Score', detail: 'User ID: $userId | New Score: $score', severity: 'info', actorRole: 'Admin');
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<FlaggedContentEntity>>> getFlaggedContent({String? status, String? priority, String? type}) async {
    try {
      final items = await remoteDataSource.getFlaggedContent(status: status, priority: priority, type: type);
      return Right(items);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> dismissFlag(String flagId) async {
    try {
      await remoteDataSource.dismissFlag(flagId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> removeContent(String flagId, String reason) async {
    try {
      await remoteDataSource.removeContent(flagId, reason);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> bulkModeration(List<String> flagIds, String action) async {
    try {
      await remoteDataSource.bulkModeration(flagIds, action);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<PenaltyEntity>>> getPenalties({String? query}) async {
    try {
      final penalties = await remoteDataSource.getPenalties(query: query);
      return Right(penalties);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> applyPenalty(String userId, String type, String reason) async {
    try {
      await remoteDataSource.applyPenalty(userId, type, reason);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> overturnPenalty(String penaltyId) async {
    try {
      await remoteDataSource.overturnPenalty(penaltyId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<DisputeEntity>>> getDisputes() async {
    try {
      final disputes = await remoteDataSource.getDisputes();
      return Right(disputes);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> resolveDispute(String disputeId, String resolution) async {
    try {
      await remoteDataSource.resolveDispute(disputeId, resolution);
      await logAudit('Resolved Dispute', detail: 'Dispute ID: $disputeId', severity: 'info', actorRole: 'Admin');
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<AppealEntity>>> getAppeals() async {
    try {
      final appeals = await remoteDataSource.getAppeals();
      return Right(appeals);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> handleAppeal(String appealId, String decision) async {
    try {
      await remoteDataSource.handleAppeal(appealId, decision);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, AnalyticsDataEntity>> getAnalytics(String dateRange, {DateTime? start, DateTime? end}) async {
    try {
      final data = await remoteDataSource.getAnalytics(dateRange, start: start, end: end);
      return Right(data);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, String>> exportSystemData(String type) async {
    try {
      final url = await remoteDataSource.exportSystemData(type);
      return Right(url);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, SystemConfigEntity>> getConfig({String? query}) async {
    try {
      final config = await remoteDataSource.getConfig(query: query);
      return Right(config);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> saveConfig(SystemConfigEntity config) async {
    try {
      final model = SystemConfigModel(
        featureFlags: config.featureFlags,
        matchParams: config.matchParams,
        trustThresholds: config.trustThresholds,
        generalSettings: config.generalSettings,
      );
      await remoteDataSource.saveConfig(model.toJson());
      await logAudit('Updated System Config', detail: 'Modified system parameters', severity: 'warning', actorRole: 'Admin');
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> restoreDefaultConfig() async {
    try {
      await remoteDataSource.restoreDefaultConfig();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<SkillCategoryEntity>>> getCategories() async {
    try {
      final categories = await remoteDataSource.getCategories();
      return Right(categories);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> createCategory(Map<String, dynamic> data) async {
    try {
      await remoteDataSource.createCategory(data);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateCategory(String id, Map<String, dynamic> data) async {
    try {
      await remoteDataSource.updateCategory(id, data);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    try {
      await remoteDataSource.deleteCategory(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> reorderCategories(List<String> orderedIds) async {
    try {
      await remoteDataSource.reorderCategories(orderedIds);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<BroadcastMessageEntity>>> getBroadcasts() async {
    try {
      final broadcasts = await remoteDataSource.getBroadcasts();
      return Right(broadcasts);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> sendBroadcast(String title, String message, String audience, {DateTime? scheduledAt}) async {
    try {
      await remoteDataSource.sendBroadcast(title, message, audience, scheduledAt: scheduledAt);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logAudit(String action, {String detail = '', String severity = 'info', String actorRole = 'User', String? actorId}) async {
    try {
      await remoteDataSource.logAudit(action, detail: detail, severity: severity, actorRole: actorRole, actorId: actorId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<SupportRequestEntity>>> getSupportRequests() async {
    try {
      final requests = await remoteDataSource.getSupportRequests();
      return Right(requests);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> respondToSupportRequest(String requestId, String response) async {
    try {
      await remoteDataSource.respondToSupportRequest(requestId, response);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<AuditLogEntryEntity>>> getAuditLogs({String? actor, String? action, int page = 1, int pageSize = 25}) async {
    try {
      final logs = await remoteDataSource.getAuditLogs(actor: actor, action: action, page: page, pageSize: pageSize);
      return Right(logs);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<AdminRoleEntity>>> getRoles() async {
    try {
      final roles = await remoteDataSource.getRoles();
      return Right(roles);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> createRole(String name, Map<String, List<String>> permissions) async {
    try {
      await remoteDataSource.createRole(name, permissions);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateRole(String id, Map<String, dynamic> data) async {
    try {
      await remoteDataSource.updateRole(id, data);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteRole(String id) async {
    try {
      await remoteDataSource.deleteRole(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, DatabaseStatsEntity>> getDatabaseStats() async {
    try {
      final stats = await remoteDataSource.getDatabaseStats();
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> runBackup() async {
    try {
      await remoteDataSource.runBackup();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> restoreBackup() async {
    try {
      await remoteDataSource.restoreBackup();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> runMaintenance() async {
    try {
      await remoteDataSource.runMaintenance();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> assignEmergencyAdmin(String userId, String verificationToken) async {
    try {
      await remoteDataSource.assignEmergencyAdmin(userId, verificationToken);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> grantTemporaryAdmin(String userId, Duration duration, List<String> permissions) async {
    try {
      await remoteDataSource.grantTemporaryAdmin(userId, duration, permissions);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> rotateRecoveryKeys() async {
    try {
      await remoteDataSource.rotateRecoveryKeys();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
