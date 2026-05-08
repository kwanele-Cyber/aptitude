import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/ai/domain/entities/behavior_flag_entity.dart';
import 'package:myapp/features/ai/domain/repository/ai_repository.dart';

class AnalyzeBehaviorUseCase {
  final AiRepository repository;

  AnalyzeBehaviorUseCase({required this.repository});

  Future<Either<Failure, List<BehaviorFlagEntity>>> call(
      AnalyzeBehaviorParams params) async {
    return repository.analyzeBehavior(params.userId);
  }
}

class AnalyzeBehaviorParams extends Equatable {
  final String userId;

  const AnalyzeBehaviorParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
