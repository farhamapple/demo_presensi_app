import 'package:geolocator/geolocator.dart';
import '../models/office_location_model.dart';

class LocationService {
  static Future<Position?> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      return await Geolocator.getLastKnownPosition();
    }
  }

  static double calculateDistanceMeters({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  static bool isPointInsidePolygon({
    required double latitude,
    required double longitude,
    required List<PolygonCoordinate> polygon,
  }) {
    if (polygon.length < 3) return false;
    bool isInside = false;
    int j = polygon.length - 1;
    for (int i = 0; i < polygon.length; i++) {
      final pi = polygon[i];
      final pj = polygon[j];
      if ((pi.lng > longitude) != (pj.lng > longitude) &&
          (latitude <
              (pj.lat - pi.lat) *
                      (longitude - pi.lng) /
                      (pj.lng - pi.lng) +
                  pi.lat)) {
        isInside = !isInside;
      }
      j = i;
    }
    return isInside;
  }

  static bool isInsideOfficeArea({
    required double userLat,
    required double userLng,
    required OfficeLocationModel office,
  }) {
    if (office.polygonCoordinates.isNotEmpty) {
      final inPoly = isPointInsidePolygon(
        latitude: userLat,
        longitude: userLng,
        polygon: office.polygonCoordinates,
      );
      if (inPoly) return true;
    }

    final distance = calculateDistanceMeters(
      startLatitude: userLat,
      startLongitude: userLng,
      endLatitude: office.latitude,
      endLongitude: office.longitude,
    );

    return distance <= office.radiusMeters;
  }
}

