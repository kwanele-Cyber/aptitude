import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/matchmaking/domain/repository/match_repository.dart';

class CreateDirectMatchUseCase {
  final MatchRepository repository;

  CreateDirectMatchUseCase({required this.repository});

  Future<Either<Failure, String>> call(CreateDirectMatchParams params) async {
    return repository.createDirectMatch(params.matchData);
  }
}

class CreateDirectMatchParams extends Equatable {
  final Map<String, dynamic> matchData;

  const CreateDirectMatchParams({required this.matchData});

  @override
  List<Object?> get props => [matchData];
}
