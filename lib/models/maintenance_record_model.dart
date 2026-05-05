import 'maintenance_item_model.dart';

class MaintenanceRecordModel {
  final String id;
  final String carId;
  final String? garageId;
  final DateTime date;
  final int mileage;
  final int totalCost;
  final String? receiptImage;
  final DateTime createdAt;
  final List<MaintenanceItemModel>? items;
  final String? garageName;
  final String? garageAddress;
  final double? garageRating;
  final String? mechanic;
  final bool hasReview;
  final String? reviewId;

  MaintenanceRecordModel({
    required this.id,
    required this.carId,
    this.garageId,
    required this.date,
    required this.mileage,
    required this.totalCost,
    this.receiptImage,
    required this.createdAt,
    this.items,
    this.garageName,
    this.garageAddress,
    this.garageRating,
    this.mechanic,
    this.hasReview = false,
    this.reviewId,
  });

  factory MaintenanceRecordModel.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    String? reviewId;
    bool hasReview = false;
    final reviews = json['reviews'];
    if (reviews is List && currentUserId != null) {
      for (final r in reviews) {
        if (r['user_id'] == currentUserId) {
          hasReview = true;
          reviewId = r['id'] as String?;
          break;
        }
      }
    }

    return MaintenanceRecordModel(
      id: json['id'] as String,
      carId: json['car_id'] as String,
      garageId: json['garage_id'] as String?,
      date: DateTime.parse(json['date'] as String),
      mileage: json['mileage'] as int,
      totalCost: json['total_cost'] as int,
      receiptImage: json['receipt_image'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      items: json['maintenance_items'] != null
          ? (json['maintenance_items'] as List)
              .map((e) => MaintenanceItemModel.fromJson(e))
              .toList()
          : null,
      garageName: json['garages']?['name'] as String?,
      garageAddress: json['garages']?['address'] as String?,
      garageRating: (json['garages']?['average_rating'] as num?)?.toDouble(),
      mechanic: json['mechanic'] as String?,
      hasReview: hasReview,
      reviewId: reviewId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'car_id': carId,
      'garage_id': garageId,
      'date': date.toIso8601String().split('T')[0],
      'mileage': mileage,
      'total_cost': totalCost,
      'receipt_image': receiptImage,
      'mechanic': mechanic,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'car_id': carId,
      'garage_id': garageId,
      'date': date.toIso8601String().split('T')[0],
      'mileage': mileage,
      'total_cost': totalCost,
      'receipt_image': receiptImage,
      'mechanic': mechanic,
    };
  }

  MaintenanceRecordModel copyWith({
    String? id,
    String? carId,
    String? garageId,
    DateTime? date,
    int? mileage,
    int? totalCost,
    String? receiptImage,
    DateTime? createdAt,
    List<MaintenanceItemModel>? items,
    String? garageName,
    String? garageAddress,
    double? garageRating,
    String? mechanic,
    bool? hasReview,
    String? reviewId,
  }) {
    return MaintenanceRecordModel(
      id: id ?? this.id,
      carId: carId ?? this.carId,
      garageId: garageId ?? this.garageId,
      date: date ?? this.date,
      mileage: mileage ?? this.mileage,
      totalCost: totalCost ?? this.totalCost,
      receiptImage: receiptImage ?? this.receiptImage,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
      garageName: garageName ?? this.garageName,
      garageAddress: garageAddress ?? this.garageAddress,
      garageRating: garageRating ?? this.garageRating,
      mechanic: mechanic ?? this.mechanic,
      hasReview: hasReview ?? this.hasReview,
      reviewId: reviewId ?? this.reviewId,
    );
  }
}
