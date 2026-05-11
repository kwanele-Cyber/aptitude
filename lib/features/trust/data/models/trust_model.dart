import 'package:myapp/features/trust/domain/entity/trust_entity.dart';

class TrustAppealModel extends TrustAppealEntity {
  const TrustAppealModel({
    required super.id,
    required super.userId,
    required super.reason,
    super.adminNotes,
    super.status,
    required super.createdAt,
    super.reviewedAt,
  });

  factory TrustAppealModel.fromJson(String key, Map<String, dynamic> json) {
    final id = json['id'] as String? ?? json['uid'] as String? ?? key;
    return TrustAppealModel(
      id: id,
      userId: json['userId'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      adminNotes: json['adminNotes'] as String?,
      status: _parseStatus(json['status'] as String?),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.tryParse(json['reviewedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'reason': reason,
      'adminNotes': adminNotes,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
    };
  }

  static AppealStatus _parseStatus(String? status) {
    return AppealStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => AppealStatus.pending,
    );
  }
}

class TrustFactorModel extends TrustFactorEntity {
  const TrustFactorModel({
    required super.name,
    required super.impact,
    required super.description,
    required super.weight,
  });

  factory TrustFactorModel.fromJson(Map<String, dynamic> json) {
    return TrustFactorModel(
      name: json['name'] as String? ?? '',
      impact: (json['impact'] as String?) == 'positive'
          ? TrustFactorImpact.positive
          : TrustFactorImpact.negative,
      description: json['description'] as String? ?? '',
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'impact': impact.name,
      'description': description,
      'weight': weight,
    };
  }
}

class TrustModel extends TrustEntity {
  const TrustModel({
    required super.id,
    required super.userId,
    required super.score,
    required super.factors,
    required super.lastCalculated,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TrustModel.fromJson(String key, Map<String, dynamic> json) {
    final id = json['id'] as String? ?? json['uid'] as String? ?? key;
    final factorsList =
        (json['factors'] as List<dynamic>?)
            ?.map(
              (e) => TrustFactorModel.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList() ??
        [];

    return TrustModel(
      id: id,
      userId: json['userId'] as String? ?? '',
      score: json['score'] as int? ?? 0,
      factors: factorsList,
      lastCalculated:
          DateTime.tryParse(json['lastCalculated'] as String? ?? '') ??
          DateTime.now(),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'score': score,
      'factors': factors.map((f) => (f as TrustFactorModel).toJson()).toList(),
      'lastCalculated': lastCalculated.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
