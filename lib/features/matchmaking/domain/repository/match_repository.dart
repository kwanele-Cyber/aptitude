import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/matchmaking/domain/entity/match_entity.dart';

abstract class MatchRepository {
  Future<Either<Failure, List<MatchEntity>>> generateMatches(String userId);
  Future<Either<Failure, void>> updateMatchStatus(
      String matchId, MatchStatus status);
  Future<Either<Failure, void>> saveMatch(String matchId);
  Future<Either<Failure, List<MatchEntity>>> fetchMatchHistory(String userId);
  Future<Either<Failure, String>> createDirectMatch(Map<String, dynamic> matchData);
  Future<Either<Failure, void>> submitFeedback(
      String matchId, int rating, String? comment);
}
