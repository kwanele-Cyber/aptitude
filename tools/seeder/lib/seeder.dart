import 'dart:math';

import 'firebase_client.dart';
import 'seed_data.dart';

class Seeder {
  final FirebaseClient client;

  Seeder({required this.client});

  Future<void> run({
    required void Function(String) onLog,
  }) async {
    final results = <String>[];
    final emailToUid = <String, String>{};
    String? adminIdToken;
    final skillIdByTitle = <String, String>{};
    final skillDataByTitle = <String, Map<String, dynamic>>{};

    // ── Step 1: Create auth accounts ──────────────────────────
    onLog('Step 1/4: Creating auth accounts...');
    for (final user in seedUsers) {
      String uid;
      try {
        final result = await client.signUp(user.email, user.password);
        uid = result.uid;
        adminIdToken ??= result.idToken;
        results.add('  ✓ Created: ${user.email}');
      } on FirebaseEmailExistsException {
        final result = await client.signIn(user.email, user.password);
        uid = result.uid;
        adminIdToken ??= result.idToken;
        results.add('  → Exists:  ${user.email}');
      } on FirebaseApiException catch (e) {
        onLog('  ✗ Failed:  ${user.email} — $e');
        return;
      }
      emailToUid[user.email] = uid;
    }
    for (final line in results) {
      onLog(line);
    }
    results.clear();

    if (adminIdToken == null) {
      onLog('  ✗ No admin ID token available — aborting');
      return;
    }

    // ── Step 2: Write user profiles ───────────────────────────
    onLog('Step 2/4: Writing user profiles...');
    final now = DateTime.now().toUtc().toIso8601String();
    for (final user in seedUsers) {
      final uid = emailToUid[user.email]!;
      await client.put(
        'users/$uid',
        {
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
          'updatedAt': now,
          'createdAt': now,
        },
        idToken: adminIdToken,
      );
      onLog('  ✓ ${user.firstName} ${user.lastName}');
    }

    // ── Step 3: Create skills ─────────────────────────────────
    onLog('Step 3/4: Creating skills...');
    for (final skill in seedSkills) {
      final uid = emailToUid[skill.ownerEmail]!;
      final pushId = await client.post(
        'skills',
        {
          'title': skill.title,
          'description': skill.description,
          'category': skill.category,
          'type': skill.type,
          'level': skill.level,
          'format': skill.format,
          'userId': uid,
          'tags': skill.tags,
          'createdAt': now,
          'updatedAt': now,
          'archivedAt': null,
          'isVerified': true,
          'portfolioUrls': <String>[],
          'latitude': _jitter(skill.ownerEmail, true),
          'longitude': _jitter(skill.ownerEmail, false),
          'availability': skill.availability,
        },
        idToken: adminIdToken,
      );
      skillIdByTitle[skill.title] = pushId;
      skillDataByTitle[skill.title] = {
        'category': skill.category,
        'level': skill.level,
        'format': skill.format,
        'tags': skill.tags,
        'latitude': _jitter(skill.ownerEmail, true),
        'longitude': _jitter(skill.ownerEmail, false),
        'availability': skill.availability,
      };
      onLog('  ✓ ${skill.title}');
    }

    // ── Step 4: Compute matches ───────────────────────────────
    onLog('Step 4/4: Computing matches...');
    final offers = seedSkills.where((s) => s.type == 'offer').toList();
    final requests = seedSkills.where((s) => s.type == 'request').toList();
    var matchCount = 0;
    final matchKeys = <String>{};

    for (final offer in offers) {
      for (final request in requests) {
        if (offer.ownerEmail == request.ownerEmail) continue;

        final a = skillDataByTitle[offer.title]!;
        final b = skillDataByTitle[request.title]!;

        final result = calculateMatchScore(
          categoryA: a['category'] as String,
          levelA: a['level'] as String,
          formatA: a['format'] as String,
          tagsA: List<String>.from(a['tags'] as List),
          latA: a['latitude'] as double?,
          lngA: a['longitude'] as double?,
          availabilityA: List<String>.from(a['availability'] as List),
          categoryB: b['category'] as String,
          levelB: b['level'] as String,
          formatB: b['format'] as String,
          tagsB: List<String>.from(b['tags'] as List),
          latB: b['latitude'] as double?,
          lngB: b['longitude'] as double?,
          availabilityB: List<String>.from(b['availability'] as List),
        );

        if (result.score >= 20) {
          final offerUid = emailToUid[offer.ownerEmail]!;
          final requestUid = emailToUid[request.ownerEmail]!;
          final offerId = skillIdByTitle[offer.title]!;
          final requestId = skillIdByTitle[request.title]!;
          final matchId = '${offerId}_$requestId';
          if (!matchKeys.add(matchId)) continue;

          await client.put(
            'matches/$matchId',
            {
              'targetUserId': requestUid,
              'targetSkillId': requestId,
              'matchedSkillId': offerId,
              'score': result.score,
              'status': 'pending',
              'createdAt': now,
              'targetUserName': _nameForEmail(request.ownerEmail),
              'targetSkillTitle': request.title,
              'targetSkillCategory': request.category,
              'targetSkillLevel': request.level,
              'targetSkillFormat': request.format,
              'targetTrustScore': _trustScoreForEmail(request.ownerEmail),
              'targetIsVerified': true,
              'distance': result.distance,
              'targetAvailability': result.commonAvailability,
            },
            idToken: adminIdToken,
          );
          matchCount++;

          // reverse perspective
          final reverseId = '${requestId}_$offerId';
          if (matchKeys.add(reverseId)) {
            await client.put(
              'matches/$reverseId',
              {
                'targetUserId': offerUid,
                'targetSkillId': offerId,
                'matchedSkillId': requestId,
                'score': result.score,
                'status': 'pending',
                'createdAt': now,
                'targetUserName': _nameForEmail(offer.ownerEmail),
                'targetSkillTitle': offer.title,
                'targetSkillCategory': offer.category,
                'targetSkillLevel': offer.level,
                'targetSkillFormat': offer.format,
                'targetTrustScore': _trustScoreForEmail(offer.ownerEmail),
                'targetIsVerified': true,
                'distance': result.distance,
                'targetAvailability': result.commonAvailability,
              },
              idToken: adminIdToken,
            );
            matchCount++;
          }
        }
      }
    }
    onLog('  ✓ Created $matchCount matches');

    // ── Summary ───────────────────────────────────────────────
    onLog('');
    onLog('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    onLog('  ✅  Seeding complete!');
    onLog('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    onLog('');
    onLog('  Login credentials (password for all): SeedPassword123!');
    for (final u in seedUsers) {
      onLog('    ${u.email}  →  ${u.firstName} ${u.lastName} (${u.role})');
    }
    onLog('');
    onLog('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  String _nameForEmail(String email) {
    final user = seedUsers.firstWhere((u) => u.email == email);
    return '${user.firstName} ${user.lastName}';
  }

  double _trustScoreForEmail(String email) {
    return seedUsers.firstWhere((u) => u.email == email).trustScore;
  }

  double _jitter(String email, bool isLat) {
    final user = seedUsers.firstWhere((u) => u.email == email);
    final base = isLat ? user.latitude : user.longitude;
    return base + (Random().nextDouble() - 0.5) * 0.02;
  }
}

// ── Match scoring ────────────────────────────────────────────────

int _levelIndex(String level) {
  switch (level) {
    case 'intermediate':
      return 1;
    case 'advanced':
      return 2;
    default:
      return 0;
  }
}

double _toRadians(double degree) => degree * pi / 180;

double haversineDistance(double lat1, double lon1, double lat2, double lon2) {
  const R = 6371;
  final dLat = _toRadians(lat2 - lat1);
  final dLon = _toRadians(lon2 - lon1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRadians(lat1)) *
          cos(_toRadians(lat2)) *
          sin(dLon / 2) *
          sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return R * c;
}

({double score, double? distance, List<String> commonAvailability})
    calculateMatchScore({
  required String categoryA,
  required String levelA,
  required String formatA,
  required List<String> tagsA,
  required double? latA,
  required double? lngA,
  required List<String> availabilityA,
  required String categoryB,
  required String levelB,
  required String formatB,
  required List<String> tagsB,
  required double? latB,
  required double? lngB,
  required List<String> availabilityB,
}) {
  double score = 0;

  if (categoryA.toLowerCase() == categoryB.toLowerCase()) {
    score += 30;
  } else if (categoryA.toLowerCase().contains(categoryB.toLowerCase()) ||
      categoryB.toLowerCase().contains(categoryA.toLowerCase())) {
    score += 15;
  }

  final levelDiff = (_levelIndex(levelA) - _levelIndex(levelB)).abs();
  if (levelDiff == 0) {
    score += 25;
  } else if (levelDiff == 1) {
    score += 15;
  } else {
    score += 5;
  }

  if (formatA == formatB) {
    score += 20;
  } else if (formatA == 'both' || formatB == 'both') {
    score += 10;
  }

  final commonTags = tagsA.where((t) => tagsB.contains(t)).length;
  score += (commonTags * 5).clamp(0, 15);

  double? distance;
  if (latA != null && lngA != null && latB != null && lngB != null) {
    distance = haversineDistance(latA, lngA, latB, lngB);
    if (distance <= 5) {
      score += 10;
    } else if (distance <= 20) {
      score += 7;
    } else if (distance <= 50) {
      score += 4;
    } else {
      score += 1;
    }
  }

  final commonA =
      availabilityA.where((slot) => availabilityB.contains(slot)).toList();
  score += (commonA.length * 2).clamp(0, 5);

  return (
    score: score.clamp(0, 100).toDouble(),
    distance: distance,
    commonAvailability: commonA,
  );
}
