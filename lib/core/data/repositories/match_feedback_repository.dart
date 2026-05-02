import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/core/data/models/match_feedback.dart';
import 'package:myapp/core/services/firebase_service.dart';
import 'package:myapp/core/services/interfaces/database_inteface.dart';

class MatchFeedbackRepository {
  final String _basePath = 'match_feedback';
  DatabaseService<DataSnapshot>? _databaseService;

  MatchFeedbackRepository({DatabaseService<DataSnapshot>? databaseService}) {
    _databaseService = databaseService ?? FirebaseService();
  }

  Future<void> submit(MatchFeedback feedback) async {
    await _databaseService!.create(
      location: '$_basePath/${feedback.id}',
      data: feedback.toJson(),
    );
  }

  Future<List<MatchFeedback>> listForUser(String uid) async {
    final snapshot = await _databaseService!.list(location: _basePath);
    if (snapshot == null || !snapshot.exists || snapshot.value == null) return [];
    final map = snapshot.value as Map<dynamic, dynamic>;
    return map.values
        .map((v) => MatchFeedback.fromJson(Map<String, dynamic>.from(v as Map)))
        .where((f) => f.toUid == uid)
        .toList();
  }

  Future<double> averageRatingForUser(String uid) async {
    final items = await listForUser(uid);
    if (items.isEmpty) return 0;
    final total = items.fold<int>(0, (sum, item) => sum + item.rating);
    return total / items.length;
  }
}
