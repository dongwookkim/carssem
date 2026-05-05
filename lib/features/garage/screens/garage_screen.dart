import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/garage_provider.dart';
import '../../../providers/location_provider.dart';
import '../../../providers/region_provider.dart';
import '../widgets/garage_card.dart';
import '../widgets/star_rating_widget.dart';

class GarageScreen extends ConsumerWidget {
  const GarageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final garagesAsync = ref.watch(garagesProvider);
    final userGarageIdsAsync = ref.watch(userGarageIdsProvider);
    final ratingFilter = ref.watch(garageRatingFilterProvider);
    final distributionAsync = ref.watch(garageRatingDistributionProvider);
    final locationDisplay = ref.watch(locationDisplayProvider);
    final isGpsMode = ref.watch(addressFilterProvider) == null;

    return Scaffold(
      body: SafeArea(
        child: Column(
        children: [
          // 위치 바
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.only(right: 14),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                // 현재위치 버튼
                GestureDetector(
                  onTap: () {
                    ref.read(addressFilterProvider.notifier).clear();
                    ref.invalidate(currentPositionProvider);
                    ref.invalidate(currentLocationNameProvider);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: Icon(Icons.my_location,
                        size: 18,
                        color: isGpsMode
                            ? AppColors.primary
                            : AppColors.textSecondary),
                  ),
                ),
                // 주소 텍스트 (탭 → 지역 검색)
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.push('/region-search'),
                    child: Text(
                      locationDisplay,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 검색 버튼
                GestureDetector(
                  onTap: () => context.push('/region-search'),
                  child: Icon(Icons.search,
                      size: 18, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          // 별점 필터
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Row(
              children: [
                distributionAsync.when(
                  data: (dist) => PopupMenuButton<int?>(
                    onSelected: (value) {
                      ref
                          .read(garageRatingFilterProvider.notifier)
                          .set(value);
                    },
                    offset: const Offset(0, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: null,
                        child: Text('전체 (${dist[0] ?? 0})'),
                      ),
                      for (int star = 5; star >= 1; star--)
                        PopupMenuItem(
                          value: star,
                          child: Row(
                            children: [
                              StarRatingWidget(
                                  rating: star.toDouble(), size: 14),
                              const SizedBox(width: 8),
                              Text(
                                '${dist[star] ?? 0}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StarRatingWidget(
                          rating: ratingFilter?.toDouble() ?? 4,
                          size: 16,
                        ),
                        const SizedBox(width: 2),
                        Icon(Icons.arrow_drop_down,
                            size: 20, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // 정비소 리스트
          Expanded(
            child: garagesAsync.when(
              data: (garages) {
                if (garages.isEmpty) {
                  return const Center(
                    child: Text(
                      '정비소가 없습니다',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }

                final userGarageIds = userGarageIdsAsync.when(
                  data: (ids) => ids,
                  loading: () => <String>{},
                  error: (_, _) => <String>{},
                );

                // 내 정비소를 상단에 배치
                final myGarages = garages
                    .where((g) => userGarageIds.contains(g.id))
                    .toList();
                final otherGarages = garages
                    .where((g) => !userGarageIds.contains(g.id))
                    .toList();
                final sorted = [...myGarages, ...otherGarages];

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(garagesProvider);
                    ref.invalidate(userGarageIdsProvider);
                    ref.invalidate(garageRatingDistributionProvider);
                  },
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: sorted.length,
                    separatorBuilder: (_, _) => const Divider(
                      height: 1,
                      indent: 20,
                      endIndent: 20,
                    ),
                    itemBuilder: (context, index) {
                      final garage = sorted[index];
                      final isMyGarage = userGarageIds.contains(garage.id);
                      return GarageCard(
                        garage: garage,
                        isMyGarage: isMyGarage,
                        onTap: () => context.push('/garage/${garage.id}'),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('오류: $e',
                    style: const TextStyle(color: AppColors.error)),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
