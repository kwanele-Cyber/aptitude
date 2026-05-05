import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/admin/data/datasources/admin_remote_datasource.dart';
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
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser(String userId) async {
    try {
      await remoteDataSource.deleteUser(userId);
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
  Future<Either<Failure, List<PenaltyEntity>>> getPenalties() async {
    try {
      final penalties = await remoteDataSource.getPenalties();
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
  Future<Either<Failure, AnalyticsDataEntity>> getAnalytics(String dateRange, {DateTime? start, DateTime? end}) async {
    try {
      final data = await remoteDataSource.getAnalytics(dateRange, start: start, end: end);
      return Right(data);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, SystemConfigEntity>> getConfig() async {
    try {
      final config = await remoteDataSource.getConfig();
      return Right(config);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> saveConfig(SystemConfigEntity config) async {
    try {
      await remoteDataSource.saveConfig((config as dynamic).toJson() as Map<String, dynamic>);
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
  Future<Either<Failure, List<AuditLogEntryEntity>>> getAuditLogs({String? admin, String? action, int page = 1, int pageSize = 25}) async {
    try {
      final logs = await remoteDataSource.getAuditLogs(admin: admin, action: action, page: page, pageSize: pageSize);
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
}
