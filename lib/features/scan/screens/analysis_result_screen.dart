import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/scan_provider.dart';
import '../../../providers/car_provider.dart';
import '../../../providers/garage_provider.dart';
import '../../../providers/maintenance_provider.dart';
import '../../../services/maintenance_service.dart';
import '../../../services/receipt_analysis_service.dart';

class AnalysisResultScreen extends ConsumerStatefulWidget {
  const AnalysisResultScreen({super.key});

  @override
  ConsumerState<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends ConsumerState<AnalysisResultScreen> {
  static const _accentColor = Color(0xFFEC5B13);

  late TextEditingController _dateController;
  late TextEditingController _garageNameController;
  late TextEditingController _mileageController;
  late TextEditingController _totalCostController;
  late TextEditingController _licensePlateController;
  late TextEditingController _carBrandController;
  late TextEditingController _carModelController;
  late TextEditingController _carYearController;
  late List<AnalyzedItem> _items;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final result = ref.read(scanNotifierProvider).result!;
    _dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(result.date),
    );
    _garageNameController = TextEditingController(text: result.garageName ?? '');
    _mileageController = TextEditingController(text: result.mileage.toString());
    _totalCostController = TextEditingController(text: result.totalCost.toString());
    _licensePlateController = TextEditingController(text: result.licensePlate ?? '');
    _carBrandController = TextEditingController(text: result.carBrand ?? '');
    _carModelController = TextEditingController(text: result.carModel ?? '');
    _carYearController = TextEditingController(
      text: result.carYear?.toString() ?? '',
    );
    _items = List.from(result.items);
  }

  @override
  void dispose() {
    _dateController.dispose();
    _garageNameController.dispose();
    _mileageController.dispose();
    _totalCostController.dispose();
    _licensePlateController.dispose();
    _carBrandController.dispose();
    _carModelController.dispose();
    _carYearController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final currentDate = DateTime.tryParse(_dateController.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _handleSave() async {
    final licensePlate = _licensePlateController.text.trim();
    final carBrand = _carBrandController.text.trim();
    final carModel = _carModelController.text.trim();
    final carYear = int.tryParse(_carYearController.text.trim());
    final mileage = int.tryParse(_mileageController.text) ?? 0;

    if (licensePlate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('차량번호를 입력해주세요'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final result = ref.read(scanNotifierProvider).result!;
      final carService = ref.read(carServiceProvider);
      final carNotifier = ref.read(carNotifierProvider.notifier);

      String carId;
      final existingCar = await carService.findByLicensePlate(licensePlate);

      if (existingCar != null) {
        carId = existingCar.id;
        if (mileage > existingCar.currentMileage) {
          await carNotifier.updateCar(
            id: existingCar.id,
            currentMileage: mileage,
          );
        }
      } else {
        final newCar = await carNotifier.createCar(
          brand: carBrand.isNotEmpty ? carBrand : '미확인',
          model: carModel.isNotEmpty ? carModel : '미확인',
          year: carYear ?? DateTime.now().year,
          licensePlate: licensePlate,
          currentMileage: mileage,
        );
        if (newCar == null) {
          throw Exception('차량 생성에 실패했습니다');
        }
        carId = newCar.id;
      }

      String? garageId;
      final garageName = _garageNameController.text.trim();
      if (garageName.isNotEmpty) {
        final garageService = ref.read(garageServiceProvider);
        garageId = await garageService.getOrCreateGarage(
          name: garageName,
          address: result.garageAddress,
        );
      }

      final items = _items.map((item) => MaintenanceItemInput(
        system: item.system,
        category: item.category,
        name: item.name,
        description: item.description,
        role: item.role,
        reason: item.reason,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
        totalPrice: item.totalPrice,
      )).toList();

      await ref.read(maintenanceNotifierProvider.notifier).createRecord(
        carId: carId,
        garageId: garageId,
        date: DateTime.parse(_dateController.text),
        mileage: mileage,
        totalCost: int.tryParse(_totalCostController.text) ?? 0,
        receiptImage: result.imageUrl,
        mechanic: result.mechanic,
        items: items,
      );

      ref.read(scanNotifierProvider.notifier).reset();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              existingCar != null
                  ? '정비 이력이 저장되었습니다'
                  : '새 차량이 등록되고 정비 이력이 저장되었습니다',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/maintenance');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('저장 실패: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat('#,###');

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 16, color: AppColors.textPrimary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/scan');
            }
          },
        ),
        title: const Text(
          '분석 결과',
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
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          16, 16, 16, 16 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title: '차량 정보'),
            const SizedBox(height: 12),
            _SectionCard(
              child: Column(
                children: [
                  _LabeledField(
                    label: '차량번호 *',
                    controller: _licensePlateController,
                    hint: '예: 12가 3456',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _LabeledField(
                          label: '제조사',
                          controller: _carBrandController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _LabeledField(
                          label: '모델',
                          controller: _carModelController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _LabeledField(
                    label: '연식',
                    controller: _carYearController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _SectionHeader(title: '기본 정보'),
            const SizedBox(height: 12),
            _SectionCard(
              child: Column(
                children: [
                  _LabeledField(
                    label: '정비 일자',
                    controller: _dateController,
                    readOnly: true,
                    onTap: _selectDate,
                  ),
                  const SizedBox(height: 16),
                  _LabeledField(
                    label: '정비소',
                    controller: _garageNameController,
                  ),
                  const SizedBox(height: 16),
                  _LabeledField(
                    label: '주행거리 (km)',
                    controller: _mileageController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _SectionHeader(
              title: '정비 항목',
              trailing: Text(
                '${_items.length}개',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ..._items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ItemCard(item: item, numberFormat: numberFormat),
                )),
            const SizedBox(height: 4),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _accentColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _accentColor.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '총 금액',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${numberFormat.format(int.tryParse(_totalCostController.text) ?? 0)}원',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _accentColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _PrimarySaveButton(
              label: '저장하기',
              busy: _isSaving,
              onPressed: _isSaving ? null : _handleSave,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _SectionHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: child,
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _LabeledField({
    required this.label,
    required this.controller,
    this.hint,
    this.readOnly = false,
    this.onTap,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: -0.25,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFEC5B13), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _ItemCard extends StatelessWidget {
  final AnalyzedItem item;
  final NumberFormat numberFormat;

  const _ItemCard({required this.item, required this.numberFormat});

  static const _accentColor = Color(0xFFEC5B13);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              item.category,
              style: const TextStyle(
                color: _accentColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.quantity}개 × ${numberFormat.format(item.unitPrice)}원',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${numberFormat.format(item.totalPrice)}원',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimarySaveButton extends StatelessWidget {
  final String label;
  final bool busy;
  final VoidCallback? onPressed;

  const _PrimarySaveButton({
    required this.label,
    required this.busy,
    required this.onPressed,
  });

  static const _accentColor = Color(0xFFEC5B13);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: onPressed == null
              ? null
              : [
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
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: _accentColor,
            disabledBackgroundColor: _accentColor.withValues(alpha: 0.5),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: busy
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(label),
        ),
      ),
    );
  }
}
