import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/disputes/domain/entities/dispute_entity.dart';
import 'package:myapp/features/disputes/domain/repository/dispute_repository.dart';

class ResolveDisputeUseCase {
  final DisputeRepository repository;

  ResolveDisputeUseCase({required this.repository});

  Future<Either<Failure, DisputeEntity>> call(
      ResolveDisputeParams params) async {
    return repository.resolveDispute(
      params.disputeId,
      resolution: params.resolution,
      resolvedBy: params.resolvedBy,
      status: params.status,
    );
  }
}

class ResolveDisputeParams extends Equatable {
  final String disputeId;
  final String resolution;
  final String resolvedBy;
  final DisputeStatus status;

  const ResolveDisputeParams({
    required this.disputeId,
    required this.resolution,
    required this.resolvedBy,
    required this.status,
  });

  @override
  List<Object?> get props => [disputeId, resolution, resolvedBy, status];
}
