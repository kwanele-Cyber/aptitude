import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/core/data/models/skill.dart';
import 'package:myapp/core/services/firebase_service.dart';
import 'package:myapp/core/services/interfaces/database_inteface.dart';
import 'package:uuid/uuid.dart';

class SkillsRepository {
  final String _basePath = "skills";
  late final DatabaseService<DataSnapshot> _databaseService;

  SkillsRepository({DatabaseService<DataSnapshot>? databaseService}) {
    _databaseService = databaseService ?? FirebaseService();
  }

  /// Gets all skills from the global list
  Future<List<Skill>> listAll() async {
    final snapshot = await _databaseService.list(location: _basePath);
    if (snapshot != null && snapshot.exists && snapshot.value != null) {
      final Map<dynamic, dynamic> map = snapshot.value as Map;
      return map.values
          .map((s) => Skill.fromJson(Map<String, dynamic>.from(s as Map)))
          .toList();
    }
    return [];
  }

  /// Resolves a skill name to an ID.
  /// If the skill exists, returns the ID.
  /// If not, creates a new skill and returns the new ID.
  Future<String> resolveSkillId(
    String name, [
    String? description,
    String? category,
  ]) async {
    final sanitizedName = name.trim().toLowerCase();
    final allSkills = await listAll();

    // Check if exists (case-insensitive)
    final existing = allSkills.where(
      (s) => s.name.toLowerCase() == sanitizedName,
    );
    if (existing.isNotEmpty) {
      return existing.first.sid;
    }

    // Create new skill
    final id = const Uuid().v4();
    final newSkill = Skill(
      sid: id,
      name: name.trim(),
      description: description ?? '',
      category: category ?? '',
    );

    await _databaseService.create(
      location: '$_basePath/$id',
      data: newSkill.toJson(),
    );

    return id;
  }

  Future<Skill?> getSkill(String id) async {
    var data = await _databaseService.read(location: "$_basePath/$id");
    if (data != null) {
      return Skill.fromJson(data.value as Map<String, dynamic>);
    }
    return null;
  }

  Future<List<Skill>?> resolveSkillsByIds(List<String> ids) async {
    List<Skill>? skills = List.empty(growable: true);
    for (final id in ids) {
      final skill = await getSkill(id);

      if (skill != null) {
        skills.add(skill);
      }
    }

    if (skills.isNotEmpty) {
      return skills;
    }

    return null;
  }

  /// Batch resolves a list of names to IDs
  Future<List<String>> resolveSkillIds(List<String> names) async {
    final List<String> ids = [];
    for (final name in names) {
      final id = await resolveSkillId(name);
      ids.add(id);
    }
    return ids;
  }
}
