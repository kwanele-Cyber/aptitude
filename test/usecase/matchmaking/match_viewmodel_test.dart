import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/usecase/matchmaking/match_viewmodel.dart';
import 'package:myapp/core/repositories/match_repository.dart';
import 'package:myapp/core/models/match_model.dart';

class MockMatchRepository extends Mock implements MatchRepository {}

void main() {
  late MatchViewModel viewModel;
  late MockMatchRepository mockRepo;

  final matches = [
    MatchModel(
      id: '1',
      teacherUid: 't1',
      learnerUid: 'l1',
      skillName: 'Flutter',
      confidenceScore: 0.9,
      status: 'pending',
    ),
    MatchModel(
      id: '2',
      teacherUid: 't2',
      learnerUid: 'l1',
      skillName: 'Dart',
      confidenceScore: 0.8,
      status: 'accepted',
    ),
    MatchModel(
      id: '3',
      teacherUid: 't3',
      learnerUid: 'l1',
      skillName: 'Firebase',
      confidenceScore: 0.7,
      status: 'ignored',
    ),
  ];

  setUp(() {
    mockRepo = MockMatchRepository();
    viewModel = MatchViewModel(mockRepo);
    
    // Inject matches manually for testing filtering without repo calls
    // In a real scenario we'd call loadMatches, but we can set the private field via reflection 
    // or just use the repo stub. Let's use the repo stub.
    when(() => mockRepo.getMatches(any())).thenAnswer((_) async => matches);
  });

  test('filteredMatches hides ignored matches by default', () async {
    await viewModel.loadSavedMatches('l1');
    expect(viewModel.filteredMatches.length, 2);
    expect(viewModel.filteredMatches.any((m) => m.status == 'ignored'), false);
  });

  test('filteredMatches applies status filter', () async {
    await viewModel.loadSavedMatches('l1');
    
    viewModel.setStatusFilter('accepted');
    expect(viewModel.filteredMatches.length, 1);
    expect(viewModel.filteredMatches.first.skillName, 'Dart');
    
    viewModel.setStatusFilter('pending');
    expect(viewModel.filteredMatches.length, 1);
    expect(viewModel.filteredMatches.first.skillName, 'Flutter');
  });

  test('filteredMatches applies search query', () async {
    await viewModel.loadSavedMatches('l1');
    
    viewModel.setSearchQuery('flu');
    expect(viewModel.filteredMatches.length, 1);
    expect(viewModel.filteredMatches.first.skillName, 'Flutter');
    
    viewModel.setSearchQuery('xyz');
    expect(viewModel.filteredMatches.length, 0);
  });

  test('filteredMatches combines status and search', () async {
    await viewModel.loadSavedMatches('l1');
    
    viewModel.setStatusFilter('accepted');
    viewModel.setSearchQuery('Dart');
    expect(viewModel.filteredMatches.length, 1);
    
    viewModel.setSearchQuery('Flutter');
    expect(viewModel.filteredMatches.length, 0);
  });
}
