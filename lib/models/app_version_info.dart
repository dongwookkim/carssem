class AppVersionInfo {
  final String platform;
  final String minSupportedVersion;
  final String? updateMessage;

  AppVersionInfo({
    required this.platform,
    required this.minSupportedVersion,
    this.updateMessage,
  });

  factory AppVersionInfo.fromJson(Map<String, dynamic> json) => AppVersionInfo(
        platform: json['platform'] as String,
        minSupportedVersion: json['min_supported_version'] as String,
        updateMessage: json['update_message'] as String?,
      );
}
