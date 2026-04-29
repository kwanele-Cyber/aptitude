import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/core/data/models/user.dart';
import 'package:myapp/core/data/models/location_model.dart';

void main() {
  group('User Model Schema Tests', () {
    test('toJson and fromJson should correctly handle profile metadata', () {
      final location = AddressModel(
        address: '123 Test St',
        latitude: -26.123,
        longitude: 28.456,
      );

      final user = User(
        uid: 'user123',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        title: 'Mentor',
        photoURL: 'https://photo.com/1',
        skills: ['Flutter', 'Python'],
        interests: ['Music', 'Art'],
        bio: 'Hello world',
        location: location,
        profileComplete: true,
        createdAt: DateTime(2026, 1, 1),
      );

      final json = user.toJson();

      expect(json['firstName'], 'John');
      expect(json['location']['latitude'], -26.123);
      expect(json['skills'], contains('Flutter'));

      final recovered = User.fromJson(json);
      expect(recovered.displayName, 'John Doe');
      expect(recovered.location.latitude, -26.123);
      expect(recovered.skills.length, 2);
    });

    test('fromJson should handle legacy string locations gracefully', () {
      final json = {
        'uid': 'u1',
        'location': 'Cape Town, South Africa',
      };

      final user = User.fromJson(json);
      
      expect(user.location.address, 'Cape Town, South Africa');
      expect(user.location.latitude, 0);
    });
  });
}
