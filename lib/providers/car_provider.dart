import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/car_model.dart';
import '../services/car_service.dart';

final carServiceProvider = Provider<CarService>((ref) => CarService());

final carsProvider = FutureProvider<List<CarModel>>((ref) async {
  final carService = ref.watch(carServiceProvider);
  return carService.getCars();
});

class SelectedCarIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? id) {
    state = id;
  }
}

final selectedCarIdProvider =
    NotifierProvider<SelectedCarIdNotifier, String?>(SelectedCarIdNotifier.new);

final selectedCarProvider = Provider<CarModel?>((ref) {
  final selectedId = ref.watch(selectedCarIdProvider);
  final carsAsync = ref.watch(carsProvider);

  return carsAsync.when(
    data: (cars) {
      if (selectedId == null && cars.isNotEmpty) {
        return cars.first;
      }
      return cars.where((c) => c.id == selectedId).firstOrNull;
    },
    loading: () => null,
    error: (_, _) => null,
  );
});

class CarNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  CarService get _carService => ref.read(carServiceProvider);

  Future<CarModel?> createCar({
    required String brand,
    required String model,
    required int year,
    String? licensePlate,
    required int currentMileage,
    String? image,
  }) async {
    state = const AsyncValue.loading();
    CarModel? result;

    state = await AsyncValue.guard(() async {
      result = await _carService.createCar(
        brand: brand,
        model: model,
        year: year,
        licensePlate: licensePlate,
        currentMileage: currentMileage,
        image: image,
      );
      ref.invalidate(carsProvider);
    });

    return result;
  }

  Future<void> updateCar({
    required String id,
    String? brand,
    String? model,
    int? year,
    String? licensePlate,
    int? currentMileage,
    String? image,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _carService.updateCar(
        id: id,
        brand: brand,
        model: model,
        year: year,
        licensePlate: licensePlate,
        currentMileage: currentMileage,
        image: image,
      );
      ref.invalidate(carsProvider);
    });
  }

  Future<void> deleteCar(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _carService.deleteCar(id);
      ref.invalidate(carsProvider);
    });
  }
}

final carNotifierProvider =
    NotifierProvider<CarNotifier, AsyncValue<void>>(CarNotifier.new);
