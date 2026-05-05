import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class StarRatingWidget extends StatelessWidget {
  final double rating;
  final double size;
  final Color? filledColor;

  const StarRatingWidget({
    super.key,
    required this.rating,
    this.size = 16,
    this.filledColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = filledColor ?? AppColors.starFilled;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        if (rating >= starValue) {
          return Icon(Icons.star, size: size, color: color);
        } else if (rating >= starValue - 0.5) {
          return Icon(Icons.star_half, size: size, color: color);
        } else {
          return Icon(Icons.star_border, size: size, color: AppColors.starEmpty);
        }
      }),
    );
  }
}
