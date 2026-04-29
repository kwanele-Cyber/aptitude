import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/core/services/firebase_service.dart';
import 'package:myapp/core/services/interfaces/database_inteface.dart';
import '../models/skill_offer.dart';
import '../models/skill_request.dart';

class UserSkillsRepository {
  final String _baseOfferPath = "skill_offers";
  final String _baseRequestPath = "skill_requests";
  late final DatabaseService<DataSnapshot> _databaseService;

  UserSkillsRepository({DatabaseService<DataSnapshot>? databaseService}) {
    _databaseService = databaseService ?? FirebaseService();
  }

  /// Adds a skill offer for a specific user
  Future<void> addOffer(SkillOffer offer) async {
    // Generate a predictable composite ID: {sid}--{uid}
    final compositeId = "${offer.sid}--${offer.uid}";
    final offerWithId = offer.copyWith(id: compositeId);

    await _databaseService.create(
      location: "$_baseOfferPath/${offer.uid}/$compositeId",
      data: offerWithId.toJson(),
    );
  }

  /// Gets all skill offers for a specific user
  Future<List<SkillOffer>> getUserOffers(String uid) async {
    final snapshot = await _databaseService.list(location: "$_baseOfferPath/$uid");
    if (snapshot != null && snapshot.exists && snapshot.value != null) {
      final Map<dynamic, dynamic> map = snapshot.value as Map;
      return map.values
          .map((s) => SkillOffer.fromJson(Map<String, dynamic>.from(s as Map)))
          .toList();
    }
    return [];
  }

  /// Gets a specific offer
  Future<SkillOffer?> getOffer(String uid, String offerId) async {
    final snapshot = await _databaseService.read(location: "$_baseOfferPath/$uid/$offerId");
    if (snapshot != null && snapshot.exists && snapshot.value != null) {
      return SkillOffer.fromJson(Map<String, dynamic>.from(snapshot.value as Map));
    }
    return null;
  }

  /// Adds a skill request for a specific user
  Future<void> addRequest(SkillRequest request) async {
    // Generate a predictable composite ID: {sid}--{uid}
    final compositeId = "${request.sid}--${request.uid}";
    final requestWithId = request.copyWith(id: compositeId);

    await _databaseService.create(
      location: "$_baseRequestPath/${request.uid}/$compositeId",
      data: requestWithId.toJson(),
    );
  }

  /// Gets all skill requests for a specific user
  Future<List<SkillRequest>> getUserRequests(String uid) async {
    final snapshot = await _databaseService.list(location: "$_baseRequestPath/$uid");
    if (snapshot != null && snapshot.exists && snapshot.value != null) {
      final Map<dynamic, dynamic> map = snapshot.value as Map;
      return map.values
          .map((s) => SkillRequest.fromJson(Map<String, dynamic>.from(s as Map)))
          .toList();
    }
    return [];
  }

  /// Gets a specific request
  Future<SkillRequest?> getRequest(String uid, String requestId) async {
    final snapshot = await _databaseService.read(location: "$_baseRequestPath/$uid/$requestId");
    if (snapshot != null && snapshot.exists && snapshot.value != null) {
      return SkillRequest.fromJson(Map<String, dynamic>.from(snapshot.value as Map));
    }
    return null;
  }

  /// Deletes a specific offer
  Future<void> deleteOffer(String uid, String offerId) async {
    await _databaseService.delete(location: "$_baseOfferPath/$uid/$offerId");
  }

  /// Updates an existing offer
  Future<void> updateOffer(SkillOffer offer) async {
    await _databaseService.update(
      location: "$_baseOfferPath/${offer.uid}/${offer.id}",
      data: offer.toJson(),
    );
  }

  /// Deletes a specific request
  Future<void> deleteRequest(String uid, String requestId) async {
    await _databaseService.delete(location: "$_baseRequestPath/$uid/$requestId");
  }

  /// Updates an existing request
  Future<void> updateRequest(SkillRequest request) async {
    await _databaseService.update(
      location: "$_baseRequestPath/${request.uid}/${request.id}",
      data: request.toJson(),
    );
  }
}
