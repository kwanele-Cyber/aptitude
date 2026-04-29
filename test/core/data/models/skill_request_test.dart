import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/core/data/models/skill_enums.dart';
import 'package:myapp/core/data/models/skill_request.dart';

void main() {
  group('SkillRequest Schema Tests', () {
    test('toJson and fromJson should correctly handle learner-specific fields', () {
      final request = SkillRequest(
        uid: 'user123',
        sid: 'flutter-dev',
        skillName: 'Flutter',
        targetLevel: SkillLevel.expert,
        preferredFormat: SkillFormat.online,
        description: 'I want to learn advanced animations',
      );

      final json = request.toJson();

      expect(json['uid'], 'user123');
      expect(json['targetLevel'], 'expert');
      expect(json['preferredFormat'], 'online');

      final recovered = SkillRequest.fromJson(json);
      expect(recovered.targetLevel, SkillLevel.expert);
      expect(recovered.skillName, 'Flutter');
    });

    test('copyWith should preserve immutability', () {
      final request = SkillRequest(
        uid: 'u1',
        sid: 's1',
        skillName: 'Original',
        targetLevel: SkillLevel.beginner,
        preferredFormat: SkillFormat.online,
        description: 'Old',
      );

      final updated = request.copyWith(
        targetLevel: SkillLevel.intermediate,
        description: 'New',
      );

      expect(updated.targetLevel, SkillLevel.intermediate);
      expect(updated.description, 'New');
      expect(updated.skillName, 'Original'); // Unchanged
    });
  });
}
