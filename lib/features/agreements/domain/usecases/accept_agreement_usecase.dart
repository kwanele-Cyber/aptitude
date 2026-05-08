import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/agreements/domain/repository/agreement_repository.dart';

class AcceptAgreementUseCase {
  final AgreementRepository repository;

  AcceptAgreementUseCase({required this.repository});

  Future<Either<Failure, void>> call(AcceptAgreementParams params) async {
    return repository.acceptAgreement(params.agreementId, params.userId);
  }
}

class AcceptAgreementParams extends Equatable {
  final String agreementId;
  final String userId;

  const AcceptAgreementParams({
    required this.agreementId,
    required this.userId,
  });

  @override
  List<Object?> get props => [agreementId, userId];
}
