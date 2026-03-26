import 'dart:ui';

import '../theme/app_colors.dart';

class TrustScoreColors {
  static Color getColorForScore(double score) {
    if (score < 2.0) return AppColors.error;
    if (score < 3.0) return AppColors.warning;
    if (score < 4.0) return const Color(0xFFEAB308);
    if (score < 4.5) return AppColors.secondary;
    return AppColors.success;
  }

  static String getScoreLabel(double score) {
    if (score < 2.0) return 'Débutant';
    if (score < 3.0) return 'En progression';
    if (score < 4.0) return 'Fiable';
    if (score < 4.5) return 'Excellent';
    return 'Expert';
  }
}
