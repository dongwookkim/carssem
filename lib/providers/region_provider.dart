import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/kakao_address_service.dart';

final kakaoAddressServiceProvider =
    Provider<KakaoAddressService>((ref) => KakaoAddressService());

/// 선택된 주소 필터 (검색용 키워드 + 표시용 주소)
class AddressFilter {
  final String keyword;
  final String displayText;
  const AddressFilter({required this.keyword, required this.displayText});
}

class AddressFilterNotifier extends Notifier<AddressFilter?> {
  @override
  AddressFilter? build() => null;

  void set(AddressFilter? filter) {
    state = filter;
  }

  void clear() {
    state = null;
  }
}

final addressFilterProvider =
    NotifierProvider<AddressFilterNotifier, AddressFilter?>(
        AddressFilterNotifier.new);

/// 카카오 주소 검색
final addressSearchProvider =
    FutureProvider.family<List<KakaoAddressResult>, String>(
        (ref, query) async {
  final service = ref.watch(kakaoAddressServiceProvider);
  return service.searchAddress(query);
});
