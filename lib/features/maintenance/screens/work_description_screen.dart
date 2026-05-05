import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../models/maintenance_item_model.dart';
import '../../../providers/work_step_provider.dart';

class WorkDescriptionScreen extends ConsumerWidget {
  final String system;
  final List<MaintenanceItemModel> items;
  final DateTime date;
  final int mileage;

  const WorkDescriptionScreen({
    super.key,
    required this.system,
    required this.items,
    required this.date,
    required this.mileage,
  });

  static const _textDark = Color(0xFF0F172A);
  static const _textSlate = Color(0xFF1E293B);
  static const _textBody = Color(0xFF475569);
  static const _textLabel = Color(0xFF94A3B8);
  static const _textMuted = Color(0xFF64748B);
  static const _border = Color(0xFFE2E8F0);
  static const _accentColor = Color(0xFFF2651D);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workStepsAsync = ref.watch(workStepsProvider(system));
    final numberFormat = NumberFormat('#,###');
    final subtotal = items.fold<int>(0, (sum, item) => sum + item.totalPrice);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 16, color: _textDark),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '작업 설명',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _textDark,
            letterSpacing: -0.45,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: _border, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 48),
          child: Column(
            children: [
              // Hero Section
              _buildHeroSection(),
              const SizedBox(height: 24),

              // Cost & Detail Card
              _buildCostDetailCard(numberFormat, subtotal),
              const SizedBox(height: 24),

              // Work Steps Card
              workStepsAsync.when(
                data: (steps) => _buildWorkStepsCard(steps),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
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

  Widget _buildHeroSection() {
    final dateStr = DateFormat('yyyy. MM. dd').format(date);
    final mileageStr = NumberFormat('#,###').format(mileage);

    return Container(
      height: 224,
      width: double.infinity,
      decoration: BoxDecoration(
        color: _border,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 10),
            spreadRadius: -3,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
            spreadRadius: -4,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                stops: [0.0, 0.5, 1.0],
                colors: [
                  Color(0xCC000000),
                  Color(0x33000000),
                  Color(0x00000000),
                ],
              ),
            ),
          ),
          // Content
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    system,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.33,
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 13, color: Colors.white70),
                    const SizedBox(width: 6),
                    Text(
                      '정비 날짜: $dateStr',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.speed_outlined,
                        size: 13, color: Colors.white70),
                    const SizedBox(width: 6),
                    Text(
                      '주행거리: $mileageStr km',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
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

  Widget _buildCostDetailCard(NumberFormat numberFormat, int subtotal) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
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
          // Cost header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '비용',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _textDark,
                  ),
                ),
                Text(
                  '${numberFormat.format(subtotal)}원',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _accentColor,
                  ),
                ),
              ],
            ),
          ),

          // Item details
          ...items.map((item) => _buildItemDetail(item)),
        ],
      ),
    );
  }

  Widget _buildItemDetail(MaintenanceItemModel item) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabelValue('작업', item.name, isBold: true),
          if (item.description != null) ...[
            const SizedBox(height: 24),
            _buildLabelValue('내용', item.description!),
          ],
          if (item.role != null) ...[
            const SizedBox(height: 24),
            _buildLabelValue('역할', item.role!),
          ],
          if (item.reason != null) ...[
            const SizedBox(height: 24),
            _buildLabelValue('이유', item.reason!),
          ],
        ],
      ),
    );
  }

  Widget _buildLabelValue(String label, String value, {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: _textLabel,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? _textSlate : _textBody,
            height: isBold ? 1.5 : 1.43,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkStepsCard(List steps) {
    if (steps.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
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
        children: steps.asMap().entries.map((entry) {
          final idx = entry.key;
          final step = entry.value;
          final isFirst = idx == 0;

          return Container(
            decoration: isFirst
                ? null
                : const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: _border, style: BorderStyle.solid),
                    ),
                  ),
            padding: EdgeInsets.fromLTRB(24, isFirst ? 24 : 25, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${step.stepOrder}단계. ${step.title}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _textDark,
                    height: 1.56,
                  ),
                ),
                const SizedBox(height: 12),
                ...step.subSteps.map<Widget>((subStep) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFFCBD5E1),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              subStep,
                              style: const TextStyle(
                                fontSize: 14,
                                color: _textMuted,
                                height: 1.43,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
