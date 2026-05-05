import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/car_model.dart';
import '../../../models/maintenance_record_model.dart';
import '../../../providers/car_provider.dart';
import '../../../providers/maintenance_provider.dart';


class MaintenanceListScreen extends ConsumerWidget {
  const MaintenanceListScreen({super.key});

  static const _accentColor = Color(0xFFEC5B13);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carsAsync = ref.watch(carsProvider);
    final selectedCarId = ref.watch(selectedCarIdProvider);

    // 차량이 선택되면 자체 Scaffold를 가진 정비 이력 화면을 바로 반환
    if (selectedCarId != null) {
      return carsAsync.when(
        data: (cars) {
          if (cars.isEmpty) return const SizedBox.shrink();
          final selectedCar = cars.firstWhere(
            (c) => c.id == selectedCarId,
            orElse: () => cars.first,
          );
          return _MaintenanceHistoryView(
            car: selectedCar,
            onBack: () => ref.read(selectedCarIdProvider.notifier).select(null),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F6F6),
        elevation: 0,
        leadingWidth: 160,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  Scaffold.of(context).openDrawer();
                },
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.menu, size: 18, color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'carssem',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF18181B),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => context.go('/scan'),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _accentColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _accentColor.withValues(alpha: 0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 10),
                      spreadRadius: -3,
                    ),
                    BoxShadow(
                      color: _accentColor.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: const Icon(Icons.camera_alt_outlined, size: 20, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: carsAsync.when(
        data: (cars) {
          if (cars.isEmpty) {
            return _buildEmptyState(context);
          }
          return _VehicleListView(cars: cars);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 192,
              height: 192,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 32),
            const Text(
              '정비 내역이 없습니다',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              '정비 후 받은 정비 명세서를 촬영해서\n정비내역을 자동으로 정리하세요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.625,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 240,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _accentColor.withValues(alpha: 0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 10),
                      spreadRadius: -3,
                    ),
                    BoxShadow(
                      color: _accentColor.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => context.go('/scan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                    minimumSize: const Size(240, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: const Text('정비 내역 추가하기'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleListView extends ConsumerWidget {
  final List<CarModel> cars;

  const _VehicleListView({required this.cars});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(carsProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '차량 목록',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF18181B),
                ),
              ),
              Text(
                '총 ${cars.length}대',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF71717A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Vehicle cards
          ...cars.map((car) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _VehicleCard(car: car),
              )),
        ],
      ),
    );
  }
}

class _VehicleCard extends ConsumerWidget {
  final CarModel car;

  const _VehicleCard({required this.car});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(maintenanceRecordsProvider(car.id));
    final numberFormat = NumberFormat('#,###');

    return GestureDetector(
      onTap: () {
        ref.read(selectedCarIdProvider.notifier).select(car.id);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 25,
              offset: const Offset(0, 10),
              spreadRadius: -5,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 8),
              spreadRadius: -6,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 10, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // License plate + car name + menu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        car.licensePlate ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF18181B),
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        car.displayName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF71717A),
                        ),
                      ),
                    ],
                  )),
                  _CarMenuButton(
                    carId: car.id,
                    licensePlate: car.licensePlate ?? car.displayName,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Latest maintenance info
              recordsAsync.when(
                data: (records) {
                  if (records.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '정비 내역이 없습니다',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF71717A),
                        ),
                      ),
                    );
                  }
                  final latest = records.first;
                  return Column(
                    children: [
                      // Date & mileage row
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '정비 날짜',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF71717A),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('yyyy. MM. dd').format(latest.date),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF18181B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '주행거리',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF71717A),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${numberFormat.format(latest.mileage)} km',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF18181B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Latest maintenance item
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '정비 항목',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF71717A),
                                      letterSpacing: -0.25,
                                    ),
                                  ),
                                  Text(
                                    (latest.items != null && latest.items!.isNotEmpty)
                                        ? latest.items!.first.name
                                        : '-',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF27272A),
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
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CarMenuButton extends ConsumerWidget {
  final String carId;
  final String licensePlate;

  const _CarMenuButton({required this.carId, required this.licensePlate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_horiz, size: 24, color: Color(0xFF71717A)),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      offset: const Offset(0, 32),
      itemBuilder: (context) => [
        const PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '삭제하기',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFEF4444),
                ),
              ),
              Icon(Icons.delete_outline, size: 14, color: Color(0xFFEF4444)),
            ],
          ),
        ),
      ],
      onSelected: (value) async {
        if (value == 'delete') {
          final confirmed = await showDialog<bool>(
            context: context,
            barrierColor: Colors.black.withValues(alpha: 0.6),
            builder: (context) => _DeleteCarDialog(licensePlate: licensePlate),
          );
          if (confirmed == true) {
            try {
              await ref.read(carNotifierProvider.notifier).deleteCar(carId);
              if (ref.read(selectedCarIdProvider) == carId) {
                ref.read(selectedCarIdProvider.notifier).select(null);
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('삭제 실패: $e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            }
          }
        }
      },
    );
  }
}

class _DeleteCarDialog extends StatelessWidget {
  final String licensePlate;

  const _DeleteCarDialog({required this.licensePlate});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 25,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.only(top: 17),
            child: Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 48),
            child: Column(
              children: [
                // Car icon in red circle
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEF2F2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.directions_car,
                    size: 36,
                    color: Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(height: 24),

                // License plate
                Text(
                  licensePlate,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEC5B13),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),

                // Title
                const Text(
                  '차량을 삭제 하시겠습니까?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 40),

                // Buttons
                Row(
                  children: [
                    // Cancel button
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.border,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            '취소',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Delete button
                    SizedBox(
                      width: 136,
                      height: 56,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFECACA).withValues(alpha: 0.8),
                              blurRadius: 15,
                              offset: const Offset(0, 10),
                              spreadRadius: -3,
                            ),
                            BoxShadow(
                              color: const Color(0xFFFECACA).withValues(alpha: 0.8),
                              blurRadius: 6,
                              offset: const Offset(0, 4),
                              spreadRadius: -4,
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            '삭제',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MaintenanceHistoryView extends ConsumerWidget {
  final CarModel car;
  final VoidCallback onBack;

  const _MaintenanceHistoryView({required this.car, required this.onBack});

  static const _accentColor = Color(0xFFF97316);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(maintenanceRecordsProvider(car.id));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 16, color: AppColors.textPrimary),
          onPressed: onBack,
        ),
        title: const Text(
          '정비 이력',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => context.go('/scan'),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _accentColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: const Icon(Icons.camera_alt_outlined, size: 17, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: recordsAsync.when(
        data: (records) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(maintenanceRecordsProvider(car.id));
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                // Vehicle Info Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
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
                        car.licensePlate ?? '',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        car.displayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Section header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '정비 히스토리',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '전체 ${records.length}건',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                if (records.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.history, size: 64, color: AppColors.textHint),
                          const SizedBox(height: 16),
                          const Text(
                            '정비 이력이 없습니다',
                            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '명세서를 스캔하여 정비 이력을 기록하세요',
                            style: TextStyle(color: AppColors.textHint),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...records.map((record) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _HistoryCard(record: record),
                      )),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final MaintenanceRecordModel record;

  const _HistoryCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat('#,###');

    return GestureDetector(
      onTap: () => context.push('/maintenance/${record.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Top row: date + mileage (light background)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.5),
                border: const Border(
                  bottom: BorderSide(color: AppColors.divider),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('yyyy. MM. dd').format(record.date),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (record.mileage > 0)
                    Text(
                      '${numberFormat.format(record.mileage)} km',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                ],
              ),
            ),

            // Items + footer
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Bullet items (summary: first 2 + "외 N건")
                  if (record.items != null && record.items!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Column(
                        children: [
                          ...record.items!.take(2).map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '\u2022',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textHint,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF334155),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          if (record.items!.length > 2)
                            Padding(
                              padding: const EdgeInsets.only(left: 20, bottom: 4),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '외 ${record.items!.length - 2}건',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textHint,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Dashed separator + cost + detail link
                  Container(
                    padding: const EdgeInsets.only(top: 17, left: 12, right: 12),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: AppColors.border,
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              '금액: ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${numberFormat.format(record.totalCost)}원',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: const [
                            Text(
                              '정비 내역 보기',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3B82F6),
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right,
                              size: 14,
                              color: Color(0xFF3B82F6),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
