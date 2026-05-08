import 'package:myapp/features/disputes/data/models/dispute_model.dart';

abstract class DisputeRemoteDataSource {
  Future<void> createDispute(DisputeModel dispute);
  Future<void> updateDispute(String disputeId, Map<String, dynamic> data);
  Future<DisputeModel?> getDispute(String disputeId);
  Future<List<DisputeModel>> fetchDisputesForUser(String userId);
  Future<List<DisputeModel>> fetchAllDisputes();
}

class DisputeRemoteDataSourceMock implements DisputeRemoteDataSource {
  @override
  Future<void> createDispute(DisputeModel dispute) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> updateDispute(
      String disputeId, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<DisputeModel?> getDispute(String disputeId) async {
    await Future.delayed(const Duration(seconds: 1));
    return null;
  }

  @override
  Future<List<DisputeModel>> fetchDisputesForUser(String userId) async {
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }

  @override
  Future<List<DisputeModel>> fetchAllDisputes() async {
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }
}
