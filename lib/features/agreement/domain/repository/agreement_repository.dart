import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/agreement/domain/entity/agreement_entity.dart';

abstract class AgreementRepository {
  /// Create a new agreement proposal
  Future<Either<Failure, AgreementEntity>> createAgreement(AgreementEntity agreement);
  
  /// Get agreement by ID
  Future<Either<Failure, AgreementEntity>> getAgreement(String id);
  
  /// Get all agreements for a user (as initiator or partner)
  Future<Either<Failure, List<AgreementEntity>>> getUserAgreements(String userId);
  
  /// Get active agreements for a user
  Future<Either<Failure, List<AgreementEntity>>> getActiveAgreements(String userId);
  
  /// Accept a pending agreement
  Future<Either<Failure, AgreementEntity>> acceptAgreement(String id);
  
  /// Decline a pending agreement
  Future<Either<Failure, AgreementEntity>> declineAgreement(String id, {String? reason});
  
  /// Propose modifications to an agreement
  Future<Either<Failure, AgreementEntity>> proposeModifications(String id, Map<String, dynamic> modifications, String notes);
  
  /// Accept a modification proposal
  Future<Either<Failure, AgreementEntity>> acceptModifications(String id);
  
  /// Decline a modification proposal
  Future<Either<Failure, AgreementEntity>> declineModifications(String id);
  
  /// Cancel an agreement (by either party)
  Future<Either<Failure, AgreementEntity>> cancelAgreement(String id, String reason);
  
  /// Complete an agreement (after all sessions done)
  Future<Either<Failure, AgreementEntity>> completeAgreement(String id);
  
  /// Stream real-time updates for an agreement
  Stream<Either<Failure, AgreementEntity>> watchAgreement(String id);
  
  /// Stream user's agreements
  Stream<Either<Failure, List<AgreementEntity>>> watchUserAgreements(String userId);
}