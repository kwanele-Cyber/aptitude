import 'package:myapp/features/policies/domain/entities/policy_entity.dart';

class PolicyModel extends PolicyEntity {
  const PolicyModel({
    required super.id,
    required super.title,
    required super.content,
    required super.version,
    required super.publishedAt,
    required super.requiresAcknowledgement,
  });

  factory PolicyModel.fromJson(String key, Map<String, dynamic> json) {
    final id = json['id'] as String? ?? json['uid'] as String? ?? key;
    return PolicyModel(
      id: id,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      version: json['version'] as String? ?? '1.0',
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'] as String)
          : DateTime.now(),
      requiresAcknowledgement:
          json['requiresAcknowledgement'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'version': version,
      'publishedAt': publishedAt.toIso8601String(),
      'requiresAcknowledgement': requiresAcknowledgement,
    };
  }
}
