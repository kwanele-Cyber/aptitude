import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/disputes/domain/entities/dispute_entity.dart';
import 'package:myapp/features/disputes/domain/repository/dispute_repository.dart';

class AppealDecisionUseCase {
  final DisputeRepository repository;

  AppealDecisionUseCase({required this.repository});

  Future<Either<Failure, DisputeEntity>> call(
      AppealDecisionParams params) async {
    return repository.appealDecision(
      params.disputeId,
      appealReason: params.appealReason,
    );
  }
}

class AppealDecisionParams extends Equatable {
  final String disputeId;
  final String appealReason;

  const AppealDecisionParams({
    required this.disputeId,
    required this.appealReason,
  });

  @override
  List<Object?> get props => [disputeId, appealReason];
}
