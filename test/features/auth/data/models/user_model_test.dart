import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/features/auth/data/models/address_model.dart';
import 'package:myapp/features/auth/data/models/user_model.dart';
import 'package:myapp/features/auth/domain/entity/user_role.dart';

void main() {
  group('UserModel.fromJson with seed-shaped data', () {
    /// Simulates what Firebase RTDB returns after [Map<String, dynamic>.from] conversion.
    /// The [Map<Object?, Object?>] raw source mimics RTDB's LinkedMap type.
    Map<String, dynamic> createSeedLikeMap() {
      final raw = <Object?, Object?>{
        'uid': 'test-uid-123',
        'email': 'admin@aptitude.test',
        'firstName': 'Alex',
        'lastName': 'Admin',
        'title': 'Platform Administrator',
        'photoURL': '',
        'skills': <Object?>['System Architecture', 'Code Review', 'Team Leadership'],
        'interests': <Object?>['Technology', 'Mentorship', 'Open Source'],
        'bio': 'Platform administrator and community manager.',
        'location': <Object?, Object?>{
          'address': 'San Francisco, CA',
          'latitude': 37.7749,
          'longitude': -122.4194,
        },
        'phone': null,
        'profileComplete': true,
        'twoFactorEnabled': false,
        'twoFactorPin': null,
        'trustScore': 85.0,
        'isVerified': true,
        'role': 'admin',
        'updatedAt': '2026-05-05T14:30:00.000',
        'createdAt': '2026-05-05T14:30:00.000',
      };
      return Map<String, dynamic>.from(raw);
    }

    test('parses all fields correctly from seed-shaped data', () {
      final json = createSeedLikeMap();
      final model = UserModel.fromJson(json);

      expect(model.id, 'test-uid-123');
      expect(model.email, 'admin@aptitude.test');
      expect(model.firstName, 'Alex');
      expect(model.lastName, 'Admin');
      expect(model.title, 'Platform Administrator');
      expect(model.photoURL, '');
      expect(model.skills, ['System Architecture', 'Code Review', 'Team Leadership']);
      expect(model.interests, ['Technology', 'Mentorship', 'Open Source']);
      expect(model.bio, 'Platform administrator and community manager.');
      expect(model.phone, isNull);
      expect(model.profileComplete, isTrue);
      expect(model.twoFactorEnabled, isFalse);
      expect(model.twoFactorPin, isNull);
      expect(model.trustScore, 85.0);
      expect(model.isVerified, isTrue);
      expect(model.name, 'Alex Admin');
    });

    test('parses role as admin correctly', () {
      final json = createSeedLikeMap();
      final model = UserModel.fromJson(json);

      expect(model.role, 'admin');
      expect(model.userRole, UserRole.admin);
      expect(model.isAdmin, isTrue);
    });

    test('parses role as member correctly', () {
      final json = createSeedLikeMap();
      json['role'] = 'member';
      final model = UserModel.fromJson(json);

      expect(model.role, 'member');
      expect(model.userRole, UserRole.member);
      expect(model.isAdmin, isFalse);
    });

    test('defaults to member role when role is missing', () {
      final json = createSeedLikeMap();
      json.remove('role');
      final model = UserModel.fromJson(json);

      expect(model.role, 'member');
      expect(model.userRole, UserRole.member);
      expect(model.isAdmin, isFalse);
    });

    test('parses nested location correctly from Map<Object?, Object?>', () {
      final json = createSeedLikeMap();
      final model = UserModel.fromJson(json);

      expect(model.location, isA<AddressModel>());
      expect(model.location.address, 'San Francisco, CA');
      expect(model.location.latitude, 37.7749);
      expect(model.location.longitude, -122.4194);
    });

    test('handles null location gracefully', () {
      final json = createSeedLikeMap();
      json['location'] = null;
      final model = UserModel.fromJson(json);

      expect(model.location.address, '');
      expect(model.location.latitude, 0.0);
      expect(model.location.longitude, 0.0);
    });

    test('parses timestamps correctly', () {
      final json = createSeedLikeMap();
      final model = UserModel.fromJson(json);

      expect(model.updatedAt, isA<DateTime>());
      expect(model.createdAt, isA<DateTime>());
      expect(model.updatedAt!.toIso8601String(), '2026-05-05T14:30:00.000');
      expect(model.createdAt!.toIso8601String(), '2026-05-05T14:30:00.000');
    });

    test('handles null timestamps gracefully', () {
      final json = createSeedLikeMap();
      json['updatedAt'] = null;
      json['createdAt'] = null;
      final model = UserModel.fromJson(json);

      expect(model.updatedAt, isNull);
      expect(model.createdAt, isA<DateTime>());
    });

    test('handles List<Object?> from RTDB for skills and interests', () {
      final json = createSeedLikeMap();
      json['skills'] = <Object?>['Flutter', 'Dart', 'Firebase'];
      json['interests'] = <Object?>['Coding', 'Teaching'];
      final model = UserModel.fromJson(json);

      expect(model.skills, ['Flutter', 'Dart', 'Firebase']);
      expect(model.interests, ['Coding', 'Teaching']);
    });

    test('handles missing skills and interests', () {
      final json = createSeedLikeMap();
      json.remove('skills');
      json.remove('interests');
      final model = UserModel.fromJson(json);

      expect(model.skills, isEmpty);
      expect(model.interests, isEmpty);
    });

    test('handles empty JSON gracefully', () {
      final model = UserModel.fromJson(<String, dynamic>{});

      expect(model.id, '');
      expect(model.email, '');
      expect(model.firstName, '');
      expect(model.lastName, '');
      expect(model.title, '');
      expect(model.photoURL, '');
      expect(model.skills, isEmpty);
      expect(model.interests, isEmpty);
      expect(model.bio, '');
      expect(model.phone, isNull);
      expect(model.profileComplete, isFalse);
      expect(model.twoFactorEnabled, isFalse);
      expect(model.twoFactorPin, isNull);
      expect(model.trustScore, 0.0);
      expect(model.isVerified, isFalse);
      expect(model.role, 'member');
      expect(model.userRole, UserRole.member);
      expect(model.isAdmin, isFalse);
      expect(model.createdAt, isA<DateTime>());
    });
  });

  group('UserModel.toJson round-trip', () {
    test('produces JSON that can be round-tripped through fromJson', () {
      final original = UserModel(
        id: 'rt-uid',
        firstName: 'Round',
        lastName: 'Trip',
        email: 'round.trip@test.com',
        title: 'Tester',
        photoURL: 'https://example.com/photo.jpg',
        skills: ['Testing', 'Dart'],
        interests: ['Music'],
        bio: 'A test user for round-trip',
        location: const AddressModel(
          address: '456 Oak Ave',
          latitude: 40.7128,
          longitude: -74.0060,
        ),
        phone: '555-0100',
        profileComplete: true,
        twoFactorEnabled: true,
        twoFactorPin: '1234',
        trustScore: 95.0,
        isVerified: true,
        role: 'member',
        createdAt: DateTime(2026, 3, 15, 10, 30),
        updatedAt: DateTime(2026, 3, 15, 10, 30),
      );

      final json = original.toJson();
      final decoded = UserModel.fromJson(json);

      expect(decoded.id, original.id);
      expect(decoded.email, original.email);
      expect(decoded.firstName, original.firstName);
      expect(decoded.lastName, original.lastName);
      expect(decoded.title, original.title);
      expect(decoded.photoURL, original.photoURL);
      expect(decoded.skills, original.skills);
      expect(decoded.interests, original.interests);
      expect(decoded.bio, original.bio);
      expect(decoded.location.address, original.location.address);
      expect(decoded.location.latitude, original.location.latitude);
      expect(decoded.location.longitude, original.location.longitude);
      expect(decoded.phone, original.phone);
      expect(decoded.profileComplete, original.profileComplete);
      expect(decoded.twoFactorEnabled, original.twoFactorEnabled);
      expect(decoded.twoFactorPin, original.twoFactorPin);
      expect(decoded.trustScore, original.trustScore);
      expect(decoded.isVerified, original.isVerified);
      expect(decoded.role, original.role);
    });
  });
}
