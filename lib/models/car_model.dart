class CarModel {
  final String id;
  final String userId;
  final String brand;
  final String model;
  final int year;
  final String? licensePlate;
  final int currentMileage;
  final String? image;
  final DateTime createdAt;

  CarModel({
    required this.id,
    required this.userId,
    required this.brand,
    required this.model,
    required this.year,
    this.licensePlate,
    required this.currentMileage,
    this.image,
    required this.createdAt,
  });

  String get displayName => '$brand $model';

  String get displayYear => '$year년식';

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      licensePlate: json['license_plate'] as String?,
      currentMileage: json['current_mileage'] as int,
      image: json['image'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'brand': brand,
      'model': model,
      'year': year,
      'license_plate': licensePlate,
      'current_mileage': currentMileage,
      'image': image,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'brand': brand,
      'model': model,
      'year': year,
      'license_plate': licensePlate,
      'current_mileage': currentMileage,
      'image': image,
    };
  }

  CarModel copyWith({
    String? id,
    String? userId,
    String? brand,
    String? model,
    int? year,
    String? licensePlate,
    int? currentMileage,
    String? image,
    DateTime? createdAt,
  }) {
    return CarModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      licensePlate: licensePlate ?? this.licensePlate,
      currentMileage: currentMileage ?? this.currentMileage,
      image: image ?? this.image,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
