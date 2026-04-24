import 'package:geolocator/geolocator.dart';
import '../models/location_model.dart';

class LocationService {
  /// Request permissions and get current position
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return null;
    } 

    return await Geolocator.getCurrentPosition();
  }

  /// Convert Position to LocationModel
  LocationModel positionToLocationModel(Position position) {
    return LocationModel(latitude: position.latitude, longitude: position.longitude);
  }

  /// Calculate distance between two points in km
  double calculateDistance(LocationModel start, LocationModel end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    ) / 1000.0; // convert to km
  }
}

