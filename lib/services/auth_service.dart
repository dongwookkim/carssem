import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/app_constants.dart';
import 'device_service.dart';
import 'supabase_service.dart';

class AuthService {
  final _client = SupabaseService.client;

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Device ID 기반 자동 인증
  /// 1. 이미 세션이 있으면 바로 반환
  /// 2. Device ID로 이메일/비밀번호 생성 → signIn 시도
  /// 3. 실패 시 signUp 자동 수행
  Future<void> authenticateWithDevice() async {
    // 이미 로그인 상태면 스킵
    if (currentUser != null) return;

    final deviceId = await DeviceService.getDeviceId();
    final email = '$deviceId@device.carssem.app';
    final password = 'carssem_device_$deviceId';

    try {
      // 기존 계정으로 로그인 시도
      await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // 기존 유저도 public.users 레코드 보장
      await _ensureUserProfile();
    } on AuthException catch (e) {
      if (e.message.contains('Invalid login credentials')) {
        // 계정이 없으면 자동 회원가입
        await _client.auth.signUp(
          email: email,
          password: password,
          data: {'device_id': deviceId},
        );

        // public.users 테이블에 프로필 레코드 생성
        await _ensureUserProfile();
      } else {
        rethrow;
      }
    }
  }

  /// public.users 테이블에 프로필 레코드가 없으면 생성
  Future<void> _ensureUserProfile() async {
    final userId = currentUser?.id;
    if (userId == null) return;

    try {
      final existing = await _client
          .from('users')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      if (existing == null) {
        await _client.from('users').insert({
          'id': userId,
        });
        debugPrint('[AuthService] users 레코드 생성 완료: $userId');
      }
    } catch (e) {
      debugPrint('[AuthService] users 레코드 생성 실패: $e');
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// 회원 탈퇴: Edge Function으로 스토리지·계정·연관 데이터 일괄 삭제 후 로그아웃.
  /// service_role 권한이 필요하므로 클라이언트가 아니라 Edge Function에서 처리한다.
  Future<void> deleteAccount() async {
    if (currentUser == null) {
      throw StateError('로그인 상태가 아닙니다');
    }

    final response = await _client.functions.invoke(
      AppConstants.deleteAccountFunction,
    );

    if (response.status != 200) {
      final message = (response.data is Map && response.data['error'] != null)
          ? response.data['error'].toString()
          : '계정 삭제에 실패했습니다 (status=${response.status})';
      throw Exception(message);
    }

    try {
      await _client.auth.signOut();
    } catch (e) {
      // auth.users는 이미 삭제된 상태이므로 signOut이 실패할 수 있다 — 무시.
      debugPrint('[AuthService] signOut after delete: $e');
    }
  }

  Future<void> updateProfile({String? name, String? profileImage}) async {
    final userId = currentUser?.id;
    if (userId == null) return;

    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (profileImage != null) updates['profile_image'] = profileImage;

    if (updates.isNotEmpty) {
      await _client.from('users').update(updates).eq('id', userId);
    }
  }
}
