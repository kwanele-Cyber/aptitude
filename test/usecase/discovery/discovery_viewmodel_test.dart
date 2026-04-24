import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/models/skill_model.dart';
import 'package:myapp/core/repositories/skill_repository.dart';
import 'package:myapp/usecase/discovery/discovery_viewmodel.dart';

class MockSkillRepository extends Mock implements SkillRepository {}

void main() {
  late DiscoveryViewModel viewModel;
  late MockSkillRepository mockRepository;

  setUp(() {
    mockRepository = MockSkillRepository();
    viewModel = DiscoveryViewModel(mockRepository);
  });

  final testSkills = [
    SkillModel(id: '1', name: 'Flutter', description: 'Desc', level: 'Beginner', type: 'offer'),
    SkillModel(id: '2', name: 'Dart', description: 'Desc', level: 'Expert', type: 'offer'),
    SkillModel(id: '3', name: 'React', description: 'Desc', level: 'Beginner', type: 'request'),
  ];

  test('search skills updates results', () async {
    when(() => mockRepository.searchSkills(any())).thenAnswer((_) async => testSkills);

    await viewModel.search('test');

    expect(viewModel.searchResults.length, 3);
    expect(viewModel.isLoading, false);
  });

  test('applying level filter refines results', () async {
    when(() => mockRepository.searchSkills(any())).thenAnswer((_) async => testSkills);

    await viewModel.search('test');
    viewModel.setLevelFilter('Beginner');

    expect(viewModel.searchResults.length, 2);
    expect(viewModel.searchResults.every((s) => s.level == 'Beginner'), true);
  });

  test('applying type filter refines results', () async {
    when(() => mockRepository.searchSkills(any())).thenAnswer((_) async => testSkills);

    await viewModel.search('test');
    viewModel.setTypeFilter('request');

    expect(viewModel.searchResults.length, 1);
    expect(viewModel.searchResults.first.name, 'React');
  });

  test('clearing filters restores results', () async {
    when(() => mockRepository.searchSkills(any())).thenAnswer((_) async => testSkills);

    await viewModel.search('test');
    viewModel.setLevelFilter('Expert');
    expect(viewModel.searchResults.length, 1);

    viewModel.setLevelFilter(null);
    expect(viewModel.searchResults.length, 3);
  });
}
