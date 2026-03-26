import 'package:flutter/material.dart';

import '../../../../core/widgets/trust_score_display_widget.dart';

class TrustScoreWidget extends StatelessWidget {
  final double trustScore;
  final bool isNew;

  const TrustScoreWidget({
    super.key,
    required this.trustScore,
    this.isNew = false,
  });

  @override
  Widget build(BuildContext context) {
    return TrustScoreDisplayWidget(
      score: trustScore,
      isNew: isNew,
      size: TrustScoreSize.large,
    );
  }
}
