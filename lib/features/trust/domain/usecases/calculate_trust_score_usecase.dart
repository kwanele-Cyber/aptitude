import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/trust/domain/entity/trust_entity.dart';
import 'package:myapp/features/trust/domain/repository/trust_repository.dart';

class CalculateTrustScoreUseCase {
  final TrustRepository repository;
  CalculateTrustScoreUseCase({required this.repository});

  Future<Either<Failure, TrustEntity>> call(
      CalculateTrustScoreParams params) async {
    return repository.calculateTrustScore(params.userId);
  }
}

class CalculateTrustScoreParams extends Equatable {
  final String userId;
  const CalculateTrustScoreParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
