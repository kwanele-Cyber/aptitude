import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/ai/domain/entities/match_optimization_entity.dart';
import 'package:myapp/features/ai/domain/repository/ai_repository.dart';

class OptimizeMatchesUseCase {
  final AiRepository repository;

  OptimizeMatchesUseCase({required this.repository});

  Future<Either<Failure, List<MatchOptimizationEntity>>> call(
      OptimizeMatchesParams params) async {
    return repository.getMatchOptimizations(params.userId);
  }
}

class OptimizeMatchesParams extends Equatable {
  final String userId;

  const OptimizeMatchesParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
