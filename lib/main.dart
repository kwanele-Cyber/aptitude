import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/notification_history_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aptitude',
      theme: ThemeData(primarySwatch: Colors.deepPurple, useMaterial3: true),
      home: const NotificationHistoryScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
