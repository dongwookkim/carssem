import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceService {
  DeviceService._();

  static final _deviceInfo = DeviceInfoPlugin();
  static String? _cachedDeviceId;

  /// 기기 고유 ID 반환
  /// iOS: identifierForVendor
  /// Android: androidId
  static Future<String> getDeviceId() async {
    if (_cachedDeviceId != null) return _cachedDeviceId!;

    if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      _cachedDeviceId = iosInfo.identifierForVendor ?? 'unknown-ios';
    } else if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      _cachedDeviceId = androidInfo.id;
    } else {
      _cachedDeviceId = 'unknown-device';
    }

    return _cachedDeviceId!;
  }
}
