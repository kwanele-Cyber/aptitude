import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/matchmaking/domain/repository/match_repository.dart';

class SubmitMatchFeedbackUseCase {
  final MatchRepository repository;

  SubmitMatchFeedbackUseCase({required this.repository});

  Future<Either<Failure, void>> call(SubmitMatchFeedbackParams params) async {
    return repository.submitFeedback(
      params.matchId,
      params.rating,
      params.comment,
    );
  }
}

class SubmitMatchFeedbackParams extends Equatable {
  final String matchId;
  final int rating;
  final String? comment;

  const SubmitMatchFeedbackParams({
    required this.matchId,
    required this.rating,
    this.comment,
  });

  @override
  List<Object?> get props => [matchId, rating, comment];
}
