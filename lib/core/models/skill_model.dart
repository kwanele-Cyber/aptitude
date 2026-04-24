class SkillModel {
  final String id;
  final String name;
  final String description;
  final String level; // e.g., 'Beginner', 'Intermediate', 'Expert'
  final String? ownerId; // The UID of the user who owns this skill
  final String? type; // 'offer' or 'request'

  SkillModel({
    required this.id,
    required this.name,
    required this.description,
    required this.level,
    this.ownerId,
    this.type,
  });

  SkillModel copyWith({
    String? id,
    String? name,
    String? description,
    String? level,
    String? ownerId,
    String? type,
  }) {
    return SkillModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      level: level ?? this.level,
      ownerId: ownerId ?? this.ownerId,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'level': level,
      if (ownerId != null) 'ownerId': ownerId,
      if (type != null) 'type': type,
    };
  }

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      level: json['level'] as String,
      ownerId: json['ownerId'] as String?,
      type: json['type'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkillModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          level == other.level &&
          ownerId == other.ownerId &&
          type == other.type;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ description.hashCode ^ level.hashCode ^ ownerId.hashCode ^ type.hashCode;
}
