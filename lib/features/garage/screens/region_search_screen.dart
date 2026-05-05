import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/kakao_address_service.dart';
import '../../../providers/region_provider.dart';

class RegionSearchScreen extends ConsumerStatefulWidget {
  const RegionSearchScreen({super.key});

  @override
  ConsumerState<RegionSearchScreen> createState() =>
      _RegionSearchScreenState();
}

class _RegionSearchScreenState extends ConsumerState<RegionSearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _query = value.trim());
    });
  }

  void _selectAddress(KakaoAddressResult result) {
    ref.read(addressFilterProvider.notifier).set(
      AddressFilter(
        keyword: result.filterKeyword,
        displayText: result.displayText,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final addressAsync =
        _query.isNotEmpty ? ref.watch(addressSearchProvider(_query)) : null;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintText: '지역명, 도로명 검색',
            hintStyle: const TextStyle(
              color: AppColors.textHint,
              fontSize: 16,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.cancel,
                        size: 18, color: AppColors.textHint),
                    onPressed: () {
                      _controller.clear();
                      setState(() => _query = '');
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            setState(() {});
            _onSearchChanged(value);
          },
        ),
      ),
      body: _query.isEmpty
          ? const SizedBox.shrink()
          : _buildResults(addressAsync),
    );
  }

  Widget _buildResults(AsyncValue<List<KakaoAddressResult>>? addressAsync) {
    if (addressAsync == null) return const SizedBox.shrink();

    return addressAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const Center(
        child: Text(
          '검색 중 오류가 발생했습니다',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
      data: (results) {
        if (results.isEmpty) {
          return const Center(
            child: Text(
              '검색 결과가 없습니다',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: results.length,
          separatorBuilder: (_, _) => const Divider(height: 1, indent: 44),
          itemBuilder: (context, index) {
            final result = results[index];
            return InkWell(
              onTap: () => _selectAddress(result),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildHighlightedText(
                          result.displayText, _query),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHighlightedText(String text, String query) {
    const baseStyle = TextStyle(fontSize: 15, color: AppColors.textPrimary);

    if (query.isEmpty) return Text(text, style: baseStyle);

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final startIndex = lowerText.indexOf(lowerQuery);

    if (startIndex == -1) return Text(text, style: baseStyle);

    final endIndex = startIndex + query.length;

    return RichText(
      text: TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: text.substring(0, startIndex)),
          TextSpan(
            text: text.substring(startIndex, endIndex),
            style: TextStyle(
              color: AppColors.primary,
              fontSize: baseStyle.fontSize,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(text: text.substring(endIndex)),
        ],
      ),
    );
  }
}
