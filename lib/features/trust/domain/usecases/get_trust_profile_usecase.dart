import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/trust/domain/entity/trust_entity.dart';
import 'package:myapp/features/trust/domain/repository/trust_repository.dart';

class GetTrustProfileUseCase {
  final TrustRepository repository;
  GetTrustProfileUseCase({required this.repository});

  Future<Either<Failure, TrustEntity>> call(
      GetTrustProfileParams params) async {
    return repository.getTrustProfile(params.userId);
  }
}

class GetTrustProfileParams extends Equatable {
  final String userId;
  const GetTrustProfileParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
