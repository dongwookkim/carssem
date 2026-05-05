import '../models/garage_model.dart';
import 'supabase_service.dart';

class GarageService {
  final _client = SupabaseService.client;

  /// 이름으로 정비소를 찾고, 없으면 새로 생성하여 ID를 반환한다.
  Future<String> getOrCreateGarage({
    required String name,
    String? address,
  }) async {
    // 이름으로 기존 정비소 검색
    final existing = await _client
        .from('garages')
        .select('id')
        .eq('name', name)
        .maybeSingle();

    if (existing != null) {
      return existing['id'] as String;
    }

    // 새로 생성
    final created = await _client
        .from('garages')
        .insert({
          'name': name,
          if (address != null) 'address': address,
        })
        .select('id')
        .single();

    return created['id'] as String;
  }

  /// 정비소 목록 조회 (주소/별점 필터)
  Future<List<GarageModel>> getGarages({
    int? minRating,
    String? addressFilter,
  }) async {
    var query = _client.from('garages').select();

    if (addressFilter != null && addressFilter.isNotEmpty) {
      query = query.ilike('address', '%$addressFilter%');
    }

    if (minRating != null && minRating > 0) {
      query = query.gte('average_rating', minRating);
    }

    final response = await query.order('average_rating', ascending: false);

    return (response as List).map((e) => GarageModel.fromJson(e)).toList();
  }

  /// 정비소 상세 조회
  Future<GarageModel?> getGarageById(String id) async {
    final response = await _client
        .from('garages')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return GarageModel.fromJson(response);
  }

  /// 현재 유저가 정비 이력이 있는 garageId 목록
  Future<Set<String>> getUserGarageIds() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return {};

    final response = await _client
        .from('maintenance_records')
        .select('garage_id, cars!inner(user_id)')
        .eq('cars.user_id', userId)
        .not('garage_id', 'is', null);

    final ids = (response as List)
        .map((e) => e['garage_id'] as String)
        .toSet();

    return ids;
  }

  /// 정비소 주소 검색 (도로명/동 매칭)
  Future<List<String>> searchGarageAddresses(String query) async {
    final response = await _client
        .from('garages')
        .select('address')
        .not('address', 'is', null)
        .ilike('address', '%$query%')
        .order('address')
        .limit(10);

    final addresses = <String>{};
    for (final row in response as List) {
      final addr = row['address'] as String?;
      if (addr != null) addresses.add(addr);
    }
    return addresses.toList();
  }

  /// 별점별 정비소 개수 분포 (전체/5/4/3/2/1)
  Future<Map<int, int>> getRatingDistribution() async {
    final response = await _client
        .from('garages')
        .select('average_rating');

    final list = response as List;
    final distribution = <int, int>{0: list.length};

    for (int star = 1; star <= 5; star++) {
      distribution[star] = list
          .where((e) => (e['average_rating'] as num).toDouble() >= star)
          .length;
    }

    return distribution;
  }
}
