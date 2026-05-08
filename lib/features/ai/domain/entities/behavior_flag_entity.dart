import 'package:equatable/equatable.dart';

enum FlagSeverity { low, medium, high, critical }

enum FlagType {
  unusualLoginLocation,
  rapidMessageSpam,
  suspiciousMatchPattern,
  fakeReviewActivity,
  accountTakeoverAttempt,
  policyViolation,
}

class BehaviorFlagEntity extends Equatable {
  final String id;
  final String userId;
  final FlagType type;
  final FlagSeverity severity;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const BehaviorFlagEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.severity,
    required this.description,
    required this.timestamp,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        severity,
        description,
        timestamp,
        metadata,
      ];
}
