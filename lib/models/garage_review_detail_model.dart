import 'maintenance_item_model.dart';

class GarageReviewDetailModel {
  final String id;
  final String garageId;
  final String userId;
  final String? recordId;
  final int rating;
  final String? content;
  final DateTime createdAt;
  final String? userName;
  final String? carBrand;
  final String? carModel;
  final int? carYear;
  final DateTime? maintenanceDate;
  final int? mileage;
  final int? totalCost;
  final List<MaintenanceItemModel>? items;

  GarageReviewDetailModel({
    required this.id,
    required this.garageId,
    required this.userId,
    this.recordId,
    required this.rating,
    this.content,
    required this.createdAt,
    this.userName,
    this.carBrand,
    this.carModel,
    this.carYear,
    this.maintenanceDate,
    this.mileage,
    this.totalCost,
    this.items,
  });

  String get carDisplayName {
    if (carBrand != null && carModel != null) {
      return '$carBrand $carModel';
    }
    return '';
  }

  factory GarageReviewDetailModel.fromJson(Map<String, dynamic> json) {
    final record = json['maintenance_records'] as Map<String, dynamic>?;
    final car = record?['cars'] as Map<String, dynamic>?;
    final itemsList = record?['maintenance_items'] as List?;

    return GarageReviewDetailModel(
      id: json['id'] as String,
      garageId: json['garage_id'] as String,
      userId: json['user_id'] as String,
      recordId: json['record_id'] as String?,
      rating: json['rating'] as int,
      content: json['content'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      userName: json['users']?['name'] as String?,
      carBrand: car?['brand'] as String?,
      carModel: car?['model'] as String?,
      carYear: car?['year'] as int?,
      maintenanceDate:
          record?['date'] != null ? DateTime.parse(record!['date'] as String) : null,
      mileage: record?['mileage'] as int?,
      totalCost: record?['total_cost'] as int?,
      items: itemsList
          ?.map((e) => MaintenanceItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
