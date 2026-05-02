import 'package:myapp/core/data/models/skill.dart';
import 'package:myapp/core/data/repositories/skill_repository.dart';
import 'package:myapp/core/data/repositories/user_repository.dart';

class GetUserSkillsUseCase {
  Future<List<Skill>> execute({required String userId}) async {
    final userRepo = UserRepository();
    final skillRepo = SkillRepository();

    // ✅ 1. Get user
    final user = await userRepo.read(userId);

    if (user == null) {
      throw Exception("User not found");
    }

    // If user has no skills
    if (user.skills.isEmpty) {
      return [];
    }

    // ✅ 2. Fetch all skills one by one
    List<Skill> skills = [];

    for (String skillId in user.skills) {
      final data = await skillRepo.read(location: "skills/$skillId");

      if (data != null) {
        skills.add(data);
      }
    }

    return skills;
  }
}
