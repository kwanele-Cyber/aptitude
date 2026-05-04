import 'package:myapp/features/auth/domain/entity/location_entity.dart';

class AddressModel extends LocationEntity {
  const AddressModel({
    required super.address,
    required super.latitude,
    required super.longitude,
  });

  const AddressModel.empty()
      : super(address: '', latitude: 0.0, longitude: 0.0);

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      address: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num? ?? 0.0).toDouble(),
      longitude: (json['longitude'] as num? ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
