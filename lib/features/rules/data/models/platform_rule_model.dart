import 'package:myapp/features/rules/domain/entities/platform_rule_entity.dart';

class PlatformRuleModel extends PlatformRuleEntity {
  const PlatformRuleModel({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required super.order,
  });

  factory PlatformRuleModel.fromJson(String id, Map<String, dynamic> json) {
    return PlatformRuleModel(
      id: id,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      order: json['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'order': order,
    };
  }
}
