import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class RatingStarsWidget extends StatelessWidget {
  final double rating;
  final int? count;
  final double size;

  static const Color _starColor = Color(0xFFF59E0B);

  const RatingStarsWidget({
    super.key,
    required this.rating,
    this.count,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          if (index < rating.floor()) {
            return Icon(Icons.star, color: _starColor, size: size);
          } else if (index < rating) {
            return Icon(Icons.star_half, color: _starColor, size: size);
          } else {
            return Icon(
              Icons.star_border,
              color: AppColors.textTertiary,
              size: size,
            );
          }
        }),
        if (count != null) ...[
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              count! > 0
                  ? '${rating.toStringAsFixed(1)} ($count ${count == 1 ? 'note' : 'notes'})'
                  : '(Pas encore noté)',
              style: TextStyle(
                fontSize: size * 0.65,
                color: AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}
