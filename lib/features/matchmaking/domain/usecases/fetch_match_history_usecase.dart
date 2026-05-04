import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/matchmaking/domain/entity/match_entity.dart';
import 'package:myapp/features/matchmaking/domain/repository/match_repository.dart';

class FetchMatchHistoryUseCase {
  final MatchRepository repository;

  FetchMatchHistoryUseCase({required this.repository});

  Future<Either<Failure, List<MatchEntity>>> call(
      FetchMatchHistoryParams params) async {
    return repository.fetchMatchHistory(params.userId);
  }
}

class FetchMatchHistoryParams extends Equatable {
  final String userId;

  const FetchMatchHistoryParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
