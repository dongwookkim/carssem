import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_version_info.dart';
import '../services/app_version_service.dart';

final appVersionServiceProvider =
    Provider<AppVersionService>((ref) => AppVersionService.instance);

class ForceUpdateState {
  final bool required;
  final AppVersionInfo? info;
  const ForceUpdateState({required this.required, this.info});
}

/// 강제 업데이트 필요 여부를 조회한다.
/// 네트워크/DB 오류 시에는 false를 반환하여 오프라인 사용자가 락아웃되지 않도록 한다.
final forceUpdateCheckProvider = FutureProvider<ForceUpdateState>((ref) async {
  final service = ref.read(appVersionServiceProvider);
  try {
    final info = await service.fetchMinVersion();
    if (info == null) return const ForceUpdateState(required: false);
    final current = await service.getCurrentVersion();
    final required = service.isUpdateRequired(
      currentVersion: current,
      minSupportedVersion: info.minSupportedVersion,
    );
    return ForceUpdateState(required: required, info: info);
  } catch (_) {
    return const ForceUpdateState(required: false);
  }
});
