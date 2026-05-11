import 'package:myapp/features/policies/data/models/policy_acknowledgment_model.dart';
import 'package:myapp/features/policies/data/models/policy_model.dart';

abstract class PoliciesRemoteDataSource {
  Future<List<PolicyModel>> getPolicies();
  Future<List<PolicyAcknowledgmentModel>> getAcknowledgments(String userId);
  Future<void> acknowledgePolicy(
      String userId, String policyId, String version);
}

