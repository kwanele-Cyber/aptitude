import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/matchmaking/data/datasources/match_remote_datasource.dart';
import 'package:myapp/features/matchmaking/domain/entity/match_entity.dart';
import 'package:myapp/features/matchmaking/domain/repository/match_repository.dart';

class MatchRepositoryImpl implements MatchRepository {
  final MatchRemoteDataSource remoteDataSource;

  MatchRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<MatchEntity>>> generateMatches(
      String userId) async {
    try {
      // generateMatches in datasource fetches all skills internally
      final matches = await remoteDataSource.generateMatches(userId, []);
      return Right(matches);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateMatchStatus(
      String matchId, MatchStatus status) async {
    try {
      await remoteDataSource.updateMatchStatus(matchId, {
        'status': status.name,
      });
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> saveMatch(String matchId) async {
    try {
      await remoteDataSource.updateMatchStatus(matchId, {
        'saved': true,
      });
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<MatchEntity>>> fetchMatchHistory(
      String userId) async {
    try {
      final matches = await remoteDataSource.fetchMatchesForUser(userId);
      return Right(matches);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
