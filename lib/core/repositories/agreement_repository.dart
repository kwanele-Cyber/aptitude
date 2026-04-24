import 'package:myapp/core/models/agreement_model.dart';
import 'package:myapp/core/services/base_database_service.dart';
import 'package:myapp/core/exceptions/custom_exception.dart';
import 'package:firebase_database/firebase_database.dart';

abstract class AgreementRepository {
  Future<void> createAgreement(AgreementModel agreement);
  Future<List<AgreementModel>> getAgreementsForUser(String userId);
  Future<void> updateAgreementStatus(String agreementId, AgreementStatus status);
  Future<List<AgreementModel>> getAgreementHistory(String agreementId);
}

class AgreementRepositoryImpl extends BaseDatabaseService implements AgreementRepository {
  AgreementRepositoryImpl({FirebaseDatabase? database}) : super(database: database);
  @override
  Future<void> createAgreement(AgreementModel agreement) async {
    try {
      await setData(path: 'agreements/${agreement.id}', data: agreement.toJson());
    } catch (e) {
      throw DatabaseException("Failed to create agreement: ${e.toString()}", "agreement-create-error");
    }
  }

  @override
  Future<List<AgreementModel>> getAgreementsForUser(String userId) async {
    try {
      final snapshot1 = await getRef('agreements')
          .orderByChild('learnerId')
          .equalTo(userId)
          .get();
      
      final snapshot2 = await getRef('agreements')
          .orderByChild('mentorId')
          .equalTo(userId)
          .get();

      final List<AgreementModel> results = [];

      if (snapshot1.exists) {
        final Map<dynamic, dynamic> map = snapshot1.value as Map<dynamic, dynamic>;
        results.addAll(map.values.map((v) => AgreementModel.fromJson(Map<String, dynamic>.from(v as Map))));
      }

      if (snapshot2.exists) {
        final Map<dynamic, dynamic> map = snapshot2.value as Map<dynamic, dynamic>;
        results.addAll(map.values.map((v) => AgreementModel.fromJson(Map<String, dynamic>.from(v as Map))));
      }

      // Remove duplicates just in case (e.g. mentor == learner)
      final uniqueResults = { for (var item in results) item.id : item }.values.toList();

      return uniqueResults;
    } catch (e) {
      throw DatabaseException("Failed to fetch agreements: ${e.toString()}", "agreement-fetch-error");
    }
  }

  @override
  Future<void> updateAgreementStatus(String agreementId, AgreementStatus status) async {
    try {
      await updateData(path: 'agreements/$agreementId', data: {'status': status.name});
    } catch (e) {
      throw DatabaseException("Failed to update agreement status: ${e.toString()}", "agreement-update-error");
    }
  }

  @override
  Future<List<AgreementModel>> getAgreementHistory(String agreementId) async {
    try {
      List<AgreementModel> history = [];
      String? currentId = agreementId;

      while (currentId != null) {
        final snapshot = await getRef('agreements/$currentId').get();
        if (!snapshot.exists) break;

        final agreement = AgreementModel.fromJson(Map<String, dynamic>.from(snapshot.value as Map));
        history.add(agreement);
        currentId = agreement.parentId;
      }

      return history;
    } catch (e) {
      throw DatabaseException("Failed to fetch agreement history: ${e.toString()}", "agreement-history-error");
    }
  }
}

