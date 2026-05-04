import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/matchmaking/domain/repository/match_repository.dart';

class SaveMatchUseCase {
  final MatchRepository repository;

  SaveMatchUseCase({required this.repository});

  Future<Either<Failure, void>> call(SaveMatchParams params) async {
    return repository.saveMatch(params.matchId);
  }
}

class SaveMatchParams extends Equatable {
  final String matchId;

  const SaveMatchParams({required this.matchId});

  @override
  List<Object?> get props => [matchId];
}
