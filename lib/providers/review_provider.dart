import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/garage_review_detail_model.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';

final reviewServiceProvider =
    Provider<ReviewService>((ref) => ReviewService());

final reviewByRecordProvider =
    FutureProvider.family<ReviewModel?, String>((ref, recordId) async {
  final service = ref.watch(reviewServiceProvider);
  return service.getReviewByRecordId(recordId);
});

/// 페이지네이션 상태
class PaginatedReviewsState {
  final List<GarageReviewDetailModel> reviews;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentOffset;

  const PaginatedReviewsState({
    this.reviews = const [],
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentOffset = 0,
  });

  PaginatedReviewsState copyWith({
    List<GarageReviewDetailModel>? reviews,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentOffset,
  }) {
    return PaginatedReviewsState(
      reviews: reviews ?? this.reviews,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentOffset: currentOffset ?? this.currentOffset,
    );
  }
}

const _pageSize = 15;

/// 정비소별 페이지네이션 리뷰 Notifier
class PaginatedGarageReviewsNotifier
    extends AsyncNotifier<PaginatedReviewsState> {
  PaginatedGarageReviewsNotifier(this.garageId);
  final String garageId;

  @override
  Future<PaginatedReviewsState> build() async {
    final service = ref.watch(reviewServiceProvider);
    final reviews =
        await service.getReviewsByGarageId(garageId, limit: _pageSize);
    return PaginatedReviewsState(
      reviews: reviews,
      hasMore: reviews.length >= _pageSize,
      currentOffset: reviews.length,
    );
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.isLoadingMore || !current.hasMore) return;

    state = AsyncValue.data(current.copyWith(isLoadingMore: true));

    try {
      final service = ref.read(reviewServiceProvider);
      final newReviews = await service.getReviewsByGarageId(
        garageId,
        limit: _pageSize,
        offset: current.currentOffset,
      );

      state = AsyncValue.data(current.copyWith(
        reviews: [...current.reviews, ...newReviews],
        isLoadingMore: false,
        hasMore: newReviews.length >= _pageSize,
        currentOffset: current.currentOffset + newReviews.length,
      ));
    } catch (e, st) {
      state = AsyncValue.data(current.copyWith(isLoadingMore: false));
      state = AsyncValue.error(e, st);
    }
  }
}

final paginatedGarageReviewsProvider =
    AsyncNotifierProvider.family<PaginatedGarageReviewsNotifier,
        PaginatedReviewsState, String>(
  PaginatedGarageReviewsNotifier.new,
);
