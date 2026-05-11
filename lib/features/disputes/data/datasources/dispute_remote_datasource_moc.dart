import 'package:myapp/features/disputes/data/models/dispute_model.dart';
import 'package:myapp/features/disputes/data/datasources/dispute_remote_datasource.dart';

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
