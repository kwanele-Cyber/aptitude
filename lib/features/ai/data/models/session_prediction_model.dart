import 'package:myapp/features/ai/domain/entities/session_prediction_entity.dart';

class SessionPredictionModel extends SessionPredictionEntity {
  const SessionPredictionModel({
    required super.matchId,
    required super.predictedQuality,
    required super.confidence,
    required super.keyFactors,
  });

  factory SessionPredictionModel.fromJson(Map<String, dynamic> json) {
    return SessionPredictionModel(
      matchId: json['matchId'] as String,
      predictedQuality: (json['predictedQuality'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
      keyFactors: List<String>.from(json['keyFactors'] as List),
    );
  }

  Map<String, dynamic> toJson() => {
        'matchId': matchId,
        'predictedQuality': predictedQuality,
        'confidence': confidence,
        'keyFactors': keyFactors,
      };
}
