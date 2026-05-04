import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/features/skills/domain/usecases/suggest_skill_category_usecase.dart';

void main() {
  late SuggestSkillCategoryUseCase useCase;

  setUp(() {
    useCase = SuggestSkillCategoryUseCase();
  });

  group('SuggestSkillCategoryUseCase', () {
    test('should suggest Technology category for tech-related skills', () {
      const params = SuggestSkillCategoryParams(
        title: 'Flutter Development',
        description: 'Teaching mobile app development with Dart',
      );

      final result = useCase(params);

      expect(result, contains('Technology'));
      expect(result.first, 'Technology');
    });

    test('should suggest Music category for music-related skills', () {
      const params = SuggestSkillCategoryParams(
        title: 'Guitar Lessons',
        description: 'Learn to play acoustic guitar for beginners',
      );

      final result = useCase(params);

      expect(result, contains('Music'));
      expect(result.first, 'Music');
    });

    test('should return empty list when no keywords match', () {
      const params = SuggestSkillCategoryParams(
        title: 'Xyzabc',
        description: 'Qwerty asdfgh zxcvbn',
      );

      final result = useCase(params);

      expect(result, isEmpty);
    });

    test('should return multiple suggestions ranked by relevance', () {
      const params = SuggestSkillCategoryParams(
        title: 'Spanish Cooking',
        description: 'Learn to cook Spanish cuisine and bake bread',
      );

      final result = useCase(params);

      expect(result.length, greaterThanOrEqualTo(2));
    });
  });
}
