import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/matchmaking/domain/entity/match_entity.dart';
import 'package:myapp/features/matchmaking/domain/repository/match_repository.dart';

class UpdateMatchStatusUseCase {
  final MatchRepository repository;

  UpdateMatchStatusUseCase({required this.repository});

  Future<Either<Failure, void>> call(UpdateMatchStatusParams params) async {
    return repository.updateMatchStatus(params.matchId, params.status);
  }
}

class UpdateMatchStatusParams extends Equatable {
  final String matchId;
  final MatchStatus status;

  const UpdateMatchStatusParams({
    required this.matchId,
    required this.status,
  });

  @override
  List<Object?> get props => [matchId, status];
}
