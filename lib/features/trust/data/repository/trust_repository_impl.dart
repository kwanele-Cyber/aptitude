import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/trust/data/datasources/trust_remote_datasource.dart';
import 'package:myapp/features/trust/domain/entity/trust_entity.dart';
import 'package:myapp/features/trust/domain/repository/trust_repository.dart';

class TrustRepositoryImpl implements TrustRepository {
  final TrustRemoteDataSource remoteDataSource;
  TrustRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, TrustEntity>> calculateTrustScore(
      String userId) async {
    try {
      final result = await remoteDataSource.calculateTrustScore(userId);
      return Right(result);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, TrustEntity>> updateReputation(
    String userId,
    String event,
    Map<String, dynamic> data,
  ) async {
    try {
      final result =
          await remoteDataSource.updateReputation(userId, event, data);
      return Right(result);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<String>>> getUsersAboveTrustThreshold(
      int threshold) async {
    try {
      final result =
          await remoteDataSource.getUsersAboveTrustThreshold(threshold);
      return Right(result);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, TrustEntity>> getTrustProfile(String userId) async {
    try {
      final result = await remoteDataSource.getTrustProfile(userId);
      return Right(result);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, TrustAppealEntity>> submitAppeal(
      String userId, String reason) async {
    try {
      final result = await remoteDataSource.submitAppeal(userId, reason);
      return Right(result);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<TrustAppealEntity>>> getAppeals(
      String userId) async {
    try {
      final result = await remoteDataSource.getAppeals(userId);
      return Right(result);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
