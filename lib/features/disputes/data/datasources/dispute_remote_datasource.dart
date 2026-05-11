import 'package:myapp/features/disputes/data/models/dispute_model.dart';

abstract class DisputeRemoteDataSource {
  Future<void> createDispute(DisputeModel dispute);
  Future<void> updateDispute(String disputeId, Map<String, dynamic> data);
  Future<DisputeModel?> getDispute(String disputeId);
  Future<List<DisputeModel>> fetchDisputesForUser(String userId);
  Future<List<DisputeModel>> fetchAllDisputes();
}

