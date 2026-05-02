import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/core/data/models/rating.dart';
import 'package:myapp/core/services/firebase_service.dart';
import 'package:myapp/core/services/interfaces/database_inteface.dart';

class RatingRepository {
  final String _path = "ratings";
  late final DatabaseService<DataSnapshot> _databaseService;

  RatingRepository({DatabaseService<DataSnapshot>? databaseService}) {
    _databaseService = databaseService ?? FirebaseService();
  }

  Future<void> submitRating(Rating rating) async {
    await _databaseService.create(
      location: "$_path/${rating.toUid}/${rating.id}",
      data: rating.toJson(),
    );
  }

  Future<List<Rating>> getUserRatings(String uid) async {
    final snapshot = await _databaseService.list(location: "$_path/$uid");
    if (snapshot != null && snapshot.exists && snapshot.value != null) {
      final Map<dynamic, dynamic> map = snapshot.value as Map;
      return map.values
          .map((v) => Rating.fromJson(Map<String, dynamic>.from(v as Map)))
          .toList();
    }
    return [];
  }
}
