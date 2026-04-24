import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myapp/firebase_options.dart';
import 'package:myapp/core/services/base_database_service.dart';
import 'package:myapp/core/repositories/auth_repository_impl.dart';

// A simple widget to keep the app alive while we run the debug logic
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('--- [DEBUG] Initializing Firebase ---');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('--- [DEBUG] Firebase Initialized ---');

  runApp(const MaterialApp(
    home: Scaffold(
      body: Center(child: Text('Check terminal for debug output...', style: TextStyle(fontSize: 18))),
    ),
  ));

  // Run the debug logic after a short delay to ensure app is ready
  Future.delayed(const Duration(seconds: 2), () async {
    await runAuthIntegrationDebug();
  });
}

Future<void> runAuthIntegrationDebug() async {
  print('\n=== STARTING AUTH INTEGRATION DEBUG ===');
  
  // 1. Initialize Repo with dev prefix
  final authRepo = AuthRepositoryImpl(pathPrefix: 'dev');
  final testEmail = 'debug_${DateTime.now().millisecondsSinceEpoch}@example.com';
  const testPassword = 'password123';

  try {
    print('1. Attempting Auth Registration for: $testEmail');
    final user = await authRepo.signUpWithEmail(
      email: testEmail, 
      password: testPassword, 
      displayName: 'Debug User'
    );
    print('✅ Auth User Created. UID: ${user.uid}');

    print('2. Verifying DB Entry at dev/users/${user.uid}');
    // This calls getData() internally
    final fetchedUser = await authRepo.getCurrentUser();
    
    if (fetchedUser != null) {
      print('✅ DB Verification Successful! User found in database.');
    } else {
      print('❌ DB Verification Failed: User created in Auth but not found in DB.');
    }

    print('3. Cleaning up dev data...');
    await authRepo.deleteData('users/${user.uid}');
    print('✅ Clean-up Successful.');

  } catch (e) {
    print('❌ ERROR DETECTED: $e');
  }

  print('=== DEBUG SESSION COMPLETE ===\n');
}
