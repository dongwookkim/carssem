import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/force_update_dialog.dart';
import '../../../providers/app_version_provider.dart';
import '../../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _authenticateAndNavigate();
  }

  Future<void> _authenticateAndNavigate() async {
    // 스플래시 화면 최소 표시 시간
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // 강제 업데이트 체크 (네트워크/DB 오류 시 통과 — 락아웃 방지)
    final updateState = await ref.read(forceUpdateCheckProvider.future);
    if (!mounted) return;
    if (updateState.required) {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => ForceUpdateDialog(
          message: updateState.info?.updateMessage,
        ),
      );
      return;
    }

    try {
      // Device ID 기반 자동 인증
      await ref.read(authNotifierProvider.notifier).authenticate();

      if (!mounted) return;

      // 약관 동의 확인
      final prefs = await SharedPreferences.getInstance();
      final termsAccepted = prefs.getBool('terms_accepted') ?? false;

      if (!mounted) return;

      if (!termsAccepted) {
        context.go('/terms');
        return;
      }

      // 권한 안내 화면을 이미 봤는지 확인
      final permissionSeen = prefs.getBool('permission_seen') ?? false;

      if (permissionSeen) {
        context.go('/maintenance');
      } else {
        context.go('/permission');
      }
    } catch (e) {
      if (!mounted) return;
      // 인증 실패 시 에러 표시 후 재시도
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('인증 실패: $e'),
          action: SnackBarAction(
            label: '재시도',
            onPressed: _authenticateAndNavigate,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 300,
              height: 300,
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '스마트한 정비 이력',
              style: TextStyle(
                fontSize: 24,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
