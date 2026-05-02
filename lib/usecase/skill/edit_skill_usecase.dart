import 'package:myapp/core/data/repositories/skill_repository.dart';
import 'package:myapp/core/data/repositories/user_repository.dart';

class EditSkillUseCase {
  Future<void> execute({
    required String userId,
    required String skillId,
    required String skillName,
    required String description,
    required String category,
  }) async {
    final skillRepo = SkillRepository();
    final userRepo = UserRepository();

    // ✅ 1. Get user (optional but important for validation)
    final user = await userRepo.read("users/$userId");

    if (user == null) {
      throw Exception("User not found");
    }

    // ✅ 2. Check if user owns this skill
    if (!user.skills.contains(skillId)) {
      throw Exception("User does not own this skill");
    }

    // ✅ 3. Update the skill
    await skillRepo.update(
      location: "skills/$skillId",
      data: {
        "name": skillName,
        "description": description,
        "category": category,
      },
    );
  }
}
