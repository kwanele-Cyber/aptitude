import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/disputes/domain/entities/dispute_entity.dart';
import 'package:myapp/features/disputes/domain/repository/dispute_repository.dart';

class CreateDisputeUseCase {
  final DisputeRepository repository;

  CreateDisputeUseCase({required this.repository});

  Future<Either<Failure, DisputeEntity>> call(
      CreateDisputeParams params) async {
    return repository.createDispute(
      reporterId: params.reporterId,
      reporterName: params.reporterName,
      respondentId: params.respondentId,
      reason: params.reason,
      description: params.description,
      agreementId: params.agreementId,
      sessionId: params.sessionId,
      evidenceUrls: params.evidenceUrls,
    );
  }
}

class CreateDisputeParams extends Equatable {
  final String reporterId;
  final String reporterName;
  final String respondentId;
  final String reason;
  final String description;
  final String? agreementId;
  final String? sessionId;
  final List<String> evidenceUrls;

  const CreateDisputeParams({
    required this.reporterId,
    required this.reporterName,
    required this.respondentId,
    required this.reason,
    required this.description,
    this.agreementId,
    this.sessionId,
    this.evidenceUrls = const [],
  });

  @override
  List<Object?> get props => [
        reporterId,
        reporterName,
        respondentId,
        reason,
        description,
        agreementId,
        sessionId,
        evidenceUrls,
      ];
}
