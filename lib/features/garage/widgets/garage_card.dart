import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/garage_model.dart';
import 'star_rating_widget.dart';

class GarageCard extends StatelessWidget {
  final GarageModel garage;
  final bool isMyGarage;
  final VoidCallback? onTap;

  const GarageCard({
    super.key,
    required this.garage,
    this.isMyGarage = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 정비소명
            Text(
              garage.name,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                decoration: isMyGarage ? TextDecoration.underline : null,
                decorationColor: AppColors.textPrimary,
              ),
            ),
            // 주소
            if (garage.address != null) ...[
              const SizedBox(height: 4),
              Text(
                garage.address!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            // 별점 + 리뷰 수
            const SizedBox(height: 6),
            Row(
              children: [
                StarRatingWidget(
                  rating: garage.averageRating,
                  size: 14,
                  filledColor: isMyGarage ? AppColors.primary : null,
                ),
                const SizedBox(width: 6),
                Text(
                  '${garage.reviewCount}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
