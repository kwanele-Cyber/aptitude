import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/core/services/firebase_service.dart';
import 'package:myapp/core/services/interfaces/database_inteface.dart';
import '../models/saved_search.dart';

class SearchRepository {
  final String _basePath = "saved_searches";
  late final DatabaseService<DataSnapshot> _databaseService;

  SearchRepository({DatabaseService<DataSnapshot>? databaseService}) {
    _databaseService = databaseService ?? FirebaseService();
  }

  Future<void> saveSearch(String uid, SavedSearch search) async {
    await _databaseService.create(
      location: "$_basePath/$uid/${search.id}",
      data: search.toJson(),
    );
  }

  Future<List<SavedSearch>> getSavedSearches(String uid) async {
    final snapshot = await _databaseService.list(location: "$_basePath/$uid");
    if (snapshot != null && snapshot.exists && snapshot.value != null) {
      final Map<dynamic, dynamic> map = snapshot.value as Map;
      return map.values
          .map((s) => SavedSearch.fromJson(Map<String, dynamic>.from(s as Map)))
          .toList();
    }
    return [];
  }

  Future<void> deleteSearch(String uid, String searchId) async {
    await _databaseService.delete(location: "$_basePath/$uid/$searchId");
  }
}
