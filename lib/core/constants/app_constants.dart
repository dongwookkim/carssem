class AppConstants {
  AppConstants._();

  static const String appName = '카쎔';
  static const String appNameEn = 'CarSSEM';

  // Storage Buckets
  static const String receiptsBucket = 'receipts';
  static const String carsBucket = 'cars';
  static const String profilesBucket = 'profiles';

  // Edge Functions
  static const String analyzeReceiptFunction = 'analyze-receipt';
  static const String deleteAccountFunction = 'delete-account';

  // Maintenance Categories
  static const String categoryParts = '부품';
  static const String categoryLabor = '공임';
  static const String categoryOther = '기타';

  // Pagination
  static const int defaultPageSize = 20;
}
