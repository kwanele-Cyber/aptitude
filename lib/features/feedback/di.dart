import 'package:get_it/get_it.dart';
import 'package:myapp/features/feedback/data/datasources/feedback_remote_datasource.dart';
import 'package:myapp/features/feedback/data/datasources/feedback_remote_datasource_firebase.dart';
import 'package:myapp/features/feedback/data/repository/feedback_repository_impl.dart';
import 'package:myapp/features/feedback/domain/repository/feedback_repository.dart';
import 'package:myapp/features/feedback/domain/usecases/edit_review_usecase.dart';
import 'package:myapp/features/feedback/domain/usecases/get_session_feedback_usecase.dart';
import 'package:myapp/features/feedback/domain/usecases/respond_to_review_usecase.dart';
import 'package:myapp/features/feedback/domain/usecases/submit_rating_usecase.dart';
import 'package:myapp/features/feedback/domain/usecases/view_reviews_usecase.dart';
import 'package:myapp/features/feedback/domain/usecases/write_review_usecase.dart';
import 'package:myapp/features/feedback/presentation/bloc/feedback_bloc.dart';

class FeedbackDI {
  final GetIt sl;
  FeedbackDI(this.sl);

  GetIt Init() {
    sl.registerFactory(
      () => FeedbackBloc(
        submitRatingUseCase: sl(),
        writeReviewUseCase: sl(),
        viewReviewsUseCase: sl(),
        editReviewUseCase: sl(),
        respondToReviewUseCase: sl(),
      ),
    );

    sl.registerLazySingleton(() => SubmitRatingUseCase(repository: sl()));
    sl.registerLazySingleton(() => WriteReviewUseCase(repository: sl()));
    sl.registerLazySingleton(() => ViewReviewsUseCase(repository: sl()));
    sl.registerLazySingleton(() => EditReviewUseCase(repository: sl()));
    sl.registerLazySingleton(() => RespondToReviewUseCase(repository: sl()));
    sl.registerLazySingleton(
        () => GetSessionFeedbackUseCase(repository: sl()));

    sl.registerLazySingleton<FeedbackRepository>(
      () => FeedbackRepositoryImpl(remoteDataSource: sl()),
    );
    sl.registerLazySingleton<FeedbackRemoteDataSource>(
      () => FeedbackRemoteDataSourceFirebase(),
    );
    return sl;
  }
}
