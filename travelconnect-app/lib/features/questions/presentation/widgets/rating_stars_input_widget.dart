import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

class RatingStarsInputWidget extends StatefulWidget {
  final int? initialRating;
  final Function(int) onRatingChanged;
  final bool isLoading;
  final double size;

  const RatingStarsInputWidget({
    super.key,
    this.initialRating,
    required this.onRatingChanged,
    this.isLoading = false,
    this.size = 34,
  });

  @override
  State<RatingStarsInputWidget> createState() => _RatingStarsInputWidgetState();
}

class _RatingStarsInputWidgetState extends State<RatingStarsInputWidget>
    with SingleTickerProviderStateMixin {
  int? _hoverRating;
  late AnimationController _animationController;

  static const Color _starColor = Color(0xFFF59E0B);
  static const Color _starHoverColor = Color(0xFFFBBF24);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onStarTap(int rating) {
    if (widget.isLoading) return;

    HapticFeedback.lightImpact();
    _animationController.forward().then((_) => _animationController.reverse());
    widget.onRatingChanged(rating);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          final starValue = index + 1;
          final isSelected = (widget.initialRating ?? 0) >= starValue;
          final isHovered = (_hoverRating ?? 0) >= starValue;

          return GestureDetector(
            onTap: () => _onStarTap(starValue),
            child: MouseRegion(
              onEnter: (_) => setState(() => _hoverRating = starValue),
              onExit: (_) => setState(() => _hoverRating = null),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  isSelected || isHovered ? Icons.star : Icons.star_border,
                  color: isSelected
                      ? _starColor
                      : isHovered
                          ? _starHoverColor
                          : AppColors.textTertiary,
                  size: widget.size,
                ),
              ),
            ),
          );
        }),
        if (widget.isLoading) ...[
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _starColor,
            ),
          ),
        ],
      ],
    );
  }
}
