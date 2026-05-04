import 'package:equatable/equatable.dart';
import 'package:myapp/core/constants/skill_categories.dart';

class SuggestSkillCategoryUseCase {
  SuggestSkillCategoryUseCase();

  List<String> call(SuggestSkillCategoryParams params) {
    return SkillCategories.suggest(params.title, params.description);
  }
}

class SuggestSkillCategoryParams extends Equatable {
  final String title;
  final String description;

  const SuggestSkillCategoryParams({
    required this.title,
    required this.description,
  });

  @override
  List<Object?> get props => [title, description];
}
