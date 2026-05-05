import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/scan_provider.dart';

class ScanScreen extends ConsumerWidget {
  const ScanScreen({super.key});

  Future<void> _pickImage(BuildContext context, WidgetRef ref, ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source, imageQuality: 80);

    if (image != null) {
      final bytes = await image.readAsBytes();
      ref.read(scanNotifierProvider.notifier).setImage(bytes, image.name);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanState = ref.watch(scanNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 16, color: AppColors.textPrimary),
          onPressed: () => context.go('/maintenance'),
        ),
        title: const Text(
          '명세서 스캔',
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: scanState.imageBytes == null
                    ? _buildImagePicker(context, ref)
                    : _buildImagePreview(context, ref, scanState),
              ),
              const SizedBox(height: 16),
              if (scanState.imageBytes != null) ...[
                if (scanState.error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            scanState.error!,
                            style: const TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                _PrimaryActionButton(
                  label: scanState.isAnalyzing ? 'AI 분석 중...' : 'AI로 분석하기',
                  busy: scanState.isAnalyzing,
                  onPressed: scanState.isAnalyzing
                      ? null
                      : () async {
                          await ref.read(scanNotifierProvider.notifier).analyzeReceipt();
                          final newState = ref.read(scanNotifierProvider);
                          if (newState.result != null && context.mounted) {
                            context.push('/scan/result');
                          }
                        },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: double.infinity,
          height: 300,
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
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long,
                size: 72,
                color: AppColors.textHint,
              ),
              SizedBox(height: 16),
              Text(
                '정비 명세서를 촬영하거나\n갤러리에서 선택하세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _SourceCardButton(
                icon: Icons.camera_alt_outlined,
                label: '카메라',
                onTap: () => _pickImage(context, ref, ImageSource.camera),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SourceCardButton(
                icon: Icons.photo_library_outlined,
                label: '갤러리',
                onTap: () => _pickImage(context, ref, ImageSource.gallery),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImagePreview(BuildContext context, WidgetRef ref, ScanState state) {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
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
            child: Image.memory(
              state.imageBytes!,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: () => _pickImage(context, ref, ImageSource.camera),
              icon: const Icon(Icons.camera_alt_outlined, size: 18),
              label: const Text('다시 촬영'),
              style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: () => _pickImage(context, ref, ImageSource.gallery),
              icon: const Icon(Icons.photo_library_outlined, size: 18),
              label: const Text('다시 선택'),
              style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }
}

class _SourceCardButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceCardButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
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
            Icon(icon, size: 26, color: AppColors.textSecondary),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  final String label;
  final bool busy;
  final VoidCallback? onPressed;

  const _PrimaryActionButton({
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
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(label),
                  ],
                )
              : Text(label),
        ),
      ),
    );
  }
}
