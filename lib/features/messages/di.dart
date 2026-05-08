import 'package:get_it/get_it.dart';
import 'package:myapp/features/messages/data/datasources/message_remote_datasource.dart';
import 'package:myapp/features/messages/data/datasources/message_remote_datasource_firebase.dart';
import 'package:myapp/features/messages/data/repository/message_repository_impl.dart';
import 'package:myapp/features/messages/domain/repository/message_repository.dart';
import 'package:myapp/features/messages/domain/usecases/create_room_usecase.dart';
import 'package:myapp/features/messages/domain/usecases/get_messages_usecase.dart';
import 'package:myapp/features/messages/domain/usecases/get_room_messages_usecase.dart';
import 'package:myapp/features/messages/domain/usecases/mark_messages_as_read_usecase.dart';
import 'package:myapp/features/messages/domain/usecases/send_message_usecase.dart';
import 'package:myapp/features/messages/domain/usecases/send_room_message_usecase.dart';
import 'package:myapp/features/messages/domain/usecases/watch_inbox_usecase.dart';
import 'package:myapp/features/messages/domain/usecases/watch_typing_indicator_usecase.dart';
import 'package:myapp/features/messages/presentation/bloc/message_bloc.dart';

class MessagesDI{
  final GetIt sl;
  MessagesDI(this.sl);

  GetIt Init(){
    
  // Messages
  sl.registerFactory(() => MessageBloc(
        sendMessageUseCase: sl(),
        getMessagesUseCase: sl(),
        markMessagesAsReadUseCase: sl(),
      ));

  sl.registerLazySingleton(() => SendMessageUseCase(sl()));
  //editmessageusecase
  sl.registerLazySingleton(() => GetMessagesUseCase(sl()));
  sl.registerLazySingleton(() => MarkMessagesAsReadUseCase(sl()));
  sl.registerLazySingleton(() => WatchInboxUseCase(sl()));
  sl.registerLazySingleton(() => WatchTypingIndicatorUsecase(sl()));
  sl.registerLazySingleton(() => CreateRoomUseCase(sl()));
  sl.registerLazySingleton(() => GetRoomMessagesUseCase(sl()));
  sl.registerLazySingleton(() => SendRoomMessageUseCase(sl()));

  sl.registerLazySingleton<MessageRepository>(
    () => MessageRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<MessageRemoteDataSource>(
    () => MessageRemoteDataSourceFirebase(),
  );
    return sl;
  }
}