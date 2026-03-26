import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

class UserTypeBadge extends StatelessWidget {
  final String userType;

  const UserTypeBadge({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    final isLocal = userType == 'local_supporter';

    final Color baseColor =
        isLocal ? AppColors.success : AppColors.primary;
    final Color endColor =
        isLocal ? AppColors.secondaryDark : AppColors.primaryLight;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [baseColor, endColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.xlAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLocal ? Icons.location_on : Icons.luggage,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            isLocal ? 'Local Supporter' : 'Voyageur',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
