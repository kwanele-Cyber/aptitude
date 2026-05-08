import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/ai/domain/entities/session_prediction_entity.dart';
import 'package:myapp/features/ai/domain/repository/ai_repository.dart';

class PredictSessionQualityUseCase {
  final AiRepository repository;

  PredictSessionQualityUseCase({required this.repository});

  Future<Either<Failure, SessionPredictionEntity>> call(
      PredictSessionQualityParams params) async {
    return repository.predictSessionQuality(params.matchId);
  }
}

class PredictSessionQualityParams extends Equatable {
  final String matchId;

  const PredictSessionQualityParams({required this.matchId});

  @override
  List<Object?> get props => [matchId];
}
