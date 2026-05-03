import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myapp/core/bloc/auth_bloc.dart';
import 'package:myapp/core/di/injection.dart';
import 'package:myapp/core/providers/notification_provider.dart';
import 'package:myapp/core/routing/router.dart';
import 'package:myapp/core/services/push_notification_service.dart';
import 'package:myapp/firebase_options.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Persist auth state across sessions — uses IndexedDB/localStorage on web,
  // local device storage on iOS/Android.
  await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);

  await initDependencies();
  await PushNotificationService().initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotificationProvider()..init()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: MaterialApp.router(
        routerConfig: router,
        title: 'Flutter MVVM',
      ),
    );
  }
}
