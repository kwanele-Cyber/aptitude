import 'package:uuid/uuid.dart';
import 'package:myapp/core/data/models/skill_enums.dart';
import 'package:myapp/core/data/models/skill_proof.dart';

class SkillOffer {
  final String id;
  final String uid; // User who offers
  final String sid; // Skill ID from global list
  final String skillName; // Denormalized for display
  final SkillLevel level;
  final SkillFormat format;
  final String description;
  final List<SkillProof> proofs; // Structured LinkedIn-style proof
  final int yearsOfExperience;
  final bool isVerified;
  final bool isArchived;
  final DateTime createdAt;

  SkillOffer({
    String? id,
    required this.uid,
    required this.sid,
    required this.skillName,
    required this.level,
    required this.format,
    required this.description,
    this.proofs = const [],
    this.yearsOfExperience = 0,
    this.isVerified = false,
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
      'level': level.name,
      'format': format.name,
      'description': description,
      'proofs': proofs.map((p) => p.toJson()).toList(),
      'yearsOfExperience': yearsOfExperience,
      'isVerified': isVerified,
      'isArchived': isArchived,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SkillOffer.fromJson(Map<String, dynamic> json) {
    return SkillOffer(
      id: json['id'] as String,
      uid: json['uid'] as String,
      sid: json['sid'] as String,
      skillName: json['skillName'] as String? ?? '',
      level: SkillLevel.values.firstWhere(
        (e) => e.name == json['level'],
        orElse: () => SkillLevel.beginner,
      ),
      format: SkillFormat.values.firstWhere(
        (e) => e.name == json['format'],
        orElse: () => SkillFormat.online,
      ),
      description: json['description'] as String? ?? '',
      proofs: (json['proofs'] as List? ?? [])
          .map((p) => SkillProof.fromJson(Map<String, dynamic>.from(p as Map)))
          .toList(),
      yearsOfExperience: json['yearsOfExperience'] as int? ?? 0,
      isVerified: json['isVerified'] as bool? ?? false,
      isArchived: json['isArchived'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  SkillOffer copyWith({
    String? id,
    String? skillName,
    SkillLevel? level,
    SkillFormat? format,
    String? description,
    List<SkillProof>? proofs,
    int? yearsOfExperience,
    bool? isVerified,
    bool? isArchived,
  }) {
    return SkillOffer(
      id: id ?? this.id,
      uid: uid,
      sid: sid,
      skillName: skillName ?? this.skillName,
      level: level ?? this.level,
      format: format ?? this.format,
      description: description ?? this.description,
      proofs: proofs ?? this.proofs,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      isVerified: isVerified ?? this.isVerified,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt,
    );
  }
}
