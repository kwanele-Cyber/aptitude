class AddressModel {
  final String address;
  final double latitude;
  final double longitude;

  AddressModel({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory AddressModel.fromJson(Map<dynamic, dynamic> json) {
    return AddressModel(
      address: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num? ?? 0.0).toDouble(),
      longitude: (json['longitude'] as num? ?? 0.0).toDouble(),
    );
  }

  factory AddressModel.empty() {
    return AddressModel(address: '', latitude: 0.0, longitude: 0.0);
  }

  get isNotEmpty => null;
}