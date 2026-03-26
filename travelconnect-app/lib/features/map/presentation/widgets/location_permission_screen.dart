import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

import '../bloc/map_bloc.dart';
import '../bloc/map_event.dart';
import '../bloc/map_state.dart';

class LocationPermissionScreen extends StatelessWidget {
  final LocationPermissionRequiredReason reason;

  const LocationPermissionScreen({super.key, required this.reason});

  @override
  Widget build(BuildContext context) {
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
                _title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                _description,
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
                  child: Text(_primaryButtonText),
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
                    child: const Text('Réessayer'),
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

  String get _title {
    switch (reason) {
      case LocationPermissionRequiredReason.serviceDisabled:
        return 'Service de localisation désactivé';
      case LocationPermissionRequiredReason.deniedPermanently:
        return 'Localisation requise';
      case LocationPermissionRequiredReason.denied:
        return 'Localisation requise';
    }
  }

  String get _description {
    switch (reason) {
      case LocationPermissionRequiredReason.serviceDisabled:
        return 'TravelConnect a besoin de votre localisation pour vous montrer les questions autour de vous. '
            'Veuillez activer le service de localisation de votre appareil.';
      case LocationPermissionRequiredReason.deniedPermanently:
        return 'TravelConnect a besoin de votre localisation pour fonctionner. '
            'Veuillez autoriser l\'accès à la localisation dans les paramètres de l\'application.';
      case LocationPermissionRequiredReason.denied:
        return 'TravelConnect a besoin de votre localisation pour vous montrer les questions autour de vous. '
            'Veuillez autoriser l\'accès à votre position.';
    }
  }

  String get _primaryButtonText {
    switch (reason) {
      case LocationPermissionRequiredReason.serviceDisabled:
        return 'Activer la localisation';
      case LocationPermissionRequiredReason.deniedPermanently:
        return 'Ouvrir les paramètres';
      case LocationPermissionRequiredReason.denied:
        return 'Autoriser la localisation';
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
