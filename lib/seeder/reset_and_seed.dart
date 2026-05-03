import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/firebase_options.dart';
import 'package:myapp/core/services/seed_data_service.dart';

/// Resets the Firebase RTDB and auth users, then re-seeds.
///
/// Run with: flutter run -t lib/seeder/reset_and_seed.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint('=== Aptitude Reset & Seed ===');

  // ── 1. Wipe the Realtime Database ───────────────────────────────────
  final db = FirebaseDatabase.instance.ref();
  final rootNodes = [
    'users',
    'skills',
    'skill_offers',
    'skill_requests',
    'matches',
    'invites',
    'chat_channels',
    'chat_messages',
    'agreements',
    'sessions',
    'session_materials',
    'session_notes',
    'blocks',
    'notifications',
    'ratings',
    'reports',
    'match_feedback',
    'saved_searches',
    'typing',
  ];

  for (final node in rootNodes) {
    try {
      await db.child(node).remove();
      debugPrint('  Removed /$node');
    } catch (e) {
      debugPrint('  Skipped /$node (empty or error): $e');
    }
  }

  // ── 2. Delete existing persona auth users ────────────────────────────
  FirebaseApp? seederApp;
  try {
    seederApp = Firebase.app('Seeder');
  } catch (_) {
    seederApp = await Firebase.initializeApp(
      name: 'Seeder',
      options: Firebase.app().options,
    );
  }

  final personas = [
    ('alex@example.com', 'Password123!'),
    ('sarah@example.com', 'Password123!'),
    ('marco@example.com', 'Password123!'),
  ];

  for (final (email, password) in personas) {
    try {
      final seederAuth = FirebaseAuth.instanceFor(app: seederApp);
      final cred = await seederAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cred.user?.delete();
      debugPrint('  Deleted auth user: $email');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        debugPrint('  Auth user not found (already clean): $email');
      } else {
        debugPrint('  Could not delete $email: ${e.code}');
      }
    }
  }

  // Also try to sign out from Seeder app if a session lingered
  try {
    await FirebaseAuth.instanceFor(app: seederApp).signOut();
  } catch (_) {}

  // ── 3. Authenticate a seed user ──────────────────────────────────────
  String uid;
  try {
    final userCredential = await FirebaseAuth.instance.signInAnonymously();
    uid = userCredential.user!.uid;
    debugPrint('Authenticated anonymously as: $uid');
  } on FirebaseAuthException catch (e) {
    debugPrint('Anonymous auth unavailable (${e.code}), using seed UID');
    uid = 'seed_admin_uid';
  }

  // ── 4. Run the seeder ────────────────────────────────────────────────
  try {
    final seeder = SeedDataService();
    await seeder.seed(uid);
    debugPrint('Seeding complete.');
  } on FirebaseException catch (e) {
    debugPrint('Firebase error: ${e.code} — ${e.message}');
  } catch (e) {
    debugPrint('Unexpected error: $e');
  }

  debugPrint('=== Done ===');

  runApp(const _ResetSeedStatus());
}

class _ResetSeedStatus extends StatelessWidget {
  const _ResetSeedStatus();

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
                'Reset & Seed Complete',
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
