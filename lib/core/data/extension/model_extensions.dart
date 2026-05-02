import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:myapp/core/data/models/skill.dart';
import 'package:myapp/core/data/models/user.dart';
import 'package:myapp/core/data/models/location_model.dart';
import 'package:myapp/core/data/repositories/skills_repository.dart';
import 'package:myapp/core/data/repositories/user_repository.dart';
import 'package:myapp/core/data/repositories/user_skills_repository.dart';
import 'package:myapp/core/data/models/skill_offer.dart';
import 'package:myapp/core/data/models/skill_enums.dart';

extension UserExtension on User {
  User copyWith({
    String? uid,
    String? email,
    String? firstName,
    String? lastName,
    String? title,
    String? photoURL,
    List<String>? skills,
    List<String>? interests,
    String? bio,
    AddressModel? location,
    bool? profileComplete,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      title: title ?? this.title,
      photoURL: photoURL ?? this.photoURL,
      skills: skills ?? this.skills,
      interests: interests ?? this.interests,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      profileComplete: profileComplete ?? this.profileComplete,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Future<Skill?> addSkillByName({
    required String name,
    String category = '',
    String description = '',
    bool persist = true,
  }) async {
    final repo = SkillsRepository();
    final userRepo = UserRepository();

    // 1. Resolve the skill globally (prevents duplicates in global skills table)
    final skillId = await repo.resolveSkillId(name, description, category);

    // 2. Check if the user already has this skill (prevents duplicates in user.skills)
    if (skills.contains(skillId)) {
      return await repo.getSkill(skillId);
    }

    // 3. Add the unique ID to the user's skills list
    skills.add(skillId);
    if (persist) {
      await userRepo.update(uid, {"skills": skills});
    }

    // 4. Unified Logic: Create a default SkillOffer if it doesn't exist
    final userSkillsRepo = UserSkillsRepository();
    final existingOffers = await userSkillsRepo.getUserOffers(uid);
    final hasOffer = existingOffers.any((o) => o.sid == skillId);

    if (!hasOffer) {
      final skill = await repo.getSkill(skillId);
      final offer = SkillOffer(
        uid: uid,
        sid: skillId,
        skillName: skill?.name ?? name,
        level: SkillLevel.beginner,
        format: SkillFormat.online,
        description: 'Added via profile setup',
      );
      await userSkillsRepo.addOffer(offer);
    }

    return await repo.getSkill(skillId);
  }

  Future<List<Skill>> addSkillsNames(List<String> SkillNames) async {
    final userRepo = UserRepository();
    final userSkillsRepo = UserSkillsRepository();
    List<Skill> results = [];

    for (final skillname in SkillNames) {
      // We pass persist: false to avoid updating the DB in every iteration
      Skill? skill = await addSkillByName(name: skillname, persist: false);
      if (skill != null) {
        results.add(skill);
      }
    }

    // 5. Prune offers for skills no longer in the core list
    final offers = await userSkillsRepo.getUserOffers(uid);
    for (final offer in offers) {
      if (!skills.contains(offer.sid)) {
        await userSkillsRepo.deleteOffer(uid, offer.id);
      }
    }

    // After adding all skills locally to the user object, we persist once.
    await userRepo.update(uid, {"skills": skills});

    return results;
  }
}
