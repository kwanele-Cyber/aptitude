import 'package:myapp/features/agreements/data/models/agreement_model.dart';

abstract class AgreementRemoteDataSource {
  Future<void> createAgreement(AgreementModel agreement);
  Future<void> updateAgreement(String agreementId, Map<String, dynamic> data);
  Future<AgreementModel?> getAgreement(String agreementId);
  Future<List<AgreementModel>> fetchAgreementsForUser(String userId);
}

