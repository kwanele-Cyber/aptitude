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
      sid: json['sid'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
    );
  }
}
