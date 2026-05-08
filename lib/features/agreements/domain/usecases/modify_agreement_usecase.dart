import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/agreements/domain/entities/agreement_entity.dart';
import 'package:myapp/features/agreements/domain/repository/agreement_repository.dart';

class ModifyAgreementUseCase {
  final AgreementRepository repository;

  ModifyAgreementUseCase({required this.repository});

  Future<Either<Failure, AgreementEntity>> call(
      ModifyAgreementParams params) async {
    return repository.modifyAgreement(
      params.agreementId,
      params.userId,
      params.duration,
      params.frequency,
      params.sessionsCount,
      params.notes,
    );
  }
}

class ModifyAgreementParams extends Equatable {
  final String agreementId;
  final String userId;
  final String duration;
  final String frequency;
  final int sessionsCount;
  final String? notes;

  const ModifyAgreementParams({
    required this.agreementId,
    required this.userId,
    required this.duration,
    required this.frequency,
    required this.sessionsCount,
    this.notes,
  });

  @override
  List<Object?> get props => [
        agreementId,
        userId,
        duration,
        frequency,
        sessionsCount,
        notes,
      ];
}
