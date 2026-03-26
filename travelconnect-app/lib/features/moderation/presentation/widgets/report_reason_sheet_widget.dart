import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travelconnect_app/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/report_reason.dart';
import '../bloc/report_bloc.dart';
import '../bloc/report_event.dart';
import '../bloc/report_state.dart';

class ReportReasonSheetWidget extends StatefulWidget {
  final String reportableType;
  final int reportableId;

  const ReportReasonSheetWidget({
    super.key,
    required this.reportableType,
    required this.reportableId,
  });

  @override
  State<ReportReasonSheetWidget> createState() =>
      _ReportReasonSheetWidgetState();
}

class _ReportReasonSheetWidgetState extends State<ReportReasonSheetWidget> {
  ReportReason? _selectedReason;
  final _commentController = TextEditingController();
  static const _maxCommentLength = 500;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocConsumer<ReportBloc, ReportState>(
      listener: (context, state) {
        if (state is ReportSubmitted) {
          Navigator.pop(context);
          HapticFeedback.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.report_success),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is ReportError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isSubmitting = state is ReportSubmitting;

        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            top: AppSpacing.xl,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.flag, color: AppColors.error),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    l10n.report_title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed:
                        isSubmitting ? null : () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Reasons
              Text(
                l10n.report_reasonLabel,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              RadioGroup<ReportReason>(
                groupValue: _selectedReason,
                onChanged: (value) {
                  if (!isSubmitting) {
                    setState(() => _selectedReason = value);
                  }
                },
                child: Column(
                  children: ReportReason.values.map(
                    (reason) => RadioListTile<ReportReason>(
                      title: Text(reason.displayName),
                      value: reason,
                      dense: true,
                    ),
                  ).toList(),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Comment
              TextField(
                controller: _commentController,
                maxLength: _maxCommentLength,
                maxLines: 3,
                enabled: !isSubmitting,
                decoration: InputDecoration(
                  labelText: l10n.report_comment,
                  hintText: l10n.report_commentHint,
                ),
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          isSubmitting ? null : () => Navigator.pop(context),
                      child: Text(l10n.report_cancel),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedReason == null || isSubmitting
                          ? null
                          : () => _submitReport(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(l10n.report_submit),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _submitReport(BuildContext context) {
    final comment = _commentController.text.trim();
    context.read<ReportBloc>().add(
          SubmitReport(
            reportableType: widget.reportableType,
            reportableId: widget.reportableId,
            reason: _selectedReason!.apiValue,
            comment: comment.isEmpty ? null : comment,
          ),
        );
  }
}
