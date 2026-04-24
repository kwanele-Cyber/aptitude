import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/firebase_options.dart';
import 'package:myapp/core/models/user_model.dart';
import 'package:myapp/core/models/skill_model.dart';
import 'package:myapp/core/models/agreement_model.dart';
import 'package:myapp/core/models/location_model.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('--- [SEED] Initializing Firebase ---');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('--- [SEED] Firebase Initialized ---');

  runApp(MaterialApp(
    home: Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Text('Seeding Database & Auth...', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            const Text('Check terminal for progress.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    ),
  ));

  // Run seeding
  Future.delayed(const Duration(seconds: 1), () async {
    await seedDatabaseAndAuth();
    print('\n🚀 SEEDING COMPLETE! You can now close the app.');
  });
}

Future<void> seedDatabaseAndAuth() async {
  final db = FirebaseDatabase.instance.ref();
  final auth = FirebaseAuth.instance;
  final uuid = const Uuid();

  // Define seed user data
  final seedUsers = [
    {
      'email': 'admin@aptitude.com',
      'password': 'admin123',
      'name': 'System Admin',
      'isMentor': false,
      'role': UserRole.admin,
    },
    {
      'email': 'jane.doe@example.com',
      'password': 'password123',
      'name': 'Jane Doe',
      'isMentor': true,
      'role': UserRole.user,
    },
    {
      'email': 'john.smith@example.com',
      'password': 'password123',
      'name': 'John Smith',
      'isMentor': true,
      'role': UserRole.user,
    },
  ];

  Map<String, String> emailToUid = {};

  print('\n1. Creating Auth Users & Database Profiles...');
  for (var data in seedUsers) {
    try {
      print('   - Registering ${data['email']}...');
      final credential = await auth.createUserWithEmailAndPassword(
        email: data['email'] as String,
        password: data['password'] as String,
      );
      
      final uid = credential.user!.uid;
      emailToUid[data['email'] as String] = uid;

      final newUser = UserModel(
        uid: uid,
        email: data['email'] as String,
        displayName: data['name'] as String,
        offeredSkills: [],
        desiredSkills: [],
        availability: {'mon': '9-17', 'wed': '18-20'},
        trustScore: 4.5,
        createdAt: DateTime.now(),
        role: data['role'] as UserRole,
      );

      await db.child('users/$uid').set(newUser.toJson());
      print('     ✅ Success! UID: $uid');
      
      // Sign out to prepare for next creation
      await auth.signOut();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print('     ℹ️ ${data['email']} already exists. Fetching existing UID...');
        // We can't easily get UID from email without Admin SDK, 
        // so we'll just try to sign in to get the UID.
        final cred = await auth.signInWithEmailAndPassword(
          email: data['email'] as String,
          password: data['password'] as String,
        );
        emailToUid[data['email'] as String] = cred.user!.uid;
        await auth.signOut();
      } else {
        print('     ❌ Error: ${e.message}');
      }
    }
  }

  final janeUid = emailToUid['jane.doe@example.com'];
  final johnUid = emailToUid['john.smith@example.com'];

  if (janeUid != null && johnUid != null) {
    print('\n2. Seeding Skills for Users...');
    
    final skills = [
      SkillModel(
        id: uuid.v4(),
        name: 'Flutter Development',
        description: 'Expert mobile app development.',
        level: 'Expert',
        ownerId: janeUid,
        type: 'offer',
      ),
      SkillModel(
        id: uuid.v4(),
        name: 'Python',
        description: 'Data Science and Automation.',
        level: 'Intermediate',
        ownerId: johnUid,
        type: 'offer',
      ),
    ];

    for (var skill in skills) {
      await db.child('skills/${skill.id}').set(skill.toJson());
    }
    print('   ✅ Skills created.');

    print('\n3. Seeding Sample Agreement...');
    final agreement = AgreementModel(
      id: uuid.v4(),
      learnerId: johnUid,
      mentorId: janeUid,
      learnerSkill: 'Flutter',
      mentorSkill: 'Python',
      frequency: 'Weekly',
      duration: 1.0,
      status: AgreementStatus.accepted,
      createdAt: DateTime.now(),
    );

    await db.child('agreements/${agreement.id}').set(agreement.toJson());
    print('   ✅ Agreement created between Jane and John.');
  }
}
