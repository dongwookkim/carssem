import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/garage_review_detail_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/garage_provider.dart';
import '../../../providers/review_provider.dart';
import '../widgets/star_rating_widget.dart';

class GarageDetailScreen extends ConsumerStatefulWidget {
  final String garageId;

  const GarageDetailScreen({super.key, required this.garageId});

  @override
  ConsumerState<GarageDetailScreen> createState() => _GarageDetailScreenState();
}

class _GarageDetailScreenState extends ConsumerState<GarageDetailScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref
          .read(paginatedGarageReviewsProvider(widget.garageId).notifier)
          .loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final garageAsync = ref.watch(garageDetailProvider(widget.garageId));
    final reviewsAsync =
        ref.watch(paginatedGarageReviewsProvider(widget.garageId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('정비소'),
      ),
      body: garageAsync.when(
        data: (garage) {
          if (garage == null) {
            return const Center(child: Text('정비소를 찾을 수 없습니다'));
          }

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // 정비소 정보 헤더
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        garage.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      if (garage.address != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          garage.address!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          StarRatingWidget(rating: garage.averageRating),
                          const SizedBox(width: 8),
                          Text(
                            '${garage.reviewCount}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: Divider(height: 1)),

              // 리뷰 목록
              reviewsAsync.when(
                data: (paginatedState) {
                  final reviews = paginatedState.reviews;
                  if (reviews.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            '아직 리뷰가 없습니다',
                            style:
                                TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index < reviews.length) {
                          return Column(
                            children: [
                              _ReviewCard(review: reviews[index]),
                              if (index < reviews.length - 1)
                                const Divider(
                                    height: 1, indent: 16, endIndent: 16),
                            ],
                          );
                        }
                        // Loading indicator at the bottom
                        if (paginatedState.isLoadingMore) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child:
                                Center(child: CircularProgressIndicator()),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      childCount:
                          reviews.length + (paginatedState.isLoadingMore ? 1 : 0),
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (e, _) => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text('리뷰 로딩 오류: $e',
                          style: const TextStyle(color: AppColors.error)),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('오류: $e',
              style: const TextStyle(color: AppColors.error)),
        ),
      ),
    );
  }
}

class _ReviewCard extends ConsumerStatefulWidget {
  final GarageReviewDetailModel review;

  const _ReviewCard({required this.review});

  @override
  ConsumerState<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends ConsumerState<_ReviewCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final review = widget.review;
    final currentUser = ref.watch(currentUserProvider);
    final isMyReview = currentUser?.id == review.userId;
    final dateFormat = DateFormat('yyyy년 M월 d일');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 날짜
          if (review.maintenanceDate != null)
            Text(
              dateFormat.format(review.maintenanceDate!),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),

          // 차종
          if (review.carDisplayName.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              review.carDisplayName,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
            ),
          ],

          // 별점
          const SizedBox(height: 6),
          StarRatingWidget(
            rating: review.rating.toDouble(),
            size: 18,
            filledColor: isMyReview ? AppColors.primary : null,
          ),

          // 리뷰 내용
          if (review.content != null && review.content!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '"${review.content!}"',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ],

          // 정비내역 토글
          if (review.items != null && review.items!.isNotEmpty) ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Row(
                children: [
                  Icon(
                    _expanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '정비내역',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // 정비내역 펼침
            if (_expanded) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 헤더: 주행거리 + 닫기 버튼
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (review.mileage != null)
                          Text(
                            '${NumberFormat('#,###').format(review.mileage)} km',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        InkWell(
                          onTap: () => setState(() => _expanded = false),
                          child: const Icon(Icons.close,
                              size: 18, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // 정비 항목 리스트
                    ...review.items!.asMap().entries.map((entry) {
                      final i = entry.key;
                      final item = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '${i + 1}. ${item.category} - ${item.name}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      );
                    }),
                    if (review.totalCost != null) ...[
                      const SizedBox(height: 4),
                      const Divider(height: 1),
                      const SizedBox(height: 4),
                      Text(
                        '총계: ${NumberFormat('#,###').format(review.totalCost)}원',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
