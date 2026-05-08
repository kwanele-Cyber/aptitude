import 'package:equatable/equatable.dart';

enum TrustFactorImpact { positive, negative }

class TrustFactorEntity extends Equatable {
  final String name;
  final TrustFactorImpact impact;
  final String description;
  final double weight;

  const TrustFactorEntity({
    required this.name,
    required this.impact,
    required this.description,
    required this.weight,
  });

  @override
  List<Object?> get props => [name, impact, description, weight];
}

class TrustEntity extends Equatable {
  final String id;
  final String userId;
  final int score;
  final List<TrustFactorEntity> factors;
  final DateTime lastCalculated;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TrustEntity({
    required this.id,
    required this.userId,
    required this.score,
    required this.factors,
    required this.lastCalculated,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props =>
      [id, userId, score, factors, lastCalculated, createdAt, updatedAt];
}

enum AppealStatus { pending, reviewed, resolved, rejected }

class TrustAppealEntity extends Equatable {
  final String id;
  final String userId;
  final String reason;
  final String? adminNotes;
  final AppealStatus status;
  final DateTime createdAt;
  final DateTime? reviewedAt;

  const TrustAppealEntity({
    required this.id,
    required this.userId,
    required this.reason,
    this.adminNotes,
    this.status = AppealStatus.pending,
    required this.createdAt,
    this.reviewedAt,
  });

  @override
  List<Object?> get props =>
      [id, userId, reason, adminNotes, status, createdAt, reviewedAt];
}
