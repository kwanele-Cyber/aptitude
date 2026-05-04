import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/features/skills/data/datasources/skill_remote_datasource.dart';
import 'package:myapp/features/skills/data/models/saved_search_model.dart';
import 'package:myapp/features/skills/data/models/skill_model.dart';

class SkillRemoteDataSourceFirebase implements SkillRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseDatabase _database;

  SkillRemoteDataSourceFirebase({FirebaseAuth? auth, FirebaseDatabase? database})
      : _auth = auth ?? FirebaseAuth.instance,
        _database = database ?? FirebaseDatabase.instance;

  DatabaseReference get _skillsRef => _database.ref('skills');

  @override
  Future<SkillModel> createSkill(Map<String, dynamic> data) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw ServerException();

      final skillRef = _skillsRef.push();
      final now = DateTime.now().toIso8601String();

      final skillData = {
        ...data,
        'userId': uid,
        'createdAt': now,
        'updatedAt': now,
      };

      await skillRef.set(skillData);
      final snapshot = await skillRef.get();
      if (!snapshot.exists) throw ServerException();

      return SkillModel.fromJson(
        skillRef.key ?? '',
        snapshot.value as Map<String, dynamic>,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<SkillModel> updateSkill(String id, Map<String, dynamic> data) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw ServerException();

      final skillRef = _skillsRef.child(id);
      final updateData = {
        ...data,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await skillRef.update(updateData);
      final snapshot = await skillRef.get();
      if (!snapshot.exists) throw ServerException();

      return SkillModel.fromJson(
        skillRef.key ?? '',
        snapshot.value as Map<String, dynamic>,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<void> deleteSkill(String id) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw ServerException();

      await _skillsRef.child(id).remove();
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<SkillModel> getSkillById(String id) async {
    try {
      final snapshot = await _skillsRef.child(id).get();
      if (!snapshot.exists) throw ServerException();

      return SkillModel.fromJson(
        snapshot.key ?? '',
        snapshot.value as Map<String, dynamic>,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<void> archiveSkill(String id) async {
    try {
      await _skillsRef.child(id).update({
        'archivedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<void> restoreSkill(String id) async {
    try {
      await _skillsRef.child(id).update({
        'archivedAt': null,
      });
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<List<SkillModel>> fetchUserSkills(String uid) async {
    try {
      final snapshot =
          await _skillsRef.orderByChild('userId').equalTo(uid).get();
      if (!snapshot.exists) return [];

      final skills = <SkillModel>[];
      final map = snapshot.value as Map<String, dynamic>?;
      if (map == null) return [];

      map.forEach((key, value) {
        skills.add(SkillModel.fromJson(
          key,
          value as Map<String, dynamic>,
        ));
      });
      return skills;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<List<SkillModel>> searchSkills(String query) async {
    try {
      final snapshot = await _skillsRef.get();
      if (!snapshot.exists) return [];

      final map = snapshot.value as Map<String, dynamic>?;
      if (map == null) return [];

      final lowerQuery = query.toLowerCase();
      final skills = <SkillModel>[];
      map.forEach((key, value) {
        final data = value as Map<String, dynamic>;
        final archivedAt = data['archivedAt'] as String?;
        if (archivedAt != null) return;

        final skill = SkillModel.fromJson(key, data);
        final matchesTitle = skill.title.toLowerCase().contains(lowerQuery);
        final matchesDescription =
            skill.description.toLowerCase().contains(lowerQuery);
        final matchesCategory =
            skill.category.toLowerCase().contains(lowerQuery);
        final matchesTags =
            skill.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));

        if (matchesTitle || matchesDescription || matchesCategory || matchesTags) {
          skills.add(skill);
        }
      });
      return skills;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<List<SkillModel>> fetchAllSkills() async {
    try {
      final snapshot = await _skillsRef.get();
      if (!snapshot.exists) return [];

      final map = snapshot.value as Map<String, dynamic>?;
      if (map == null) return [];

      final skills = <SkillModel>[];
      map.forEach((key, value) {
        final data = value as Map<String, dynamic>;
        final archivedAt = data['archivedAt'] as String?;
        if (archivedAt != null) return;

        skills.add(SkillModel.fromJson(key, data));
      });
      return skills;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  DatabaseReference get _savedSearchesRef => _database.ref('savedSearches');

  @override
  Future<void> saveSearch(Map<String, dynamic> data) async {
    try {
      final searchRef = _savedSearchesRef.push();
      await searchRef.set(data);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<List<SavedSearchModel>> fetchSavedSearches(String uid) async {
    try {
      final snapshot =
          await _savedSearchesRef.orderByChild('userId').equalTo(uid).get();
      if (!snapshot.exists) return [];

      final map = snapshot.value as Map<String, dynamic>?;
      if (map == null) return [];

      final searches = <SavedSearchModel>[];
      map.forEach((key, value) {
        searches.add(SavedSearchModel.fromJson(
            key, value as Map<String, dynamic>));
      });
      searches.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return searches;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<void> deleteSavedSearch(String id) async {
    try {
      await _savedSearchesRef.child(id).remove();
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException();
    }
  }
}
