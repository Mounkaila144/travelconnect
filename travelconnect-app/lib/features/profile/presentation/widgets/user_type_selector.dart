import 'package:flutter/material.dart';
import 'package:travelconnect_app/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

class UserTypeSelector extends StatelessWidget {
  final String? selectedType;
  final ValueChanged<String> onSelected;

  const UserTypeSelector({
    super.key,
    this.selectedType,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: _TypeCard(
            type: 'traveler',
            label: l10n.userType_traveler,
            description: l10n.userType_travelerDesc,
            icon: Icons.luggage,
            color: AppColors.primary,
            isSelected: selectedType == 'traveler',
            onTap: () => onSelected('traveler'),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _TypeCard(
            type: 'local_supporter',
            label: l10n.userType_localSupporter,
            description: l10n.userType_localSupporterDesc,
            icon: Icons.location_on,
            color: AppColors.success,
            isSelected: selectedType == 'local_supporter',
            onTap: () => onSelected('local_supporter'),
          ),
        ),
      ],
    );
  }
}

class _TypeCard extends StatelessWidget {
  final String type;
  final String label;
  final String description;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeCard({
    required this.type,
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : AppColors.surfaceWhite,
          border: Border.all(
            color: isSelected ? color : AppColors.borderLight,
            width: isSelected ? 2.5 : 1,
          ),
          borderRadius: AppRadius.lgAll,
          boxShadow: isSelected ? AppShadows.subtle : null,
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.15)
                    : AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: isSelected ? color : AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
