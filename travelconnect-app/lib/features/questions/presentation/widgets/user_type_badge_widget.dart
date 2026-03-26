import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

class UserTypeBadgeWidget extends StatelessWidget {
  final String userType;

  const UserTypeBadgeWidget({super.key, required this.userType});

  bool get _isLocal => userType == 'local_supporter';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _isLocal ? AppColors.successLight : const Color(0xFFD4E4F7),
        borderRadius: AppRadius.xlAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isLocal ? Icons.location_city : Icons.flight,
            size: 14,
            color: _isLocal ? AppColors.success : AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            _isLocal ? 'Local' : 'Voyageur',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _isLocal ? AppColors.success : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
