import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/garage_model.dart';
import '../providers/location_provider.dart';
import '../providers/region_provider.dart';
import '../services/garage_service.dart';

final garageServiceProvider =
    Provider<GarageService>((ref) => GarageService());

/// 별점 필터 (null = 전체)
class GarageRatingFilterNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void set(int? value) {
    state = value;
  }
}

final garageRatingFilterProvider =
    NotifierProvider<GarageRatingFilterNotifier, int?>(
        GarageRatingFilterNotifier.new);

/// 현재 주소 필터 문자열
/// 우선순위: 카카오 주소 선택 > GPS 위치(시군구)
final currentAddressFilterProvider = Provider<String?>((ref) {
  // 1. 카카오 주소 선택 → 도로명/동명 키워드
  final addressFilter = ref.watch(addressFilterProvider);
  if (addressFilter != null) return addressFilter.keyword;

  // 2. GPS 위치 → 시군구 추출
  final locationName = ref.watch(currentLocationNameProvider);
  return locationName.when(
    data: (name) {
      final parts = name.split(' ');
      return parts.length >= 2 ? parts[1] : null;
    },
    loading: () => null,
    error: (_, _) => null,
  );
});

/// 위치 바에 표시할 텍스트
final locationDisplayProvider = Provider<String>((ref) {
  final addressFilter = ref.watch(addressFilterProvider);
  if (addressFilter != null) return addressFilter.displayText;

  final locationName = ref.watch(currentLocationNameProvider);
  return locationName.when(
    data: (name) => name,
    loading: () => '위치 확인 중...',
    error: (_, _) => '서울특별시 종로구 세종로',
  );
});

/// 정비소 목록 (주소 + 별점 필터 적용)
final garagesProvider = FutureProvider<List<GarageModel>>((ref) async {
  final service = ref.watch(garageServiceProvider);
  final minRating = ref.watch(garageRatingFilterProvider);
  final addressFilter = ref.watch(currentAddressFilterProvider);
  return service.getGarages(
    minRating: minRating,
    addressFilter: addressFilter,
  );
});

/// 현재 유저의 정비 이력이 있는 garageId Set
final userGarageIdsProvider = FutureProvider<Set<String>>((ref) async {
  final service = ref.watch(garageServiceProvider);
  return service.getUserGarageIds();
});

/// 별점별 정비소 개수 분포
final garageRatingDistributionProvider =
    FutureProvider<Map<int, int>>((ref) async {
  final service = ref.watch(garageServiceProvider);
  return service.getRatingDistribution();
});

/// 정비소 상세
final garageDetailProvider =
    FutureProvider.family<GarageModel?, String>((ref, id) async {
  final service = ref.watch(garageServiceProvider);
  return service.getGarageById(id);
});
