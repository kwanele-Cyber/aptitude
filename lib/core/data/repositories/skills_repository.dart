import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/core/data/models/skill.dart';
import 'package:myapp/core/services/firebase_service.dart';
import 'package:myapp/core/services/interfaces/database_inteface.dart';
import 'package:myapp/core/services/ai_service.dart';

class SkillsRepository {
  final String _basePath = "skills";
  late final DatabaseService<DataSnapshot> _databaseService;
  final _aiService = AIService();

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

  //adds a skill to db and returns the created resource
  Future<Skill?> addSkill(Skill val) async {
    Skill? skill;
    await _databaseService
        .create(location: "$_basePath/${val.sid}", data: val.toJson())
        .whenComplete(() async {
          skill = await getSkill(val.sid);
        });

    return skill;
  }

  /// Resolves a skill name to an ID (slug-based).
  Future<String> resolveSkillId(
    String name, [
    String? description,
    String? category,
  ]) async {
    final sanitizedName = _sanitizeDisplayName(name);
    final slug = _generateSlug(sanitizedName);
    
    if (slug.isEmpty) throw Exception('Invalid skill name: $name');
    if (slug.length > 50) throw Exception('Skill name too long');

    // 1. Instant lookup via slug key (O(1) vs O(N))
    final existing = await getSkill(slug);
    if (existing != null) {
      return existing.sid;
    }

    // 2. Suggest category if not provided
    final resolvedCategory = category ?? await _aiService.suggestCategory(sanitizedName);

    // 3. Create new skill using slug as ID
    final newSkill = Skill(
      sid: slug,
      name: sanitizedName,
      description: description ?? '',
      category: resolvedCategory,
    );

    await _databaseService.create(
      location: '$_basePath/$slug',
      data: newSkill.toJson(),
    );

    return slug;
  }

  String _sanitizeDisplayName(String name) {
    // Limit to 50 characters and remove non-printable/weird chars
    String sanitized = name.trim();
    if (sanitized.length > 50) {
      sanitized = sanitized.substring(0, 50);
    }
    // Remove characters that might break UI or DB (keep alphanumeric, space, basic punctuation)
    return sanitized.replaceAll(RegExp(r'[^\w\s\.\-\(\)]'), '');
  }

  String _generateSlug(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '') // Remove special chars
        .replaceAll(RegExp(r'\s+'), '-') // Replace spaces with hyphens
        .replaceAll(RegExp(r'-+'), '-') // Collapse all hyphens to single (VERY IMPORTANT: reserves -- for composite IDs)
        .replaceAll(RegExp(r'^-+|-+$'), ''); // Remove leading/trailing hyphens
  }

  Future<Skill?> getSkill(String id) async {
    var data = await _databaseService.read(location: "$_basePath/$id");
    if (data != null && data.exists && data.value != null) {
      return Skill.fromJson(Map<String, dynamic>.from(data.value as Map));
    }
    return null;
  }

  Future<List<Skill>?> resolveSkillsByIds(List<String> ids) async {
    if (ids.isEmpty) return null;
    final all = await listAll();
    final skills = all.where((s) => ids.contains(s.sid)).toList();
    return skills.isEmpty ? null : skills;
  }

  Future<List<String>> resolveSkillIds(List<String> names) async {
    final List<String> ids = [];
    for (final name in names) {
      final id = await resolveSkillId(name);
      ids.add(id);
    }
    return ids.toSet().toList();
  }

  /// Search skills by keyword
  Future<List<Skill>> searchSkills(String query) async {
    if (query.isEmpty) return [];
    final all = await listAll();
    final q = query.toLowerCase();
    return all.where((s) => s.name.toLowerCase().contains(q)).toList();
  }
}
