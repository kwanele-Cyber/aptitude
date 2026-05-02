import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/core/data/models/agreement.dart';
import 'package:myapp/core/services/firebase_service.dart';
import 'package:myapp/core/services/interfaces/database_inteface.dart';

class AgreementRepository {
  final String _path = "agreements";
  late final DatabaseService<DataSnapshot> _databaseService;

  AgreementRepository({DatabaseService<DataSnapshot>? databaseService}) {
    _databaseService = databaseService ?? FirebaseService();
  }

  Future<void> createAgreement(Agreement agreement) async {
    await _databaseService.create(
      location: "$_path/${agreement.id}",
      data: agreement.toJson(),
    );
  }

  Future<void> updateStatus(String id, AgreementStatus status) async {
    await _databaseService.update(
      location: "$_path/$id",
      data: {
        'status': status.index,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  Future<void> modifyAgreementTerms({
    required String id,
    required int sessionsCount,
    required int minutesPerSession,
    required String frequency,
  }) async {
    await _databaseService.update(
      location: "$_path/$id",
      data: {
        'sessionsCount': sessionsCount,
        'minutesPerSession': minutesPerSession,
        'frequency': frequency,
        'status': AgreementStatus.pending.index,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  Future<Agreement?> getAgreement(String id) async {
    final snapshot = await _databaseService.read(location: "$_path/$id");
    if (snapshot != null && snapshot.exists && snapshot.value != null) {
      return Agreement.fromJson(Map<String, dynamic>.from(snapshot.value as Map));
    }
    return null;
  }

  Future<List<Agreement>> listByChannel(String channelId) async {
    final snapshot = await _databaseService.list(location: _path);
    if (snapshot != null && snapshot.exists && snapshot.value != null) {
      final Map<dynamic, dynamic> map = snapshot.value as Map;
      return map.values
          .map((v) => Agreement.fromJson(Map<String, dynamic>.from(v as Map)))
          .where((a) => a.channelId == channelId)
          .toList();
    }
    return [];
  }
}
