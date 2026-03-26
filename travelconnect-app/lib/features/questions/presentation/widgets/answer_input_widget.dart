import 'package:flutter/material.dart';
import 'package:travelconnect_app/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

class AnswerInputWidget extends StatefulWidget {
  final Function(String) onSubmit;
  final VoidCallback onCancel;
  final bool isSubmitting;

  const AnswerInputWidget({
    super.key,
    required this.onSubmit,
    required this.onCancel,
    this.isSubmitting = false,
  });

  @override
  State<AnswerInputWidget> createState() => _AnswerInputWidgetState();
}

class _AnswerInputWidgetState extends State<AnswerInputWidget> {
  final _controller = TextEditingController();
  static const _maxLength = 1000;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.all(AppSpacing.lg),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              maxLength: _maxLength,
              maxLines: 8,
              minLines: 3,
              autofocus: true,
              decoration: InputDecoration(
                hintText: l10n.answerInput_hint,
              ),
              buildCounter: (context,
                  {required currentLength,
                  required isFocused,
                  maxLength}) {
                return Text(
                  '$currentLength/$maxLength',
                  style: TextStyle(
                    color: currentLength >= maxLength!
                        ? AppColors.error
                        : AppColors.textSecondary,
                  ),
                );
              },
              enabled: !widget.isSubmitting,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: widget.isSubmitting ? null : widget.onCancel,
                  child: Text(l10n.answerInput_cancel),
                ),
                const SizedBox(width: AppSpacing.sm),
                ElevatedButton(
                  onPressed:
                      widget.isSubmitting || _controller.text.trim().isEmpty
                          ? null
                          : () {
                              widget.onSubmit(_controller.text.trim());
                              _controller.clear();
                            },
                  child: widget.isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.answerInput_send),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
