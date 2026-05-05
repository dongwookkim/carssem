import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/maintenance_item_model.dart';
import '../../../providers/car_provider.dart';
import '../../../providers/maintenance_provider.dart';

class MaintenanceDetailScreen extends ConsumerWidget {
  final String recordId;

  const MaintenanceDetailScreen({super.key, required this.recordId});

  static const _textDark = Color(0xFF1A1A1A);
  static const _textGray = Color(0xFF757575);
  static const _borderLight = Color(0xFFF0F0F0);
  static const _accentColor = Color(0xFFFF6611);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordAsync = ref.watch(maintenanceDetailProvider(recordId));
    final selectedCar = ref.watch(selectedCarProvider);
    final numberFormat = NumberFormat('#,###');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 16, color: _textDark),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '정비 내역',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _textDark,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, size: 16, color: _textDark),
            onPressed: () => recordAsync.whenData((record) {
              if (record != null) _showDeleteDialog(context, ref, record.carId);
            }),
          ),
        ],
      ),
      body: recordAsync.when(
        data: (record) {
          if (record == null) {
            return const Center(child: Text('정비 이력을 찾을 수 없습니다'));
          }

          // Group items by system
          final groupedItems = <String, List<MaintenanceItemModel>>{};
          if (record.items != null) {
            for (final item in record.items!) {
              final key = item.system ?? '기타 정비';
              groupedItems.putIfAbsent(key, () => []).add(item);
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section - Garage Info
                Container(
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: _textDark, width: 2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '정비소',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: _textGray,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        record.garageName ?? '미등록',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _textDark,
                        ),
                      ),
                      if (record.garageAddress != null || record.mechanic != null) ...[
                        const SizedBox(height: 8),
                        if (record.garageAddress != null)
                          Text(
                            record.garageAddress!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: _textGray,
                              height: 1.625,
                            ),
                          ),
                        if (record.mechanic != null)
                          Text(
                            '정비사: ${record.mechanic}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: _textGray,
                              height: 1.625,
                            ),
                          ),
                      ],
                      if (record.garageRating != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            ...List.generate(5, (i) {
                              if (i < record.garageRating!.floor()) {
                                return const Icon(Icons.star, size: 15, color: AppColors.starFilled);
                              } else if (i < record.garageRating!) {
                                return const Icon(Icons.star_half, size: 15, color: AppColors.starFilled);
                              } else {
                                return const Icon(Icons.star_border, size: 15, color: AppColors.starEmpty);
                              }
                            }),
                            const SizedBox(width: 6),
                            Text(
                              record.garageRating!.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _textDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // Section - Vehicle Info Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E5E5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        selectedCar?.licensePlate ?? '',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: _textDark,
                          letterSpacing: -0.75,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedCar?.displayName ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _textGray,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Date + Mileage row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '정비 날짜',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _textGray,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('yyyy. MM. dd').format(record.date),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _textDark,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            '주행거리',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _textGray,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${numberFormat.format(record.mileage)} km',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _textDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // Category Sections
                if (groupedItems.isNotEmpty)
                  ...groupedItems.entries.toList().asMap().entries.map((entry) {
                    final idx = entry.key;
                    final category = entry.value.key;
                    final items = entry.value.value;
                    final subtotal = items.fold<int>(0, (sum, item) => sum + item.totalPrice);

                    return Padding(
                      padding: EdgeInsets.only(bottom: idx < groupedItems.length - 1 ? 40 : 0),
                      child: _buildCategorySection(
                        index: idx + 1,
                        title: category,
                        items: items,
                        subtotal: subtotal,
                        numberFormat: numberFormat,
                      ),
                    );
                  }),

                // Total Section
                const SizedBox(height: 48),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 36),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: _textDark, width: 4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '총 정비 금액',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: _textGray,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${numberFormat.format(record.totalCost)}원',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: _textDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Re-register section
                Center(
                  child: Text(
                    '정비 내역의 기록이 잘못 되었다면 다시 등록해주세요',
                    style: TextStyle(
                      fontSize: 12,
                      color: _textGray,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go('/scan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accentColor,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                        side: const BorderSide(color: _accentColor),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.35,
                      ),
                    ),
                    child: const Text('정비 내역 다시 등록'),
                  ),
                ),
                const SizedBox(height: 80),

                // Footer
                const Center(
                  child: Opacity(
                    opacity: 0.5,
                    child: Text(
                      'DOCUMENT GENERATED VIA CARSSEM',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: _textGray,
                        letterSpacing: 2.7,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
      ),
    );
  }

  Widget _buildCategorySection({
    required int index,
    required String title,
    required List<MaintenanceItemModel> items,
    required int subtotal,
    required NumberFormat numberFormat,
  }) {
    final sectionTitle = '${index.toString().padLeft(2, '0')}. $title';

    return Column(
      children: [
        // Section header
        Container(
          padding: const EdgeInsets.only(bottom: 9),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: _textDark)),
          ),
          child: Text(
            sectionTitle,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: _textDark,
              letterSpacing: -0.28,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Items
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Column(
            children: [
              ...items.map((item) => Container(
                    height: 45,
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: _borderLight)),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 14,
                            color: _textDark,
                          ),
                        ),
                        Text(
                          numberFormat.format(item.totalPrice),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _textDark,
                          ),
                        ),
                      ],
                    ),
                  )),

              // Subtotal
              Container(
                padding: const EdgeInsets.only(top: 17, bottom: 12),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: _textDark)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '소계',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _textGray,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      '${numberFormat.format(subtotal)}원',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: _textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, String carId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('정비 이력 삭제'),
        content: const Text('이 정비 이력을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(maintenanceNotifierProvider.notifier).deleteRecord(recordId, carId);
              context.pop();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}
