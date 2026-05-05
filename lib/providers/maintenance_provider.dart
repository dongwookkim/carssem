import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/maintenance_record_model.dart';
import '../services/maintenance_service.dart';

final maintenanceServiceProvider =
    Provider<MaintenanceService>((ref) => MaintenanceService());

final maintenanceRecordsProvider =
    FutureProvider.family<List<MaintenanceRecordModel>, String>(
        (ref, carId) async {
  final service = ref.watch(maintenanceServiceProvider);
  return service.getRecordsByCarId(carId);
});

final recentMaintenanceProvider =
    FutureProvider<List<MaintenanceRecordModel>>((ref) async {
  final service = ref.watch(maintenanceServiceProvider);
  return service.getRecentRecords(limit: 5);
});

final maintenanceDetailProvider =
    FutureProvider.family<MaintenanceRecordModel?, String>((ref, id) async {
  final service = ref.watch(maintenanceServiceProvider);
  return service.getRecordById(id);
});

class MaintenanceNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  MaintenanceService get _service => ref.read(maintenanceServiceProvider);

  Future<MaintenanceRecordModel?> createRecord({
    required String carId,
    String? garageId,
    required DateTime date,
    required int mileage,
    required int totalCost,
    String? receiptImage,
    String? mechanic,
    required List<MaintenanceItemInput> items,
  }) async {
    state = const AsyncValue.loading();
    MaintenanceRecordModel? result;

    state = await AsyncValue.guard(() async {
      result = await _service.createRecord(
        carId: carId,
        garageId: garageId,
        date: date,
        mileage: mileage,
        totalCost: totalCost,
        receiptImage: receiptImage,
        mechanic: mechanic,
        items: items,
      );
      ref.invalidate(maintenanceRecordsProvider(carId));
      ref.invalidate(recentMaintenanceProvider);
    });

    return result;
  }

  Future<void> deleteRecord(String id, String carId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.deleteRecord(id);
      ref.invalidate(maintenanceRecordsProvider(carId));
      ref.invalidate(recentMaintenanceProvider);
    });
  }
}

final maintenanceNotifierProvider =
    NotifierProvider<MaintenanceNotifier, AsyncValue<void>>(
        MaintenanceNotifier.new);
