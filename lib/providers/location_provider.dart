import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

final locationServiceProvider =
    Provider<LocationService>((ref) => LocationService());

final currentPositionProvider = FutureProvider<Position>((ref) async {
  final service = ref.watch(locationServiceProvider);
  return service.getCurrentPosition();
});

final currentLocationNameProvider = FutureProvider<String>((ref) async {
  final service = ref.watch(locationServiceProvider);
  final position = await ref.watch(currentPositionProvider.future);
  return service.getAddressFromPosition(position);
});
