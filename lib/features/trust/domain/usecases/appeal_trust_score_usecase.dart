import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/trust/domain/entity/trust_entity.dart';
import 'package:myapp/features/trust/domain/repository/trust_repository.dart';

class AppealTrustScoreUseCase {
  final TrustRepository repository;
  AppealTrustScoreUseCase({required this.repository});

  Future<Either<Failure, TrustAppealEntity>> call(
      AppealTrustScoreParams params) async {
    return repository.submitAppeal(params.userId, params.reason);
  }
}

class AppealTrustScoreParams extends Equatable {
  final String userId;
  final String reason;
  const AppealTrustScoreParams({
    required this.userId,
    required this.reason,
  });

  @override
  List<Object?> get props => [userId, reason];
}

class GetAppealsUseCase {
  final TrustRepository repository;
  GetAppealsUseCase({required this.repository});

  Future<Either<Failure, List<TrustAppealEntity>>> call(
      GetAppealsParams params) async {
    return repository.getAppeals(params.userId);
  }
}

class GetAppealsParams extends Equatable {
  final String userId;
  const GetAppealsParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
