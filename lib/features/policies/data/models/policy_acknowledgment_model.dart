import 'package:myapp/features/policies/domain/entities/policy_acknowledgment_entity.dart';

class PolicyAcknowledgmentModel extends PolicyAcknowledgmentEntity {
  const PolicyAcknowledgmentModel({
    required super.policyId,
    required super.acknowledgedAt,
    required super.version,
  });

  factory PolicyAcknowledgmentModel.fromJson(
      String policyId, Map<String, dynamic> json) {
    return PolicyAcknowledgmentModel(
      policyId: policyId,
      acknowledgedAt: json['acknowledgedAt'] != null
          ? DateTime.parse(json['acknowledgedAt'] as String)
          : DateTime.now(),
      version: json['version'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'acknowledgedAt': acknowledgedAt.toIso8601String(),
      'version': version,
    };
  }
}
