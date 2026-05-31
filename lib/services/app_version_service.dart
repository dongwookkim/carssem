import 'dart:io' show Platform;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/app_version_info.dart';
import 'supabase_service.dart';

class AppVersionService {
  AppVersionService._();
  static final AppVersionService instance = AppVersionService._();

  static const String _androidPackageFallback = 'com.carssem.carssem';

  String get _platformKey => Platform.isIOS ? 'ios' : 'android';

  Future<AppVersionInfo?> fetchMinVersion() async {
    final response = await SupabaseService.client
        .from('app_versions')
        .select()
        .eq('platform', _platformKey)
        .maybeSingle();

    if (response == null) return null;
    return AppVersionInfo.fromJson(response);
  }

  Future<String> getCurrentVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }

  bool isUpdateRequired({
    required String currentVersion,
    required String minSupportedVersion,
  }) {
    return _compareVersions(currentVersion, minSupportedVersion) < 0;
  }

  /// `1.2.3` 같은 semver 문자열 비교. 빌드 번호(+N)는 무시.
  /// a < b → 음수, a == b → 0, a > b → 양수.
  int _compareVersions(String a, String b) {
    final aParts = _parseVersion(a);
    final bParts = _parseVersion(b);
    final length = aParts.length > bParts.length ? aParts.length : bParts.length;
    for (var i = 0; i < length; i++) {
      final av = i < aParts.length ? aParts[i] : 0;
      final bv = i < bParts.length ? bParts[i] : 0;
      if (av != bv) return av - bv;
    }
    return 0;
  }

  List<int> _parseVersion(String version) {
    final core = version.split('+').first.split('-').first;
    return core.split('.').map((s) => int.tryParse(s) ?? 0).toList();
  }

  Uri _storeUri() {
    if (Platform.isIOS) {
      final id = dotenv.env['IOS_APP_STORE_ID']?.trim() ?? '';
      if (id.isNotEmpty) {
        return Uri.parse('https://apps.apple.com/app/id$id');
      }
      return Uri.parse('https://apps.apple.com/kr/search?term=carssem');
    }
    final pkg = dotenv.env['ANDROID_PACKAGE_NAME']?.trim().isNotEmpty == true
        ? dotenv.env['ANDROID_PACKAGE_NAME']!.trim()
        : _androidPackageFallback;
    return Uri.parse('https://play.google.com/store/apps/details?id=$pkg');
  }

  Future<bool> launchStore() async {
    final uri = _storeUri();
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
