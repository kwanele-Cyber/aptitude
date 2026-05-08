import 'package:myapp/features/agreements/data/models/agreement_model.dart';

abstract class AgreementRemoteDataSource {
  Future<void> createAgreement(AgreementModel agreement);
  Future<void> updateAgreement(String agreementId, Map<String, dynamic> data);
  Future<AgreementModel?> getAgreement(String agreementId);
  Future<List<AgreementModel>> fetchAgreementsForUser(String userId);
}

class AgreementRemoteDataSourceMock implements AgreementRemoteDataSource {
  @override
  Future<void> createAgreement(AgreementModel agreement) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<void> updateAgreement(String agreementId, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<AgreementModel?> getAgreement(String agreementId) async {
    await Future.delayed(const Duration(seconds: 1));
    return null;
  }

  @override
  Future<List<AgreementModel>> fetchAgreementsForUser(String userId) async {
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }
}
