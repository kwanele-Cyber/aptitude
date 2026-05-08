import 'package:myapp/features/ai/domain/entities/behavior_flag_entity.dart';

class BehaviorFlagModel extends BehaviorFlagEntity {
  const BehaviorFlagModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.severity,
    required super.description,
    required super.timestamp,
    super.metadata,
  });

  factory BehaviorFlagModel.fromJson(Map<String, dynamic> json) {
    return BehaviorFlagModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: FlagType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => FlagType.policyViolation,
      ),
      severity: FlagSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => FlagSeverity.low,
      ),
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? const {},
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'type': type.name,
        'severity': severity.name,
        'description': description,
        'timestamp': timestamp.toIso8601String(),
        'metadata': metadata,
      };
}
