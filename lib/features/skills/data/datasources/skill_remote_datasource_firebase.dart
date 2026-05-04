import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/features/skills/data/datasources/skill_remote_datasource.dart';
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
}
