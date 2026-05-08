import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/trust/domain/entity/trust_entity.dart';
import 'package:myapp/features/trust/domain/repository/trust_repository.dart';

class UpdateReputationUseCase {
  final TrustRepository repository;
  UpdateReputationUseCase({required this.repository});

  Future<Either<Failure, TrustEntity>> call(
      UpdateReputationParams params) async {
    return repository.updateReputation(
        params.userId, params.event, params.data);
  }
}

class UpdateReputationParams extends Equatable {
  final String userId;
  final String event;
  final Map<String, dynamic> data;

  const UpdateReputationParams({
    required this.userId,
    required this.event,
    required this.data,
  });

  @override
  List<Object?> get props => [userId, event, data];
}
