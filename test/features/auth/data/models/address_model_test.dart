import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/features/auth/data/models/address_model.dart';

void main() {
  group('AddressModel', () {
    const tAddressModel = AddressModel(
      address: '123 Main St',
      latitude: 40.7128,
      longitude: -74.0060,
    );

    group('fromJson', () {
      test('should return a valid model when JSON is provided', () {
        final jsonMap = {
          'address': '123 Main St',
          'latitude': 40.7128,
          'longitude': -74.0060,
        };

        final result = AddressModel.fromJson(jsonMap);

        expect(result.address, tAddressModel.address);
        expect(result.latitude, tAddressModel.latitude);
        expect(result.longitude, tAddressModel.longitude);
      });

      test('should return an empty model when JSON is null/empty', () {
        final jsonMap = <String, dynamic>{};

        final result = AddressModel.fromJson(jsonMap);

        expect(result.address, '');
        expect(result.latitude, 0.0);
        expect(result.longitude, 0.0);
      });
    });

    group('toJson', () {
      test('should return a JSON map containing the proper data', () {
        final result = tAddressModel.toJson();

        expect(result, isA<Map<String, dynamic>>());
        expect(result['address'], '123 Main St');
        expect(result['latitude'], 40.7128);
        expect(result['longitude'], -74.0060);
      });
    });

    group('empty constructor', () {
      test('should create an empty address model', () {
        const empty = AddressModel.empty();

        expect(empty.address, '');
        expect(empty.latitude, 0.0);
        expect(empty.longitude, 0.0);
      });
    });

    group('equality', () {
      test('should be equal when properties match', () {
        const model1 = AddressModel(
          address: '123 Main St',
          latitude: 40.7128,
          longitude: -74.0060,
        );
        const model2 = AddressModel(
          address: '123 Main St',
          latitude: 40.7128,
          longitude: -74.0060,
        );

        expect(model1, equals(model2));
      });

      test('should not be equal when properties differ', () {
        const model1 = AddressModel(
          address: '123 Main St',
          latitude: 40.7128,
          longitude: -74.0060,
        );
        const model2 = AddressModel(
          address: '456 Oak Ave',
          latitude: 40.7128,
          longitude: -74.0060,
        );

        expect(model1, isNot(equals(model2)));
      });
    });

    group('round-trip serialization', () {
      test('should deserialize back to the same model', () {
        final json = tAddressModel.toJson();
        final result = AddressModel.fromJson(json);

        expect(result, equals(tAddressModel));
      });
    });
  });
}
