import 'package:dartz/dartz.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/trust/domain/entity/trust_entity.dart';

abstract class TrustRepository {
  Future<Either<Failure, TrustEntity>> calculateTrustScore(String userId);

  Future<Either<Failure, TrustEntity>> updateReputation(
    String userId,
    String event,
    Map<String, dynamic> data,
  );

  Future<Either<Failure, List<String>>> getUsersAboveTrustThreshold(
      int threshold);

  Future<Either<Failure, TrustEntity>> getTrustProfile(String userId);

  Future<Either<Failure, TrustAppealEntity>> submitAppeal(
      String userId, String reason);

  Future<Either<Failure, List<TrustAppealEntity>>> getAppeals(String userId);
}
