import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/car_provider.dart';
import '../../../providers/maintenance_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carsAsync = ref.watch(carsProvider);
    final recentMaintenanceAsync = ref.watch(recentMaintenanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('카쎔'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(carsProvider);
          ref.invalidate(recentMaintenanceProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // My Cars Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '내 차량',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/cars'),
                    child: const Text('관리'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              carsAsync.when(
                data: (cars) {
                  if (cars.isEmpty) {
                    return _buildEmptyCarCard(context);
                  }
                  return SizedBox(
                    height: 140,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: cars.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        if (index == cars.length) {
                          return _buildAddCarCard(context);
                        }
                        final car = cars[index];
                        return _buildCarCard(context, car, ref);
                      },
                    ),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (e, _) => Text('오류: $e'),
              ),
              const SizedBox(height: 24),

              // Quick Scan Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/scan'),
                  icon: const Icon(Icons.document_scanner),
                  label: const Text('명세서 스캔하기'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Recent Maintenance Section
              const Text(
                '최근 정비 이력',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              recentMaintenanceAsync.when(
                data: (records) {
                  if (records.isEmpty) {
                    return _buildEmptyMaintenanceCard();
                  }
                  return Column(
                    children: records.map((record) {
                      return _buildMaintenanceCard(context, record);
                    }).toList(),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (e, _) => Text('오류: $e'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCarCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/cars/add'),
      child: Container(
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 40, color: AppColors.primary),
            SizedBox(height: 8),
            Text(
              '차량을 등록해주세요',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarCard(BuildContext context, car, WidgetRef ref) {
    final isSelected = ref.watch(selectedCarIdProvider) == car.id;

    return GestureDetector(
      onTap: () {
        ref.read(selectedCarIdProvider.notifier).select(car.id);
      },
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.directions_car,
              size: 32,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const Spacer(),
            Text(
              car.displayName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              car.displayYear,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            Text(
              '${NumberFormat('#,###').format(car.currentMileage)} km',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCarCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/cars/add'),
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 32, color: AppColors.textSecondary),
            SizedBox(height: 4),
            Text(
              '추가',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyMaintenanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Icon(Icons.history, size: 40, color: AppColors.textHint),
          SizedBox(height: 8),
          Text(
            '정비 이력이 없습니다',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          SizedBox(height: 4),
          Text(
            '명세서를 스캔하여 정비 이력을 기록하세요',
            style: TextStyle(color: AppColors.textHint, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceCard(BuildContext context, record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => context.push('/maintenance/${record.id}'),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.build, color: AppColors.primary),
        ),
        title: Text(
          record.garageName ?? '정비소 미등록',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          DateFormat('yyyy.MM.dd').format(record.date),
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        trailing: Text(
          '${NumberFormat('#,###').format(record.totalCost)}원',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
