import 'package:flutter/foundation.dart';
import '../models/garage_review_detail_model.dart';
import '../models/review_model.dart';
import 'supabase_service.dart';

class ReviewService {
  final _client = SupabaseService.client;

  /// 특정 정비 기록에 대한 리뷰 조회
  Future<ReviewModel?> getReviewByRecordId(String recordId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _client
        .from('reviews')
        .select()
        .eq('record_id', recordId)
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) return null;
    return ReviewModel.fromJson(response);
  }

  /// 리뷰 생성
  Future<ReviewModel> createReview({
    required String garageId,
    required String recordId,
    required int rating,
    String? content,
  }) async {
    final userId = _client.auth.currentUser!.id;

    final response = await _client
        .from('reviews')
        .insert({
          'garage_id': garageId,
          'user_id': userId,
          'record_id': recordId,
          'rating': rating,
          'content': content,
        })
        .select()
        .single();

    return ReviewModel.fromJson(response);
  }

  /// 리뷰 수정
  Future<void> updateReview({
    required String reviewId,
    required String garageId,
    required int rating,
    String? content,
  }) async {
    await _client.from('reviews').update({
      'rating': rating,
      'content': content,
    }).eq('id', reviewId);
  }

  /// 리뷰 삭제
  Future<void> deleteReview(String reviewId, String garageId) async {
    await _client.from('reviews').delete().eq('id', reviewId);
  }

  /// 정비소의 리뷰 목록 (차량/정비내역 포함, 페이지네이션)
  Future<List<GarageReviewDetailModel>> getReviewsByGarageId(
    String garageId, {
    int limit = 15,
    int offset = 0,
  }) async {
    try {
      final response = await _client
          .from('reviews')
          .select('''
            *,
            users (name),
            maintenance_records (
              date, mileage, total_cost,
              cars (brand, model, year),
              maintenance_items (*)
            )
          ''')
          .eq('garage_id', garageId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      debugPrint('[ReviewService] garageId=$garageId, count=${(response as List).length}');
      return response
          .map((e) => GarageReviewDetailModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[ReviewService] getReviewsByGarageId error: $e');
      rethrow;
    }
  }

}
