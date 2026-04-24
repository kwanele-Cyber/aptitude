import 'package:myapp/core/models/skill_model.dart';
import 'package:myapp/core/services/base_database_service.dart';
import 'package:myapp/core/repositories/skill_repository.dart';
import 'package:firebase_database/firebase_database.dart';

class SkillRepositoryImpl extends BaseDatabaseService implements SkillRepository {
  SkillRepositoryImpl({FirebaseDatabase? database}) : super(database: database);
  @override
  Future<void> createSkill({
    required SkillModel skill,
    required String userId,
    required bool isOffer,
  }) async {
    final skillId = skill.id.isEmpty ? generateId('skills') : skill.id;
    final skillData = skill.copyWith(id: skillId).toJson();
    skillData['ownerId'] = userId;
    skillData['type'] = isOffer ? 'offer' : 'request';
    skillData['createdAt'] = ServerValue.timestamp;

    // 1. Save to skills node
    await setData(path: 'skills/$skillId', data: skillData);

    // 2. Update user node (using a map of skill IDs to data to mimic list but safer in RTDB)
    final field = isOffer ? 'offeredSkills' : 'desiredSkills';
    await updateData(
      path: 'users/$userId/$field/$skillId',
      data: skillData,
    );
  }

  @override
  Future<void> updateSkill({
    required SkillModel skill,
    required String userId,
  }) async {
    final skillData = skill.toJson();
    skillData['ownerId'] = userId;
    skillData['updatedAt'] = ServerValue.timestamp;

    // 1. Update in skills node
    await updateData(path: 'skills/${skill.id}', data: skillData);

    // 2. Update in user node
    // First find if it's an offer or request
    final skillSnapshot = await getData('skills/${skill.id}');
    final type = (skillSnapshot.value as Map?)?['type'] ?? 'offer';
    final field = type == 'offer' ? 'offeredSkills' : 'desiredSkills';
    
    await updateData(
      path: 'users/$userId/$field/${skill.id}',
      data: skillData,
    );
  }

  @override
  Future<void> deleteSkill({
    required String skillId,
    required String userId,
  }) async {
    // 1. Delete from skills node
    await deleteData('skills/$skillId');

    // 2. Remove from user node (check both)
    await deleteData('users/$userId/offeredSkills/$skillId');
    await deleteData('users/$userId/desiredSkills/$skillId');
  }

  @override
  Future<List<SkillModel>> searchSkills(String query) async {
    final snapshot = await getRef('skills').get();
    
    if (!snapshot.exists) return [];

    final Map<dynamic, dynamic> skillsMap = snapshot.value as Map<dynamic, dynamic>;
    final List<SkillModel> results = [];

    skillsMap.forEach((key, value) {
      final data = Map<String, dynamic>.from(value as Map);
      if (data['id'] == null) data['id'] = key;
      results.add(SkillModel.fromJson(data));
    });

    if (query.isEmpty) return results;

    final lowercaseQuery = query.toLowerCase();
    return results.where((skill) => 
      skill.name.toLowerCase().contains(lowercaseQuery) || 
      skill.description.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  @override
  Future<List<SkillModel>> getRecentSkills({int limit = 20}) async {
    final snapshot = await getRef('skills')
        .orderByChild('createdAt')
        .limitToLast(limit)
        .get();

    if (!snapshot.exists) return [];

    final Map<dynamic, dynamic> skillsMap = snapshot.value as Map<dynamic, dynamic>;
    final List<SkillModel> results = [];

    skillsMap.forEach((key, value) {
      final data = Map<String, dynamic>.from(value as Map);
      if (data['id'] == null) data['id'] = key;
      results.add(SkillModel.fromJson(data));
    });

    // RTDB returns in ascending order by default, need to reverse if we want descending
    return results.reversed.toList();
  }

  @override
  Future<List<SkillModel>> getSkillsByUser(String userId) async {
    final snapshot = await getRef('skills')
        .orderByChild('ownerId')
        .equalTo(userId)
        .get();

    if (!snapshot.exists) return [];

    final Map<dynamic, dynamic> skillsMap = snapshot.value as Map<dynamic, dynamic>;
    return skillsMap.values.map((value) {
      final data = Map<String, dynamic>.from(value as Map);
      return SkillModel.fromJson(data);
    }).toList();
  }
}

