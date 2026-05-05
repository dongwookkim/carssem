import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 지역 단위 검색 결과 (시군구 / 동 / 도로명)
class KakaoAddressResult {
  final String displayText; // 표시용: "서울 강남구", "경기 화성시 만남로"
  final String filterKeyword; // DB 검색용: "강남구", "만남로"

  const KakaoAddressResult({
    required this.displayText,
    required this.filterKeyword,
  });
}

class KakaoAddressService {
  static String get _apiKey => dotenv.env['KAKAO_REST_API_KEY'] ?? '';

  /// 카카오 키워드 검색 → 지역 단위(시군구/동/도로명)로 그룹핑하여 반환
  Future<List<KakaoAddressResult>> searchAddress(String query) async {
    if (query.trim().isEmpty || _apiKey.isEmpty) return [];

    try {
      final uri =
          Uri.https('dapi.kakao.com', '/v2/local/search/keyword.json', {
        'query': query.trim(),
        'size': '15',
      });

      final client = HttpClient();
      try {
        final request = await client.getUrl(uri);
        request.headers.set('Authorization', 'KakaoAK $_apiKey');

        final response = await request.close();
        final body = await response.transform(utf8.decoder).join();
        final data = json.decode(body) as Map<String, dynamic>;

        final documents = data['documents'] as List? ?? [];

        // 지역 단위로 추출 & 중복 제거
        final seen = <String>{};
        final results = <KakaoAddressResult>[];

        for (final doc in documents) {
          final addressName = doc['address_name'] as String? ?? '';
          final roadAddressName = doc['road_address_name'] as String?;
          final addr = roadAddressName ?? addressName;
          if (addr.isEmpty) continue;

          final parts = addr.split(' ');
          if (parts.length < 2) continue;

          final sido = parts[0]; // 서울, 경기 등

          // 시군구 추출 (2번째 파트)
          final sigungu = parts.length >= 2 ? parts[1] : null;
          if (sigungu != null) {
            final key = '$sido $sigungu';
            if (!seen.contains(key)) {
              seen.add(key);
              results.add(KakaoAddressResult(
                displayText: key,
                filterKeyword: sigungu,
              ));
            }
          }

          // 동/읍/면 추출
          for (final part in parts.skip(2)) {
            if (part.endsWith('동') ||
                part.endsWith('읍') ||
                part.endsWith('면') ||
                part.endsWith('리')) {
              final key = '$sido $sigungu $part';
              if (!seen.contains(key)) {
                seen.add(key);
                results.add(KakaoAddressResult(
                  displayText: key,
                  filterKeyword: part,
                ));
              }
            }
          }

          // 도로명 추출
          for (final part in parts.skip(2)) {
            if (part.endsWith('로') ||
                part.endsWith('길') ||
                part.endsWith('대로')) {
              final key = '$sido $sigungu $part';
              if (!seen.contains(key)) {
                seen.add(key);
                results.add(KakaoAddressResult(
                  displayText: key,
                  filterKeyword: part,
                ));
              }
            }
          }
        }

        return results;
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('[KakaoAddressService] searchAddress error: $e');
      return [];
    }
  }
}
