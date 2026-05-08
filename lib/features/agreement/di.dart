class AgreementDI {
  final GetIt sl;
  AgreementDI(this.sl);

 

  // Add to existing init() function or create new registration
  GetIt Init() {
    // Data Sources
    sl.registerLazySingleton<AgreementRemoteDataSource>(
      () => AgreementRemoteDataSourceFirebase(),
    );

    // Repositories
    sl.registerLazySingleton<AgreementRepository>(
      () => AgreementRepositoryImpl(remoteDataSource: sl()),
    );

    // Use Cases
    sl.registerLazySingleton(() => CreateAgreementUseCase(sl()));
    sl.registerLazySingleton(() => GetAgreementUseCase(sl()));
    sl.registerLazySingleton(() => GetUserAgreementsUseCase(sl()));
    sl.registerLazySingleton(() => AcceptAgreementUseCase(sl()));
    sl.registerLazySingleton(() => DeclineAgreementUseCase(sl()));
    sl.registerLazySingleton(() => ProposeModificationsUseCase(sl()));
    sl.registerLazySingleton(() => AcceptModificationsUseCase(sl()));
    sl.registerLazySingleton(() => DeclineModificationsUseCase(sl()));
    sl.registerLazySingleton(() => CancelAgreementUseCase(sl()));
    sl.registerLazySingleton(() => CompleteAgreementUseCase(sl()));
    sl.registerLazySingleton(() => WatchAgreementUseCase(sl()));
    sl.registerLazySingleton(() => WatchUserAgreementsUseCase(sl()));

    // BLoC
    sl.registerFactory(
      () => AgreementBloc(
        createAgreement: sl(),
        getAgreement: sl(),
        getUserAgreements: sl(),
        acceptAgreement: sl(),
        declineAgreement: sl(),
        proposeModifications: sl(),
        acceptModifications: sl(),
        declineModifications: sl(),
        cancelAgreement: sl(),
        completeAgreement: sl(),
        watchAgreement: sl(),
        watchUserAgreements: sl(),
      ),
    );
      return sl;
  }

}
