import 'package:myapp/features/trust/data/models/trust_model.dart';
import 'package:myapp/features/trust/domain/entity/trust_entity.dart';

abstract class TrustRemoteDataSource {
  Future<TrustModel> calculateTrustScore(String userId);
  Future<TrustModel> updateReputation(
      String userId, String event, Map<String, dynamic> data);
  Future<List<String>> getUsersAboveTrustThreshold(int threshold);
  Future<TrustModel> getTrustProfile(String userId);
  Future<TrustAppealModel> submitAppeal(String userId, String reason);
  Future<List<TrustAppealModel>> getAppeals(String userId);
}

