import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/disputes/domain/entities/dispute_entity.dart';
import 'package:myapp/features/disputes/domain/repository/dispute_repository.dart';

class ReportUserUseCase {
  final DisputeRepository repository;

  ReportUserUseCase({required this.repository});

  Future<Either<Failure, DisputeEntity>> call(ReportUserParams params) async {
    return repository.reportUser(
      reporterId: params.reporterId,
      reporterName: params.reporterName,
      reportedUserId: params.reportedUserId,
      reportedUserName: params.reportedUserName,
      reason: params.reason,
      description: params.description,
      evidenceUrls: params.evidenceUrls,
    );
  }
}

class ReportUserParams extends Equatable {
  final String reporterId;
  final String reporterName;
  final String reportedUserId;
  final String reportedUserName;
  final String reason;
  final String description;
  final List<String> evidenceUrls;

  const ReportUserParams({
    required this.reporterId,
    required this.reporterName,
    required this.reportedUserId,
    required this.reportedUserName,
    required this.reason,
    required this.description,
    this.evidenceUrls = const [],
  });

  @override
  List<Object?> get props => [
        reporterId,
        reporterName,
        reportedUserId,
        reportedUserName,
        reason,
        description,
        evidenceUrls,
      ];
}
