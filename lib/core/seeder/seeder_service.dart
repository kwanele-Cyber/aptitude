import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/core/seeder/seed_data.dart';
import 'package:myapp/core/seeder/seeder_utils.dart';

class SeedProgress {
  final String step;
  final double progress;
  final bool isError;
  const SeedProgress({
    required this.step,
    required this.progress,
    this.isError = false,
  });
}

class SeederService {
  final FirebaseAuth _auth;
  final FirebaseDatabase _database;

  SeederService({FirebaseAuth? auth, FirebaseDatabase? database})
      : _auth = auth ?? FirebaseAuth.instance,
        _database = database ?? FirebaseDatabase.instance;

  Stream<SeedProgress> run() async* {
    final results = <String>[];
    final emailToUid = <String, String>{};
    final skillIdByTitle = <String, String>{};
    final skillDataByTitle = <String, Map<String, dynamic>>{};

    try {
      // Step 1: Create auth accounts
      yield const SeedProgress(
        step: 'Creating user accounts...',
        progress: 0.0,
      );
      for (final user in seedUsers) {
        String uid;
        try {
          final credential = await _auth.createUserWithEmailAndPassword(
            email: user.email,
            password: user.password,
          );
          uid = credential.user!.uid;
          results.add('✓ Created auth: ${user.email}');
        } on FirebaseAuthException catch (e) {
          if (e.code == 'email-already-in-use') {
            // Sign in to get existing UID
            final credential = await _auth.signInWithEmailAndPassword(
              email: user.email,
              password: user.password,
            );
            uid = credential.user!.uid;
            await _auth.signOut();
            results.add('→ Existing auth: ${user.email}');
          } else {
            yield SeedProgress(
              step: 'Auth error for ${user.email}: ${e.message}',
              progress: 0.1,
              isError: true,
            );
            return;
          }
        }
        emailToUid[user.email] = uid;
      }
      await _auth.signOut();

      // Step 2: Write user profiles
      yield const SeedProgress(
        step: 'Creating user profiles...',
        progress: 0.2,
      );
      final now = DateTime.now();
      for (final user in seedUsers) {
        final uid = emailToUid[user.email]!;
        final profileJson = {
          'uid': uid,
          'email': user.email,
          'firstName': user.firstName,
          'lastName': user.lastName,
          'title': user.title,
          'photoURL': '',
          'skills': user.skills,
          'interests': user.interests,
          'bio': user.bio,
          'location': {
            'address': user.addressLabel,
            'latitude': user.latitude,
            'longitude': user.longitude,
          },
          'phone': null,
          'profileComplete': true,
          'twoFactorEnabled': false,
          'twoFactorPin': null,
          'trustScore': user.trustScore,
          'isVerified': true,
          'role': user.role,
          'updatedAt': formatTimestamp(now),
          'createdAt': formatTimestamp(now),
        };
        await _database.ref('users/$uid').set(profileJson);
        results.add('✓ Created profile: ${user.firstName} ${user.lastName}');
      }

      // Step 3: Create skills
      yield const SeedProgress(
        step: 'Creating skills...',
        progress: 0.5,
      );
      for (final skill in seedSkills) {
        final uid = emailToUid[skill.ownerEmail]!;
        final pushRef = _database.ref('skills').push();
        final pushId = pushRef.key!;
        final skillJson = {
          'title': skill.title,
          'description': skill.description,
          'category': skill.category,
          'type': skill.type,
          'level': skill.level,
          'format': skill.format,
          'userId': uid,
          'tags': skill.tags,
          'createdAt': formatTimestamp(now),
          'updatedAt': formatTimestamp(now),
          'archivedAt': null,
          'isVerified': true,
          'portfolioUrls': <String>[],
          'latitude': _latitudeForEmail(skill.ownerEmail),
          'longitude': _longitudeForEmail(skill.ownerEmail),
          'availability': skill.availability,
        };
        await pushRef.set(skillJson);
        skillIdByTitle[skill.title] = pushId;
        skillDataByTitle[skill.title] = skillJson;
        results.add('✓ Created skill: ${skill.title}');
      }

      // Step 4: Generate matches
      yield const SeedProgress(
        step: 'Computing matches...',
        progress: 0.7,
      );
      final offers =
          seedSkills.where((s) => s.type == 'offer').toList();
      final requests =
          seedSkills.where((s) => s.type == 'request').toList();
      var matchCount = 0;
      final matchKeys = <String>{};

      for (final offer in offers) {
        for (final request in requests) {
          if (offer.ownerEmail == request.ownerEmail) continue;

          final aData = skillDataByTitle[offer.title]!;
          final bData = skillDataByTitle[request.title]!;

          final result = calculateMatchScore(
            categoryA: aData['category'] as String,
            levelA: aData['level'] as String,
            formatA: aData['format'] as String,
            tagsA: List<String>.from(aData['tags'] as List),
            latA: aData['latitude'] as double?,
            lngA: aData['longitude'] as double?,
            availabilityA: List<String>.from(aData['availability'] as List),
            categoryB: bData['category'] as String,
            levelB: bData['level'] as String,
            formatB: bData['format'] as String,
            tagsB: List<String>.from(bData['tags'] as List),
            latB: bData['latitude'] as double?,
            lngB: bData['longitude'] as double?,
            availabilityB: List<String>.from(bData['availability'] as List),
          );

          if (result.score >= 20) {
            final offerUid = emailToUid[offer.ownerEmail]!;
            final requestUid = emailToUid[request.ownerEmail]!;
            final matchId = '${skillIdByTitle[offer.title]}_${skillIdByTitle[request.title]}';
            if (matchKeys.contains(matchId)) continue;
            matchKeys.add(matchId);

            final matchJson = {
              'targetUserId': requestUid,
              'targetSkillId': skillIdByTitle[request.title],
              'matchedSkillId': skillIdByTitle[offer.title],
              'score': result.score,
              'status': 'pending',
              'createdAt': formatTimestamp(now),
              'targetUserName': _nameForEmail(request.ownerEmail),
              'targetSkillTitle': request.title,
              'targetSkillCategory': request.category,
              'targetSkillLevel': request.level,
              'targetSkillFormat': request.format,
              'targetTrustScore': _trustScoreForEmail(request.ownerEmail),
              'targetIsVerified': true,
              'distance': result.distance,
              'targetAvailability': result.commonAvailability,
            };
            await _database.ref('matches/$matchId').set(matchJson);
            matchCount++;

            // Also do the reverse direction
            final reverseId = '${skillIdByTitle[request.title]}_${skillIdByTitle[offer.title]}';
            if (!matchKeys.contains(reverseId)) {
              matchKeys.add(reverseId);
              final reverseJson = {
                'targetUserId': offerUid,
                'targetSkillId': skillIdByTitle[offer.title],
                'matchedSkillId': skillIdByTitle[request.title],
                'score': result.score,
                'status': 'pending',
                'createdAt': formatTimestamp(now),
                'targetUserName': _nameForEmail(offer.ownerEmail),
                'targetSkillTitle': offer.title,
                'targetSkillCategory': offer.category,
                'targetSkillLevel': offer.level,
                'targetSkillFormat': offer.format,
                'targetTrustScore': _trustScoreForEmail(offer.ownerEmail),
                'targetIsVerified': true,
                'distance': result.distance,
                'targetAvailability': result.commonAvailability,
              };
              await _database.ref('matches/$reverseId').set(reverseJson);
              matchCount++;
            }
          }
        }
      }
      results.add('✓ Created $matchCount matches');

      // Step 5: Also seed matches by calling existing algorithm for each user
      // --- Skip this step, already done above ---

      yield const SeedProgress(
        step: 'Seeding complete!',
        progress: 1.0,
      );

      // Store results for the UI to display
      // We cache them in a field since streams can't carry complex data easily
      _lastResults = [
        '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
        '🌱  SEED COMPLETE',
        '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
        ...results,
        '',
        '📋  LOGIN CREDENTIALS:',
        'Password for all: SeedPassword123!',
        ...seedUsers.map((u) =>
            '   ${u.email}  →  ${u.firstName} ${u.lastName} (${u.role})'),
      ];
    } catch (e) {
      yield SeedProgress(
        step: 'Seed failed: $e',
        progress: 0.0,
        isError: true,
      );
    }
  }

  List<String> get lastResults => _lastResults;
  List<String> _lastResults = [];

  double? _latitudeForEmail(String email) {
    final user = seedUsers.firstWhere((u) => u.email == email);
    return user.latitude + (Random().nextDouble() - 0.5) * 0.02;
  }

  double? _longitudeForEmail(String email) {
    final user = seedUsers.firstWhere((u) => u.email == email);
    return user.longitude + (Random().nextDouble() - 0.5) * 0.02;
  }

  String _nameForEmail(String email) {
    final user = seedUsers.firstWhere((u) => u.email == email);
    return '${user.firstName} ${user.lastName}';
  }

  double _trustScoreForEmail(String email) {
    final user = seedUsers.firstWhere((u) => u.email == email);
    return user.trustScore;
  }
}
