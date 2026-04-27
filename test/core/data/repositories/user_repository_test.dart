import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/core/data/models/user.dart';
import 'package:myapp/core/data/models/location_model.dart';
import 'package:myapp/core/data/repositories/user_repository.dart';
import 'package:myapp/core/services/interfaces/database_inteface.dart';

class MockDatabaseService extends Mock
    implements DatabaseService<DataSnapshot> {}

class MockDataSnapshot extends Mock implements DataSnapshot {}

void main() {
  late UserRepository userRepository;
  late MockDatabaseService mockDatabaseService;
  late MockDataSnapshot mockDataSnapshot;

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    mockDataSnapshot = MockDataSnapshot();
    userRepository = UserRepository(databaseService: mockDatabaseService);
  });

  final testUser = User(
    uid: '123',
    email: 'test@example.com',
    firstName: 'Test',
    lastName: 'User',
    title: 'Developer',
    photoURL: '',
    skills: ['Flutter'],
    interests: ['Coding'],
    bio: 'Hello world',
    location: AddressModel.empty(),
    createdAt: DateTime.now(),
    profileComplete: true,
    updatedAt: DateTime.now(),
  );

  group('UserRepository', () {
    test('create calls database service create', () async {
      when(
        () => mockDatabaseService.create(
          location: any(named: 'location'),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => {});

      await userRepository.create(testUser);

      verify(
        () => mockDatabaseService.create(
          location: 'users/123',
          data: testUser.toJson(),
        ),
      ).called(1);
    });

    test('read returns user when snapshot exists', () async {
      when(() => mockDataSnapshot.exists).thenReturn(true);
      when(() => mockDataSnapshot.value).thenReturn(testUser.toJson());
      when(
        () => mockDatabaseService.read(location: any(named: 'location')),
      ).thenAnswer((_) async => mockDataSnapshot);

      final result = await userRepository.read('123');

      expect(result?.uid, testUser.uid);
      expect(result?.email, testUser.email);
    });

    test('read returns null when snapshot does not exist', () async {
      when(() => mockDataSnapshot.exists).thenReturn(false);
      when(
        () => mockDatabaseService.read(location: any(named: 'location')),
      ).thenAnswer((_) async => mockDataSnapshot);

      final result = await userRepository.read('123');

      expect(result, isNull);
    });

    test('update calls database service update', () async {
      final updates = {'firstName': 'New Name'};
      when(
        () => mockDatabaseService.update(
          location: any(named: 'location'),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => {});

      await userRepository.update('123', updates);

      verify(
        () => mockDatabaseService.update(location: 'users/123', data: updates),
      ).called(1);
    });

    test('delete calls database service delete', () async {
      when(
        () => mockDatabaseService.delete(location: any(named: 'location')),
      ).thenAnswer((_) async => {});

      await userRepository.delete('123');

      verify(() => mockDatabaseService.delete(location: 'users/123')).called(1);
    });
  });
}
