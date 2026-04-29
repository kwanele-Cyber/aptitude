import 'package:uuid/uuid.dart';
import 'package:myapp/core/data/models/skill_enums.dart';

class SkillRequest {
  final String id;
  final String uid; // User who wants to learn
  final String sid; // Skill ID from global list
  final String skillName;
  final SkillLevel targetLevel;
  final SkillFormat preferredFormat;
  final String description;
  final bool isArchived;
  final DateTime createdAt;

  SkillRequest({
    String? id,
    required this.uid,
    required this.sid,
    required this.skillName,
    required this.targetLevel,
    required this.preferredFormat,
    required this.description,
    this.isArchived = false,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'sid': sid,
      'skillName': skillName,
      'targetLevel': targetLevel.name,
      'preferredFormat': preferredFormat.name,
      'description': description,
      'isArchived': isArchived,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SkillRequest.fromJson(Map<String, dynamic> json) {
    return SkillRequest(
      id: json['id'] as String,
      uid: json['uid'] as String,
      sid: json['sid'] as String,
      skillName: json['skillName'] as String? ?? '',
      targetLevel: SkillLevel.values.firstWhere(
        (e) => e.name == json['targetLevel'],
        orElse: () => SkillLevel.beginner,
      ),
      preferredFormat: SkillFormat.values.firstWhere(
        (e) => e.name == json['preferredFormat'],
        orElse: () => SkillFormat.online,
      ),
      description: json['description'] as String? ?? '',
      isArchived: json['isArchived'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  SkillRequest copyWith({
    String? id,
    String? skillName,
    SkillLevel? targetLevel,
    SkillFormat? preferredFormat,
    String? description,
    bool? isArchived,
  }) {
    return SkillRequest(
      id: id ?? this.id,
      uid: uid,
      sid: sid,
      skillName: skillName ?? this.skillName,
      targetLevel: targetLevel ?? this.targetLevel,
      preferredFormat: preferredFormat ?? this.preferredFormat,
      description: description ?? this.description,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt,
    );
  }
}
