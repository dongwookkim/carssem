import 'dart:io';
import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceService {
  DeviceService._();

  static final _deviceInfo = DeviceInfoPlugin();
  static const _androidId = AndroidId();
  static String? _cachedDeviceId;

  /// 로컬 폴백 ID 저장 키 (기기 ID를 못 가져올 때만 사용)
  static const _fallbackIdKey = 'device_install_id';

  /// 기기 고유 ID 반환
  /// iOS: identifierForVendor (기기·vendor 고유)
  /// Android: Settings.Secure.ANDROID_ID (앱 서명키·기기 조합 고유, 재설치 유지)
  ///
  /// 위 값을 못 가져오는 예외 상황에서만 영구 저장된 UUID로 폴백한다.
  /// (과거 androidInfo.id == Build.ID 를 쓰면서 같은 OS 빌드의 기기들이
  ///  동일 계정으로 묶이던 버그를 방지하기 위함)
  static Future<String> getDeviceId() async {
    if (_cachedDeviceId != null) return _cachedDeviceId!;

    String? id;
    if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      id = iosInfo.identifierForVendor;
    } else if (Platform.isAndroid) {
      id = await _androidId.getId();
    }

    if (id == null || id.isEmpty) {
      id = await _getOrCreateFallbackId();
    }

    _cachedDeviceId = id;
    return id;
  }

  /// 기기 ID를 못 가져올 때 사용할, 설치마다 고유한 영구 UUID.
  /// 상수 폴백('unknown-ios' 등)으로 인해 여러 기기가 계정을 공유하는 것을 막는다.
  static Future<String> _getOrCreateFallbackId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_fallbackIdKey);
    if (id == null || id.isEmpty) {
      id = const Uuid().v4();
      await prefs.setString(_fallbackIdKey, id);
    }
    return id;
  }
}
