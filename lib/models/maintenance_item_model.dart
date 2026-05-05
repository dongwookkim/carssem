class MaintenanceItemModel {
  final String id;
  final String recordId;
  final String? system;
  final String category;
  final String name;
  final String? description;
  final String? role;
  final String? reason;
  final int quantity;
  final int unitPrice;
  final int totalPrice;

  MaintenanceItemModel({
    required this.id,
    required this.recordId,
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

  factory MaintenanceItemModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceItemModel(
      id: json['id'] as String,
      recordId: json['record_id'] as String,
      system: json['system'] as String?,
      category: json['category'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      role: json['role'] as String?,
      reason: json['reason'] as String?,
      quantity: json['quantity'] as int,
      unitPrice: json['unit_price'] as int,
      totalPrice: json['total_price'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'record_id': recordId,
      'system': system,
      'category': category,
      'name': name,
      'description': description,
      'role': role,
      'reason': reason,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'record_id': recordId,
      'system': system,
      'category': category,
      'name': name,
      'description': description,
      'role': role,
      'reason': reason,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
    };
  }

  MaintenanceItemModel copyWith({
    String? id,
    String? recordId,
    String? system,
    String? category,
    String? name,
    String? description,
    String? role,
    String? reason,
    int? quantity,
    int? unitPrice,
    int? totalPrice,
  }) {
    return MaintenanceItemModel(
      id: id ?? this.id,
      recordId: recordId ?? this.recordId,
      system: system ?? this.system,
      category: category ?? this.category,
      name: name ?? this.name,
      description: description ?? this.description,
      role: role ?? this.role,
      reason: reason ?? this.reason,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}
