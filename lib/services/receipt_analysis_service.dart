import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/app_constants.dart';
import 'supabase_service.dart';

class ReceiptAnalysisService {
  final _client = SupabaseService.client;

  Future<ReceiptAnalysisResult> analyzeReceipt(Uint8List imageBytes, String fileName) async {
    // 1. Upload image to Storage
    final userId = _client.auth.currentUser!.id;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = '$userId/$timestamp-$fileName';

    await _client.storage.from(AppConstants.receiptsBucket).uploadBinary(
      path,
      imageBytes,
      fileOptions: const FileOptions(upsert: true),
    );

    final imageUrl = _client.storage
        .from(AppConstants.receiptsBucket)
        .getPublicUrl(path);

    // 2. Call Edge Function
    final response = await _client.functions.invoke(
      AppConstants.analyzeReceiptFunction,
      body: {'imageUrl': imageUrl},
    );

    if (response.status != 200) {
      throw Exception('Failed to analyze receipt: ${response.data}');
    }

    // 3. Parse response
    final data = response.data as Map<String, dynamic>;

    return ReceiptAnalysisResult(
      imageUrl: imageUrl,
      date: _parseDate(data['date']),
      garageName: data['garage_name'] as String?,
      garageAddress: data['garage_address'] as String?,
      mechanic: data['mechanic'] as String?,
      mileage: data['mileage'] as int? ?? 0,
      items: _parseItems(data['items']),
      totalCost: data['total_cost'] as int? ?? 0,
      carBrand: data['car_brand'] as String?,
      carModel: data['car_model'] as String?,
      carYear: data['car_year'] as int?,
      licensePlate: data['license_plate'] as String?,
    );
  }

  DateTime _parseDate(dynamic dateStr) {
    if (dateStr == null) return DateTime.now();
    try {
      return DateTime.parse(dateStr as String);
    } catch (_) {
      return DateTime.now();
    }
  }

  List<AnalyzedItem> _parseItems(dynamic itemsData) {
    if (itemsData == null) return [];

    final items = itemsData as List;
    return items.map((item) {
      return AnalyzedItem(
        system: item['system'] as String? ?? '기타 정비',
        category: item['category'] as String? ?? '기타',
        name: item['name'] as String? ?? '',
        description: item['description'] as String?,
        role: item['role'] as String?,
        reason: item['reason'] as String?,
        quantity: item['quantity'] as int? ?? 1,
        unitPrice: item['unit_price'] as int? ?? 0,
        totalPrice: item['total_price'] as int? ?? 0,
      );
    }).toList();
  }
}

class ReceiptAnalysisResult {
  final String imageUrl;
  final DateTime date;
  final String? garageName;
  final String? garageAddress;
  final String? mechanic;
  final int mileage;
  final List<AnalyzedItem> items;
  final int totalCost;
  final String? carBrand;
  final String? carModel;
  final int? carYear;
  final String? licensePlate;

  ReceiptAnalysisResult({
    required this.imageUrl,
    required this.date,
    this.garageName,
    this.garageAddress,
    this.mechanic,
    required this.mileage,
    required this.items,
    required this.totalCost,
    this.carBrand,
    this.carModel,
    this.carYear,
    this.licensePlate,
  });
}

class AnalyzedItem {
  final String system;
  final String category;
  final String name;
  final String? description;
  final String? role;
  final String? reason;
  final int quantity;
  final int unitPrice;
  final int totalPrice;

  AnalyzedItem({
    required this.system,
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
