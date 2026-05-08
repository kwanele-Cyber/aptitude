import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/feedback/domain/entities/feedback_entity.dart';
import 'package:myapp/features/feedback/domain/repository/feedback_repository.dart';

class GetSessionFeedbackUseCase {
  final FeedbackRepository repository;

  GetSessionFeedbackUseCase({required this.repository});

  Future<Either<Failure, List<FeedbackEntity>>> call(
      GetSessionFeedbackParams params) async {
    return repository.getSessionFeedback(params.sessionId);
  }
}

class GetSessionFeedbackParams extends Equatable {
  final String sessionId;

  const GetSessionFeedbackParams({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}
