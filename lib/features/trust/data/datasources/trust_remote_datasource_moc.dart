import 'package:myapp/features/trust/data/models/trust_model.dart';
import 'package:myapp/features/trust/domain/entity/trust_entity.dart';
import 'package:myapp/features/trust/data/datasources/trust_remote_datasource.dart';

class TrustRemoteDataSourceMock implements TrustRemoteDataSource {
  @override
  Future<TrustModel> calculateTrustScore(String userId) async {
    await Future.delayed(const Duration(seconds: 1));
    return TrustModel(
      id: 'trust_$userId',
      userId: userId,
      score: 75,
      factors: [
        TrustFactorModel(
          name: 'Completed Sessions',
          impact: TrustFactorImpact.positive,
          description: 'Number of successfully completed skill sessions',
          weight: 30,
        ),
        TrustFactorModel(
          name: 'Positive Ratings',
          impact: TrustFactorImpact.positive,
          description: 'Average rating from session partners',
          weight: 25,
        ),
        TrustFactorModel(
          name: 'Cancellation Rate',
          impact: TrustFactorImpact.negative,
          description: 'Percentage of sessions cancelled',
          weight: -20,
        ),
      ],
      lastCalculated: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<TrustModel> updateReputation(
      String userId, String event, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 1));
    return TrustModel(
      id: 'trust_$userId',
      userId: userId,
      score: 80,
      factors: [],
      lastCalculated: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<List<String>> getUsersAboveTrustThreshold(int threshold) async {
    await Future.delayed(const Duration(seconds: 1));
    return ['user1', 'user2', 'user3'];
  }

  @override
  Future<TrustModel> getTrustProfile(String userId) async {
    await Future.delayed(const Duration(seconds: 1));
    return TrustModel(
      id: 'trust_$userId',
      userId: userId,
      score: 75,
      factors: [
        TrustFactorModel(
          name: 'Completed Sessions',
          impact: TrustFactorImpact.positive,
          description: 'Number of successfully completed skill sessions',
          weight: 30,
        ),
      ],
      lastCalculated: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<TrustAppealModel> submitAppeal(
      String userId, String reason) async {
    await Future.delayed(const Duration(seconds: 1));
    return TrustAppealModel(
      id: 'appeal_1',
      userId: userId,
      reason: reason,
      status: AppealStatus.pending,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<List<TrustAppealModel>> getAppeals(String userId) async {
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }
}
