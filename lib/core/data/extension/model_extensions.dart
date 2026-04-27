import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:myapp/core/data/models/skill.dart';
import 'package:myapp/core/data/models/user.dart';
import 'package:myapp/core/data/models/location_model.dart';
import 'package:myapp/core/data/repositories/skills_repository.dart';
import 'package:myapp/core/data/repositories/user_repository.dart';

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
    final _repo = SkillsRepository();
    final _userRepo = UserRepository();

    // 1. Resolve the skill globally (prevents duplicates in global skills table)
    final skillId = await _repo.resolveSkillId(name, description, category);

    // 2. Check if the user already has this skill (prevents duplicates in user.skills)
    if (skills.contains(skillId)) {
      return await _repo.getSkill(skillId);
    }

    // 3. Add the unique ID to the user's skills list
    skills.add(skillId);
    if (persist) {
      await _userRepo.update(uid, {"skills": skills});
    }

    return await _repo.getSkill(skillId);
  }

  Future<List<Skill>> addSkillsNames(List<String> SkillNames) async {
    final _userRepo = UserRepository();
    List<Skill> results = [];

    for (final skillname in SkillNames) {
      // We pass persist: false to avoid updating the DB in every iteration
      Skill? skill = await addSkillByName(name: skillname, persist: false);
      if (skill != null) {
        results.add(skill);
      }
    }

    // After adding all skills locally to the user object, we persist once.
    await _userRepo.update(uid, {"skills": skills});

    return results;
  }
}
