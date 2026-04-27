import 'package:uuid/uuid.dart';

class Skill {
  String sid;
  final String name;
  final String description;
  final String category;

  Skill({
    String? sid,
    required this.name,
    required this.description,
    required this.category,
  }) : sid = sid ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'sid': sid,
      'name': name,
      'description': description,
      'category': category,
    };
  }

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      sid: json['sid'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
    );
  }
}
