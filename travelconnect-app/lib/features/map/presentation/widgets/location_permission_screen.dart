import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

import '../bloc/map_bloc.dart';
import '../bloc/map_event.dart';
import '../bloc/map_state.dart';

class LocationPermissionScreen extends StatelessWidget {
  final LocationPermissionRequiredReason reason;

  const LocationPermissionScreen({super.key, required this.reason});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _icon,
                  size: 56,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                _title(l10n),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                _description(l10n),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxxl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _onPrimaryAction(context),
                  child: Text(_primaryButtonText(l10n)),
                ),
              ),
              if (reason == LocationPermissionRequiredReason.deniedPermanently ||
                  reason == LocationPermissionRequiredReason.serviceDisabled) ...[
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      context.read<MapBloc>().add(const InitializeMap());
                    },
                    child: Text(l10n.location_retry),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData get _icon {
    switch (reason) {
      case LocationPermissionRequiredReason.serviceDisabled:
        return Icons.location_off;
      case LocationPermissionRequiredReason.deniedPermanently:
        return Icons.settings;
      case LocationPermissionRequiredReason.denied:
        return Icons.location_on;
    }
  }

  String _title(AppLocalizations l10n) {
    switch (reason) {
      case LocationPermissionRequiredReason.serviceDisabled:
        return l10n.location_serviceDisabledTitle;
      case LocationPermissionRequiredReason.deniedPermanently:
      case LocationPermissionRequiredReason.denied:
        return l10n.location_requiredTitle;
    }
  }

  String _description(AppLocalizations l10n) {
    switch (reason) {
      case LocationPermissionRequiredReason.serviceDisabled:
        return l10n.location_serviceDisabledDesc;
      case LocationPermissionRequiredReason.deniedPermanently:
        return l10n.location_deniedPermanentlyDesc;
      case LocationPermissionRequiredReason.denied:
        return l10n.location_deniedDesc;
    }
  }

  String _primaryButtonText(AppLocalizations l10n) {
    switch (reason) {
      case LocationPermissionRequiredReason.serviceDisabled:
        return l10n.location_enableLocation;
      case LocationPermissionRequiredReason.deniedPermanently:
        return l10n.location_openSettings;
      case LocationPermissionRequiredReason.denied:
        return l10n.location_allowLocation;
    }
  }

  void _onPrimaryAction(BuildContext context) {
    switch (reason) {
      case LocationPermissionRequiredReason.serviceDisabled:
        context
            .read<MapBloc>()
            .getCurrentLocation
            .repository
            .openLocationSettings();
        break;
      case LocationPermissionRequiredReason.deniedPermanently:
        context
            .read<MapBloc>()
            .getCurrentLocation
            .repository
            .openAppSettings();
        break;
      case LocationPermissionRequiredReason.denied:
        context.read<MapBloc>().add(const RequestLocationPermission());
        break;
    }
  }
}
