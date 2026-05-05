import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/maintenance_record_model.dart';
import '../../../models/review_model.dart';
import '../../../providers/review_provider.dart';

class GarageReviewDialog extends ConsumerStatefulWidget {
  final MaintenanceRecordModel record;

  const GarageReviewDialog({super.key, required this.record});

  @override
  ConsumerState<GarageReviewDialog> createState() => _GarageReviewDialogState();

  static Future<bool> show(BuildContext context, MaintenanceRecordModel record) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GarageReviewDialog(record: record),
    );
    return result ?? false;
  }
}

class _GarageReviewDialogState extends ConsumerState<GarageReviewDialog> {
  int _rating = 0;
  final _contentController = TextEditingController();
  ReviewModel? _existingReview;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _deleteConfirm = false;

  @override
  void initState() {
    super.initState();
    _loadExistingReview();
  }

  Future<void> _loadExistingReview() async {
    if (!widget.record.hasReview) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final service = ref.read(reviewServiceProvider);
    final review = await service.getReviewByRecordId(widget.record.id);
    if (mounted) {
      setState(() {
        _existingReview = review;
        if (review != null) {
          _rating = review.rating;
          _contentController.text = review.content ?? '';
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSave() async {
    if (_rating == 0) return;
    setState(() => _isSaving = true);

    try {
      final service = ref.read(reviewServiceProvider);
      final content = _contentController.text.trim();

      if (_existingReview != null) {
        await service.updateReview(
          reviewId: _existingReview!.id,
          garageId: widget.record.garageId!,
          rating: _rating,
          content: content.isNotEmpty ? content : null,
        );
      } else {
        await service.createReview(
          garageId: widget.record.garageId!,
          recordId: widget.record.id,
          rating: _rating,
          content: content.isNotEmpty ? content : null,
        );
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handleDelete() async {
    if (_existingReview == null) return;
    setState(() => _isSaving = true);

    try {
      final service = ref.read(reviewServiceProvider);
      await service.deleteReview(_existingReview!.id, widget.record.garageId!);

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 실패: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    final numberFormat = NumberFormat('#,###');
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: _isLoading
          ? const SizedBox(
              height: 300,
              child: Center(child: CircularProgressIndicator()),
            )
          : Stack(
              children: [
                GestureDetector(
              onTap: () {
                if (_deleteConfirm) {
                  setState(() => _deleteConfirm = false);
                }
              },
              behavior: HitTestBehavior.translucent,
              child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 제목
                    const Text(
                      '정비소 평가',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 정비소 이름 + 주소
                    Text(
                      record.garageName ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    if (record.garageAddress != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          record.garageAddress!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    const SizedBox(height: 20),

                    // 정비일 + 금액
                    Text(
                      DateFormat('yyyy년 M월 d일').format(record.date),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${numberFormat.format(record.totalCost)}원',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // 정비 항목
                    if (record.items != null && record.items!.isNotEmpty)
                      ...record.items!.map((item) => Text(
                            '· ${item.name}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          )),

                    const SizedBox(height: 24),

                    // 별점
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () => setState(() => _rating = index + 1),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              index < _rating
                                  ? Icons.star_rounded
                                  : Icons.star_rounded,
                              size: 48,
                              color: index < _rating
                                  ? AppColors.starFilled
                                  : AppColors.starEmpty,
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 20),

                    // 후기 입력
                    TextField(
                      controller: _contentController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: '정비 후기를 남겨주세요',
                        hintStyle: const TextStyle(color: AppColors.textHint),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 버튼
                    Column(
                      children: [
                        Row(
                          children: [
                            if (_existingReview != null)
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _isSaving
                                      ? null
                                      : () {
                                          if (_deleteConfirm) {
                                            _handleDelete();
                                          } else {
                                            setState(() => _deleteConfirm = true);
                                          }
                                        },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.error,
                                    backgroundColor: _deleteConfirm ? AppColors.error.withOpacity(0.1) : null,
                                    side: BorderSide(
                                      color: AppColors.error,
                                      width: _deleteConfirm ? 2 : 1,
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('삭제'),
                                ),
                              ),
                            if (_existingReview != null) const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _isSaving ? null : () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('취소'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: (_isSaving || _rating == 0) ? null : _handleSave,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('확인'),
                              ),
                            ),
                          ],
                        ),
                        if (_deleteConfirm)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              '한 번 더 클릭하면 삭제됩니다.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            ),
                if (_isSaving)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
