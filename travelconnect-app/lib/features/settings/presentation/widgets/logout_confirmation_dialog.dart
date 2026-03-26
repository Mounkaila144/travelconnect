import 'package:flutter/material.dart';
import 'package:travelconnect_app/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';

Future<bool> showLogoutConfirmationDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text(l10n.logout_title),
      content: Text(l10n.logout_message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.logout_cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.error,
          ),
          child: Text(l10n.logout_confirm),
        ),
      ],
    ),
  );

  return result ?? false;
}
