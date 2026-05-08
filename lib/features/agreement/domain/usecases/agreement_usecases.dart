import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/lib/features/agreement/domain/entity/agreement_entity.dart';
import 'package:myapp/lib/features/agreement/domain/repository/agreement_repository.dart';

class CreateAgreementUseCase {
  final AgreementRepository repository;
  CreateAgreementUseCase(this.repository);
  
  Future<Either<Failure, AgreementEntity>> call(AgreementEntity agreement) {
    return repository.createAgreement(agreement);
  }
}

class GetAgreementUseCase {
  final AgreementRepository repository;
  GetAgreementUseCase(this.repository);
  
  Future<Either<Failure, AgreementEntity>> call(String id) {
    return repository.getAgreement(id);
  }
}

class GetUserAgreementsUseCase {
  final AgreementRepository repository;
  GetUserAgreementsUseCase(this.repository);
  
  Future<Either<Failure, List<AgreementEntity>>> call(String userId) {
    return repository.getUserAgreements(userId);
  }
}

class AcceptAgreementUseCase {
  final AgreementRepository repository;
  AcceptAgreementUseCase(this.repository);
  
  Future<Either<Failure, AgreementEntity>> call(String id) {
    return repository.acceptAgreement(id);
  }
}

class DeclineAgreementUseCase {
  final AgreementRepository repository;
  DeclineAgreementUseCase(this.repository);
  
  Future<Either<Failure, AgreementEntity>> call(String id, {String? reason}) {
    return repository.declineAgreement(id, reason: reason);
  }
}

class ProposeModificationsUseCase {
  final AgreementRepository repository;
  ProposeModificationsUseCase(this.repository);
  
  Future<Either<Failure, AgreementEntity>> call(
    String id,
    Map<String, dynamic> modifications,
    String notes,
  ) {
    return repository.proposeModifications(id, modifications, notes);
  }
}

class AcceptModificationsUseCase {
  final AgreementRepository repository;
  AcceptModificationsUseCase(this.repository);
  
  Future<Either<Failure, AgreementEntity>> call(String id) {
    return repository.acceptModifications(id);
  }
}

class DeclineModificationsUseCase {
  final AgreementRepository repository;
  DeclineModificationsUseCase(this.repository);
  
  Future<Either<Failure, AgreementEntity>> call(String id) {
    return repository.declineModifications(id);
  }
}

class CancelAgreementUseCase {
  final AgreementRepository repository;
  CancelAgreementUseCase(this.repository);
  
  Future<Either<Failure, AgreementEntity>> call(String id, String reason) {
    return repository.cancelAgreement(id, reason);
  }
}

class CompleteAgreementUseCase {
  final AgreementRepository repository;
  CompleteAgreementUseCase(this.repository);
  
  Future<Either<Failure, AgreementEntity>> call(String id) {
    return repository.completeAgreement(id);
  }
}

class WatchAgreementUseCase {
  final AgreementRepository repository;
  WatchAgreementUseCase(this.repository);
  
  Stream<Either<Failure, AgreementEntity>> call(String id) {
    return repository.watchAgreement(id);
  }
}

class WatchUserAgreementsUseCase {
  final AgreementRepository repository;
  WatchUserAgreementsUseCase(this.repository);
  
  Stream<Either<Failure, List<AgreementEntity>>> call(String userId) {
    return repository.watchUserAgreements(userId);
  }
}