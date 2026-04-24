import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/models/skill_model.dart';
import 'package:myapp/core/models/match_model.dart';
import 'package:myapp/core/models/user_model.dart';
import 'package:myapp/core/repositories/match_repository.dart';
import 'package:myapp/core/repositories/skill_repository.dart';
import 'package:myapp/core/repositories/user_repository.dart';
import 'package:myapp/core/services/location_service.dart';
import 'package:myapp/core/models/location_model.dart';
import 'package:firebase_database/firebase_database.dart';

class MockSkillRepository extends Mock implements SkillRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class MockLocationService extends Mock implements LocationService {}

class MockFirebaseDatabase extends Mock implements FirebaseDatabase {}

class MockDatabaseReference extends Mock implements DatabaseReference {}

class FakeLocationModel extends Fake implements LocationModel {}

void main() {
  late MatchRepositoryImpl repository;
  late MockSkillRepository mockSkillRepo;
  late MockUserRepository mockUserRepo;
  late MockLocationService mockLocationService;
  late MockFirebaseDatabase mockDatabase;
  late MockDatabaseReference mockRef;

  setUpAll(() {
    registerFallbackValue(FakeLocationModel());
  });

  setUp(() {
    mockSkillRepo = MockSkillRepository();
    mockUserRepo = MockUserRepository();
    mockLocationService = MockLocationService();
    mockDatabase = MockFirebaseDatabase();
    mockRef = MockDatabaseReference();

    when(() => mockDatabase.ref(any())).thenReturn(mockRef);
    when(() => mockRef.child(any())).thenReturn(mockRef);
    when(() => mockRef.orderByChild(any())).thenReturn(mockRef);
    when(() => mockRef.equalTo(any())).thenReturn(mockRef);
    when(() => mockRef.set(any())).thenAnswer((_) async => {});
    when(() => mockRef.get()).thenAnswer((_) async {
      final snapshot = MockDataSnapshot();
      when(() => snapshot.exists).thenReturn(false);
      return snapshot;
    });

    // Default stub for distance calculation (M04 requirement)
    when(
      () => mockLocationService.calculateDistance(any(), any()),
    ).thenReturn(100.0);
    repository = MatchRepositoryImpl(
      mockSkillRepo,
      mockUserRepo,
      mockLocationService,
      database: mockDatabase,
    );
  });

  final learner = UserModel(
    uid: 'learner1',
    email: 'l@test.com',
    displayName: 'Learner',
    desiredSkills: [
      SkillModel(id: 'd1', name: 'Flutter', description: '', level: 'Beginner'),
    ],
    offeredSkills: [],
    location: null,
    availability: {},
    trustScore: 4.0,
    createdAt: DateTime.now(),
  );

  final teacherBeginner = UserModel(
    uid: 'teacher1',
    email: 't1@test.com',
    displayName: 'Teacher 1',
    offeredSkills: [],
    desiredSkills: [],
    location: null,
    availability: {},
    trustScore: 4.0,
    createdAt: DateTime.now(),
  );

  final teacherExpert = UserModel(
    uid: 'teacher2',
    email: 't2@test.com',
    displayName: 'Teacher 2',
    offeredSkills: [],
    desiredSkills: [],
    location: null,
    bio: 'Expert Flutter developer.',
    availability: {},
    trustScore: 4.0,
    createdAt: DateTime.now(),
  );

  final offerBeginner = SkillModel(
    id: 'o1',
    name: 'Flutter',
    description: '',
    level: 'Beginner',
    ownerId: 'teacher1',
    type: 'offer',
  );
  final offerExpert = SkillModel(
    id: 'o2',
    name: 'Flutter',
    description: '',
    level: 'Expert',
    ownerId: 'teacher2',
    type: 'offer',
  );

  test('generateMatches ranks expert and local matches higher', () async {
    when(
      () => mockUserRepo.getUser('learner1'),
    ).thenAnswer((_) async => learner);
    when(
      () => mockSkillRepo.searchSkills(any()),
    ).thenAnswer((_) async => [offerBeginner, offerExpert]);
    when(
      () => mockUserRepo.getUser('teacher1'),
    ).thenAnswer((_) async => teacherBeginner);
    when(
      () => mockUserRepo.getUser('teacher2'),
    ).thenAnswer((_) async => teacherExpert);

    final matches = await repository.generateMatches('learner1');

    expect(matches.length, 2);
    // Teacher 2 (Expert + New York) should be first
    expect(matches.first.teacherUid, 'teacher2');
    expect(matches.first.confidenceScore > matches.last.confidenceScore, true);
  });

  test('updateMatchStatus updates the correct path and status', () async {
    when(() => mockRef.child(any())).thenReturn(mockRef);
    when(() => mockRef.update(any())).thenAnswer((_) async => {});

    await repository.updateMatchStatus('match_123', 'accepted');

    verify(() => mockRef.update({'status': 'accepted'})).called(1);
  });

  test('generateMatches preserves existing match status', () async {
    final existingMatch = MatchModel(
      id: 'learner1_teacher2_o2', // Matches the ID generated in the test
      teacherUid: 'teacher2',
      learnerUid: 'learner1',
      skillName: 'Flutter',
      confidenceScore: 0.9,
      status: 'declined',
    );

    when(() => mockUserRepo.getUser('learner1')).thenAnswer((_) async => learner);
    when(() => mockSkillRepo.searchSkills(any())).thenAnswer((_) async => [offerExpert]);
    when(() => mockUserRepo.getUser('teacher2')).thenAnswer((_) async => teacherExpert);
    
    // Mock getMatches to return the existing declined match
    when(() => mockRef.orderByChild('learnerUid')).thenReturn(mockRef);
    when(() => mockRef.equalTo('learner1')).thenReturn(mockRef);
    when(() => mockRef.get()).thenAnswer((_) async {
      final mockSnapshot = MockDataSnapshot();
      when(() => mockSnapshot.exists).thenReturn(true);
      when(() => mockSnapshot.value).thenReturn({
        'learner1_teacher2_o2': existingMatch.toJson(),
      });
      return mockSnapshot;
    });

    final matches = await repository.generateMatches('learner1');

    expect(matches.length, 1);
    expect(matches.first.status, 'declined');
    // Verify it was saved with 'declined' status
    verify(() => mockRef.set(any(that: predicate((map) => (map as Map)['status'] == 'declined')))).called(1);
  });
}

class MockDataSnapshot extends Mock implements DataSnapshot {}
