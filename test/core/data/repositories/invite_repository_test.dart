import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/core/data/models/invite.dart';
import 'package:myapp/core/data/repositories/invite_repository.dart';
import 'package:myapp/core/services/interfaces/database_inteface.dart';

class MockDatabaseService extends Mock implements DatabaseService<DataSnapshot> {}
class MockDataSnapshot extends Mock implements DataSnapshot {}

void main() {
  late InviteRepository inviteRepository;
  late MockDatabaseService mockDatabaseService;
  late MockDataSnapshot mockDataSnapshot;

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    mockDataSnapshot = MockDataSnapshot();
    inviteRepository = InviteRepository(databaseService: mockDatabaseService);
  });



  final testInvite = Invite(
    id: 'invite_1',
    from: 'user_a',
    to: 'user_b',
    fromName: 'User A',
    toName: 'User B',
    commonSkills: ['Flutter'],
    status: InviteStatus.pending,
    createdAt: DateTime.now().toIso8601String(),
  );

  group('InviteRepository', () {
    test('sendInvite calls database service create', () async {
      when(() => mockDatabaseService.create(
            location: any(named: 'location'),
            data: any(named: 'data'),
          )).thenAnswer((_) async => {});

      await inviteRepository.sendInvite(testInvite);

      verify(() => mockDatabaseService.create(
            location: 'invites/invite_1',
            data: testInvite.toJson(),
          )).called(1);
    });

    test('updateStatus calls database service update', () async {
      when(() => mockDatabaseService.update(
            location: any(named: 'location'),
            data: any(named: 'data'),
          )).thenAnswer((_) async => {});

      await inviteRepository.updateStatus('invite_1', InviteStatus.accepted);

      verify(() => mockDatabaseService.update(
            location: 'invites/invite_1',
            data: {'status': 'accepted'},
          )).called(1);
    });

    test('hasExistingInvite returns true if invite exists', () async {
      when(() => mockDataSnapshot.exists).thenReturn(true);
      when(() => mockDataSnapshot.value).thenReturn({
        'id1': {'from': 'user_a', 'to': 'user_b'}
      });
      when(() => mockDatabaseService.list(location: any(named: 'location')))
          .thenAnswer((_) async => mockDataSnapshot);

      final result = await inviteRepository.hasExistingInvite('user_a', 'user_b');

      expect(result, isTrue);
    });

    test('listByRecipient filters invites correctly', () async {
      when(() => mockDataSnapshot.exists).thenReturn(true);
      final inviteData = testInvite.toJson();
      when(() => mockDataSnapshot.value).thenReturn({
        'id1': inviteData,
        'id2': {...inviteData, 'to': 'other_user'}
      });
      when(() => mockDatabaseService.list(location: any(named: 'location')))
          .thenAnswer((_) async => mockDataSnapshot);

      final result = await inviteRepository.listByRecipient('user_b');

      expect(result.length, 1);
      expect(result.first.to, 'user_b');
    });
  });
}
