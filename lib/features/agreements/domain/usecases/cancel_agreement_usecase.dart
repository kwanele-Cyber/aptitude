import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/agreements/domain/repository/agreement_repository.dart';

class CancelAgreementUseCase {
  final AgreementRepository repository;

  CancelAgreementUseCase({required this.repository});

  Future<Either<Failure, void>> call(CancelAgreementParams params) async {
    return repository.cancelAgreement(params.agreementId, params.userId);
  }
}

class CancelAgreementParams extends Equatable {
  final String agreementId;
  final String userId;

  const CancelAgreementParams({
    required this.agreementId,
    required this.userId,
  });

  @override
  List<Object?> get props => [agreementId, userId];
}
