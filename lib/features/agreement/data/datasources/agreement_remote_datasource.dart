import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/features/agreement/data/models/agreement_model.dart';
import 'package:rxdart/rxdart.dart';

abstract class AgreementRemoteDataSource {
  Future<AgreementModel> createAgreement(AgreementModel agreement);
  Future<AgreementModel> getAgreement(String id);
  Future<List<AgreementModel>> getUserAgreements(String userId);
  Future<AgreementModel> updateAgreement(String id, Map<String, dynamic> updates);
  Future<void> deleteAgreement(String id);
  Stream<AgreementModel> watchAgreement(String id);
  Stream<List<AgreementModel>> watchUserAgreements(String userId);
}

class AgreementRemoteDataSourceFirebase implements AgreementRemoteDataSource {
  final FirebaseDatabase _database;

  AgreementRemoteDataSourceFirebase({FirebaseDatabase? database})
      : _database = database ?? FirebaseDatabase.instance;

  DatabaseReference get _agreementsRef => _database.ref('agreements');

  @override
  Future<AgreementModel> createAgreement(AgreementModel agreement) async {
    try {
      final ref = _agreementsRef.push();
      final data = agreement.toJson();
      await ref.set(data);
      return AgreementModel.fromJson(ref.key!, data);
    } catch (e) {
      throw ServerException('Failed to create agreement: $e');
    }
  }

  @override
  Future<AgreementModel> getAgreement(String id) async {
    try {
      final snapshot = await _agreementsRef.child(id).get();
      if (!snapshot.exists) throw ServerException('Agreement not found');
      return AgreementModel.fromJson(id, Map<String, dynamic>.from(snapshot.value as Map));
    } catch (e) {
      throw ServerException('Failed to load agreement: $e');
    }
  }

  @override
  Future<List<AgreementModel>> getUserAgreements(String userId) async {
    try {
      final snapshot = await _agreementsRef
          .orderByChild('initiatorId')
          .equalTo(userId)
          .get();
      
      final agreements = <AgreementModel>[];
      
      if (snapshot.exists) {
        final map = Map<String, dynamic>.from(snapshot.value as Map);
        map.forEach((key, value) {
          agreements.add(AgreementModel.fromJson(key, Map<String, dynamic>.from(value as Map)));
        });
      }

      // Also get agreements where user is partner
      final partnerSnapshot = await _agreementsRef
          .orderByChild('partnerId')
          .equalTo(userId)
          .get();
          
      if (partnerSnapshot.exists) {
        final map = Map<String, dynamic>.from(partnerSnapshot.value as Map);
        map.forEach((key, value) {
          agreements.add(AgreementModel.fromJson(key, Map<String, dynamic>.from(value as Map)));
        });
      }

      // Remove duplicates and sort by createdAt (newest first)
      final unique = agreements.toSet().toList();
      unique.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return unique;
    } catch (e) {
      throw ServerException('Failed to load user agreements: $e');
    }
  }

  @override
  Future<AgreementModel> updateAgreement(String id, Map<String, dynamic> updates) async {
    try {
      await _agreementsRef.child(id).update(updates);
      return getAgreement(id);
    } catch (e) {
      throw ServerException('Failed to update agreement: $e');
    }
  }

  @override
  Future<void> deleteAgreement(String id) async {
    try {
      await _agreementsRef.child(id).remove();
    } catch (e) {
      throw ServerException('Failed to delete agreement: $e');
    }
  }

  @override
  Stream<AgreementModel> watchAgreement(String id) {
    return _agreementsRef.child(id).onValue.map((event) {
      if (!event.snapshot.exists) throw ServerException('Agreement not found');
      return AgreementModel.fromJson(id, Map<String, dynamic>.from(event.snapshot.value as Map));
    });
  }

  @override
  Stream<List<AgreementModel>> watchUserAgreements(String userId) {
    // Combine streams for initiator and partner
    final initiatorStream = _agreementsRef
        .orderByChild('initiatorId')
        .equalTo(userId)
        .onValue
        .map((event) => _extractAgreements(event, userId));
    
    final partnerStream = _agreementsRef
        .orderByChild('partnerId')
        .equalTo(userId)
        .onValue
        .map((event) => _extractAgreements(event, userId));
    
    // Merge and deduplicate
    return StreamZip([initiatorStream, partnerStream]).map((lists) {
      final all = [...lists[0], ...lists[1]];
      final unique = all.toSet().toList();
      unique.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return unique;
    });
  }

  List<AgreementModel> _extractAgreements(DatabaseEvent event, String userId) {
    final agreements = <AgreementModel>[];
    if (event.snapshot.exists && event.snapshot.value != null) {
      final map = Map<String, dynamic>.from(event.snapshot.value as Map);
      map.forEach((key, value) {
        final agreement = AgreementModel.fromJson(key, Map<String, dynamic>.from(value as Map));
        // Only include if user is involved
        if (agreement.initiatorId == userId || agreement.partnerId == userId) {
          agreements.add(agreement);
        }
      });
    }
    return agreements;
  }
}
