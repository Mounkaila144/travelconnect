import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelconnect_app/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../injection.dart';
import '../bloc/report_bloc.dart';
import 'report_reason_sheet_widget.dart';

class ReportButtonWidget extends StatelessWidget {
  final String reportableType;
  final int reportableId;

  const ReportButtonWidget({
    super.key,
    required this.reportableType,
    required this.reportableId,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return IconButton(
      icon: const Icon(Icons.flag_outlined, color: AppColors.textTertiary),
      iconSize: 20,
      tooltip: l10n.report_flagTooltip,
      onPressed: () => _showReportSheet(context),
    );
  }

  void _showReportSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => BlocProvider(
        create: (_) => sl<ReportBloc>(),
        child: ReportReasonSheetWidget(
          reportableType: reportableType,
          reportableId: reportableId,
        ),
      ),
    );
  }
}
