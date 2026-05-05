import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  // 광화문 좌표 기본값
  static const double defaultLatitude = 37.5759;
  static const double defaultLongitude = 126.9769;

  Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return _defaultPosition();
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return _defaultPosition();
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return _defaultPosition();
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      return _defaultPosition();
    }
  }

  Future<String> getAddressFromPosition(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = <String>[
          if (place.administrativeArea?.isNotEmpty == true) place.administrativeArea!,
          if (place.subAdministrativeArea?.isNotEmpty == true) place.subAdministrativeArea!,
          if (place.locality?.isNotEmpty == true) place.locality!,
          if (place.subLocality?.isNotEmpty == true) place.subLocality!,
        ];
        if (parts.isNotEmpty) return parts.join(' ');
      }
    } catch (_) {
      // ignore geocoding errors
    }
    return '서울특별시 종로구 세종로';
  }

  Position _defaultPosition() {
    return Position(
      latitude: defaultLatitude,
      longitude: defaultLongitude,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }
}
