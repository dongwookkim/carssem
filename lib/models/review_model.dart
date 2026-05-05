class ReviewModel {
  final String id;
  final String garageId;
  final String userId;
  final String? recordId;
  final int rating;
  final String? content;
  final DateTime createdAt;
  final String? userName;

  ReviewModel({
    required this.id,
    required this.garageId,
    required this.userId,
    this.recordId,
    required this.rating,
    this.content,
    required this.createdAt,
    this.userName,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      garageId: json['garage_id'] as String,
      userId: json['user_id'] as String,
      recordId: json['record_id'] as String?,
      rating: json['rating'] as int,
      content: json['content'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      userName: json['users']?['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'garage_id': garageId,
      'user_id': userId,
      'record_id': recordId,
      'rating': rating,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'garage_id': garageId,
      'user_id': userId,
      'record_id': recordId,
      'rating': rating,
      'content': content,
    };
  }

  ReviewModel copyWith({
    String? id,
    String? garageId,
    String? userId,
    String? recordId,
    int? rating,
    String? content,
    DateTime? createdAt,
    String? userName,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      garageId: garageId ?? this.garageId,
      userId: userId ?? this.userId,
      recordId: recordId ?? this.recordId,
      rating: rating ?? this.rating,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      userName: userName ?? this.userName,
    );
  }
}
