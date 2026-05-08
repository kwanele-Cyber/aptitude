import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/agreements/domain/entities/agreement_entity.dart';
import 'package:myapp/features/agreements/domain/repository/agreement_repository.dart';

class ViewAgreementsUseCase {
  final AgreementRepository repository;

  ViewAgreementsUseCase({required this.repository});

  Future<Either<Failure, List<AgreementEntity>>> call(
      ViewAgreementsParams params) async {
    return repository.viewAgreements(params.userId);
  }
}

class ViewAgreementsParams extends Equatable {
  final String userId;

  const ViewAgreementsParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
