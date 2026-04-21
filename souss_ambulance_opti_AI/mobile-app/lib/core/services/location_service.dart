import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'api_service.dart';

class LocationService {
  static StreamSubscription<Position>? _positionStream;

  // Start tracking location for patient or driver
  static void startTracking({
    required int userId,
    required String userType, // 'patient' or 'driver'
  }) {
    // Update immediately
    _updateLocation(userId, userType);

    // Then update every 10 seconds when position changes
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen((Position position) {
      _sendToServer(
        userId: userId,
        userType: userType,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    });
  }

  // Stop tracking
  static void stopTracking() {
    _positionStream?.cancel();
    _positionStream = null;
  }

  // Get current position and update once
  static Future<void> _updateLocation(int userId, String userType) async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      await _sendToServer(
        userId: userId,
        userType: userType,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  // Send location to server
  static Future<void> _sendToServer({
    required int userId,
    required String userType,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await ApiService.post('update_location', {
        'user_id': userId,
        'user_type': userType,
        'latitude': latitude,
        'longitude': longitude,
      });
      print('Location updated: $latitude, $longitude');
    } catch (e) {
      print('Error sending location: $e');
    }
  }

  // Get distance between two coordinates (for finding nearest driver/hospital)
  static double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }
}