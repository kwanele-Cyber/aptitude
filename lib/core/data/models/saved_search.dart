import 'package:myapp/core/data/models/skill_enums.dart';

class SavedSearch {
  final String id;
  final String name;
  final String? query;
  final Set<SkillLevel> levels;
  final Set<SkillFormat> formats;
  final DateTime createdAt;

  SavedSearch({
    required this.id,
    required this.name,
    this.query,
    this.levels = const {},
    this.formats = const {},
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'query': query,
      'levels': levels.map((e) => e.name).toList(),
      'formats': formats.map((e) => e.name).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SavedSearch.fromJson(Map<String, dynamic> json) {
    return SavedSearch(
      id: json['id'] as String,
      name: json['name'] as String,
      query: json['query'] as String?,
      levels: (json['levels'] as List? ?? [])
          .map((e) => SkillLevel.values.firstWhere((l) => l.name == e))
          .toSet(),
      formats: (json['formats'] as List? ?? [])
          .map((e) => SkillFormat.values.firstWhere((f) => f.name == e))
          .toSet(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
