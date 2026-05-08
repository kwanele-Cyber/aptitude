import 'package:equatable/equatable.dart';

class SessionPredictionEntity extends Equatable {
  final String matchId;
  final double predictedQuality;
  final double confidence;
  final List<String> keyFactors;

  const SessionPredictionEntity({
    required this.matchId,
    required this.predictedQuality,
    required this.confidence,
    required this.keyFactors,
  });

  @override
  List<Object?> get props => [
        matchId,
        predictedQuality,
        confidence,
        keyFactors,
      ];
}
