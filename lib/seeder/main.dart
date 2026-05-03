import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/firebase_options.dart';
import 'package:myapp/core/services/seed_data_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint('=== Aptitude Seeder ===');
  debugPrint('Initializing Firebase...');

  String uid;
  try {
    final userCredential = await FirebaseAuth.instance.signInAnonymously();
    uid = userCredential.user!.uid;
    debugPrint('Authenticated anonymously as: $uid');
  } on FirebaseAuthException catch (e) {
    // Anonymous auth not enabled — use a fixed seed UID
    debugPrint('Anonymous auth unavailable (${e.code}), using seed UID');
    uid = 'seed_admin_uid';
  }

  try {
    final seeder = SeedDataService();
    await seeder.seed(uid);
    debugPrint('Seeding complete. You can close this window.');
  } on FirebaseException catch (e) {
    debugPrint('Firebase error: ${e.code} — ${e.message}');
  } catch (e) {
    debugPrint('Unexpected error: $e');
  }

  runApp(const _SeederStatus());
}

class _SeederStatus extends StatelessWidget {
  const _SeederStatus();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF0F0F1A),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF34D399), size: 64),
              const SizedBox(height: 16),
              Text(
                'Seed Complete',
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You can close this window.',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
