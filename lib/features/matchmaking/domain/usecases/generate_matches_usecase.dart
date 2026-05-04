import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/matchmaking/domain/entity/match_entity.dart';
import 'package:myapp/features/matchmaking/domain/repository/match_repository.dart';

class GenerateMatchesUseCase {
  final MatchRepository repository;

  GenerateMatchesUseCase({required this.repository});

  Future<Either<Failure, List<MatchEntity>>> call(
      GenerateMatchesParams params) async {
    return repository.generateMatches(params.userId);
  }
}

class GenerateMatchesParams extends Equatable {
  final String userId;

  const GenerateMatchesParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
