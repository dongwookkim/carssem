import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/maintenance_record_model.dart';
import 'supabase_service.dart';

class MaintenanceService {
  final _client = SupabaseService.client;

  String? get _currentUserId => _client.auth.currentUser?.id;

  Future<List<MaintenanceRecordModel>> getRecordsByCarId(String carId) async {
    final response = await _client
        .from('maintenance_records')
        .select('''
          *,
          maintenance_items (*),
          garages (name, address, average_rating),
          reviews (id, user_id)
        ''')
        .eq('car_id', carId)
        .order('date', ascending: false);

    final userId = _currentUserId;
    return (response as List)
        .map((e) => MaintenanceRecordModel.fromJson(e, currentUserId: userId))
        .toList();
  }

  Future<List<MaintenanceRecordModel>> getRecentRecords({int limit = 5}) async {
    final userId = _currentUserId;
    if (userId == null) return [];

    final response = await _client
        .from('maintenance_records')
        .select('''
          *,
          maintenance_items (*),
          garages (name, address, average_rating),
          reviews (id, user_id),
          cars!inner (user_id)
        ''')
        .eq('cars.user_id', userId)
        .order('date', ascending: false)
        .limit(limit);

    return (response as List)
        .map((e) => MaintenanceRecordModel.fromJson(e, currentUserId: userId))
        .toList();
  }

  Future<MaintenanceRecordModel?> getRecordById(String id) async {
    final response = await _client
        .from('maintenance_records')
        .select('''
          *,
          maintenance_items (*),
          garages (name, address, average_rating),
          reviews (id, user_id)
        ''')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return MaintenanceRecordModel.fromJson(response, currentUserId: _currentUserId);
  }

  Future<MaintenanceRecordModel> createRecord({
    required String carId,
    String? garageId,
    required DateTime date,
    required int mileage,
    required int totalCost,
    String? receiptImage,
    String? mechanic,
    required List<MaintenanceItemInput> items,
  }) async {
    final recordResponse = await _client
        .from('maintenance_records')
        .insert({
          'car_id': carId,
          'garage_id': garageId,
          'date': date.toIso8601String().split('T')[0],
          'mileage': mileage,
          'total_cost': totalCost,
          'receipt_image': receiptImage,
          'mechanic': mechanic,
        })
        .select()
        .single();

    final recordId = recordResponse['id'] as String;

    if (items.isNotEmpty) {
      final itemsData = items.map((item) => {
        'record_id': recordId,
        'system': item.system,
        'category': item.category,
        'name': item.name,
        'description': item.description,
        'role': item.role,
        'reason': item.reason,
        'quantity': item.quantity,
        'unit_price': item.unitPrice,
        'total_price': item.totalPrice,
      }).toList();

      await _client.from('maintenance_items').insert(itemsData);
    }

    return (await getRecordById(recordId))!;
  }

  Future<void> deleteRecord(String id) async {
    await _client.from('maintenance_items').delete().eq('record_id', id);
    await _client.from('maintenance_records').delete().eq('id', id);
  }

  Future<String?> uploadReceiptImage(
    String recordId,
    List<int> imageBytes,
    String fileName,
  ) async {
    final path = '$recordId/$fileName';

    await _client.storage.from('receipts').uploadBinary(
      path,
      imageBytes as dynamic,
      fileOptions: const FileOptions(upsert: true),
    );

    return _client.storage.from('receipts').getPublicUrl(path);
  }
}

class MaintenanceItemInput {
  final String? system;
  final String category;
  final String name;
  final String? description;
  final String? role;
  final String? reason;
  final int quantity;
  final int unitPrice;
  final int totalPrice;

  MaintenanceItemInput({
    this.system,
    required this.category,
    required this.name,
    this.description,
    this.role,
    this.reason,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });
}
