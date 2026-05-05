import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/car_provider.dart';

class CarFormScreen extends ConsumerStatefulWidget {
  final String? carId;

  const CarFormScreen({super.key, this.carId});

  @override
  ConsumerState<CarFormScreen> createState() => _CarFormScreenState();
}

class _CarFormScreenState extends ConsumerState<CarFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _mileageController = TextEditingController();

  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.carId != null;
    if (_isEditMode) {
      _loadCarData();
    }
  }

  Future<void> _loadCarData() async {
    setState(() => _isLoading = true);
    try {
      final carService = ref.read(carServiceProvider);
      final car = await carService.getCarById(widget.carId!);
      if (car != null && mounted) {
        _brandController.text = car.brand;
        _modelController.text = car.model;
        _yearController.text = car.year.toString();
        _licensePlateController.text = car.licensePlate ?? '';
        _mileageController.text = car.currentMileage.toString();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _licensePlateController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(carNotifierProvider.notifier);

      if (_isEditMode) {
        await notifier.updateCar(
          id: widget.carId!,
          brand: _brandController.text.trim(),
          model: _modelController.text.trim(),
          year: int.parse(_yearController.text),
          licensePlate: _licensePlateController.text.trim().isEmpty
              ? null
              : _licensePlateController.text.trim(),
          currentMileage: int.parse(_mileageController.text.replaceAll(',', '')),
        );
      } else {
        await notifier.createCar(
          brand: _brandController.text.trim(),
          model: _modelController.text.trim(),
          year: int.parse(_yearController.text),
          licensePlate: _licensePlateController.text.trim().isEmpty
              ? null
              : _licensePlateController.text.trim(),
          currentMileage: int.parse(_mileageController.text.replaceAll(',', '')),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode ? '차량 정보가 수정되었습니다' : '차량이 등록되었습니다'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? '차량 수정' : '차량 등록'),
      ),
      body: _isLoading && _isEditMode
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                24, 24, 24, 24 + MediaQuery.of(context).padding.bottom,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _brandController,
                      decoration: const InputDecoration(
                        labelText: '제조사',
                        hintText: '현대, 기아, BMW 등',
                        prefixIcon: Icon(Icons.business),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '제조사를 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _modelController,
                      decoration: const InputDecoration(
                        labelText: '모델명',
                        hintText: '아반떼, K5, 3시리즈 등',
                        prefixIcon: Icon(Icons.directions_car),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '모델명을 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _yearController,
                      decoration: const InputDecoration(
                        labelText: '연식',
                        hintText: '2023',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '연식을 입력해주세요';
                        }
                        final year = int.tryParse(value);
                        if (year == null || year < 1900 || year > DateTime.now().year + 1) {
                          return '올바른 연식을 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _licensePlateController,
                      decoration: const InputDecoration(
                        labelText: '차량 번호 (선택)',
                        hintText: '12가 3456',
                        prefixIcon: Icon(Icons.badge),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _mileageController,
                      decoration: const InputDecoration(
                        labelText: '현재 주행거리 (km)',
                        hintText: '50000',
                        prefixIcon: Icon(Icons.speed),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '주행거리를 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(_isEditMode ? '수정하기' : '등록하기'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
