import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/car_model.dart';
import 'supabase_service.dart';

class CarService {
  final _client = SupabaseService.client;

  Future<List<CarModel>> getCars() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('cars')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => CarModel.fromJson(e)).toList();
  }

  Future<CarModel?> findByLicensePlate(String licensePlate) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _client
        .from('cars')
        .select()
        .eq('user_id', userId)
        .eq('license_plate', licensePlate)
        .maybeSingle();

    if (response == null) return null;
    return CarModel.fromJson(response);
  }

  Future<CarModel?> getCarById(String id) async {
    final response = await _client
        .from('cars')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return CarModel.fromJson(response);
  }

  Future<CarModel> createCar({
    required String brand,
    required String model,
    required int year,
    String? licensePlate,
    required int currentMileage,
    String? image,
  }) async {
    final userId = _client.auth.currentUser!.id;

    final response = await _client
        .from('cars')
        .insert({
          'user_id': userId,
          'brand': brand,
          'model': model,
          'year': year,
          'license_plate': licensePlate,
          'current_mileage': currentMileage,
          'image': image,
        })
        .select()
        .single();

    return CarModel.fromJson(response);
  }

  Future<CarModel> updateCar({
    required String id,
    String? brand,
    String? model,
    int? year,
    String? licensePlate,
    int? currentMileage,
    String? image,
  }) async {
    final updates = <String, dynamic>{};
    if (brand != null) updates['brand'] = brand;
    if (model != null) updates['model'] = model;
    if (year != null) updates['year'] = year;
    if (licensePlate != null) updates['license_plate'] = licensePlate;
    if (currentMileage != null) updates['current_mileage'] = currentMileage;
    if (image != null) updates['image'] = image;

    final response = await _client
        .from('cars')
        .update(updates)
        .eq('id', id)
        .select()
        .single();

    return CarModel.fromJson(response);
  }

  Future<void> deleteCar(String id) async {
    await _client.from('cars').delete().eq('id', id);
  }

  Future<String?> uploadCarImage(String carId, List<int> imageBytes, String fileName) async {
    final path = '$carId/$fileName';

    await _client.storage.from('cars').uploadBinary(
      path,
      imageBytes as dynamic,
      fileOptions: const FileOptions(upsert: true),
    );

    return _client.storage.from('cars').getPublicUrl(path);
  }
}
