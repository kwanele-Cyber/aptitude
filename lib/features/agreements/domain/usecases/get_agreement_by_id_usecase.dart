import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/agreements/domain/entities/agreement_entity.dart';
import 'package:myapp/features/agreements/domain/repository/agreement_repository.dart';

class GetAgreementByIdUseCase {
  final AgreementRepository repository;

  GetAgreementByIdUseCase({required this.repository});

  Future<Either<Failure, AgreementEntity>> call(
      GetAgreementByIdParams params) async {
    return repository.getAgreementById(params.agreementId);
  }
}

class GetAgreementByIdParams extends Equatable {
  final String agreementId;

  const GetAgreementByIdParams({required this.agreementId});

  @override
  List<Object?> get props => [agreementId];
}
